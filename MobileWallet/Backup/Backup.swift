//  Backup.swift

/*
 Package MobileWallet
 Created by S.Shovkoplyas on 04.06.2020
 Using Swift 5.0
 Running on macOS 10.15
 
 Copyright 2019 The Tari Project
 
 Redistribution and use in source and binary forms, with or
 without modification, are permitted provided that the
 following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 3. Neither the name of the copyright holder nor the names of
 its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

protocol BackupObserver: AnyObject {
    func didFinishUploadBackup(percent: Double, completed: Bool, error: Error?)
}

class Backup: NSObject {

    var query: NSMetadataQuery!

    private let containerIdentifier = "iCloud.com.tari.wallet"
    private let DocumentsFolder = "Documents"
    private let directory = TariLib.shared.databaseDirectory
    private let fileName = TariLib.databaseName

    private var observers = NSPointerArray.weakObjects()

    static let shared = Backup()

    override init() {
        super.init()
        initialiseQuery()
        addNotificationObservers()
    }

    func initialiseQuery() {
        query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)
    }

    func addObserver(_ observer: BackupObserver) {
        observers.addObject(observer)
    }

    func startBackup() throws {
        let fileURL = directory
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent(DocumentsFolder) else { return }

        if !FileManager.default.fileExists(atPath: containerURL.path) {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
        }
        let backupFileURL = containerURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: backupFileURL.path) {
            try FileManager.default.removeItem(at: backupFileURL)
            try FileManager.default.copyItem(at: fileURL, to: backupFileURL)
        } else {
            try FileManager.default.copyItem(at: fileURL, to: backupFileURL)
        }

        query.operationQueue?.addOperation({ [weak self] in
            _ = self?.query.start()
            self?.query.enableUpdates()
        })
    }

    func downloadBackup(completion:((_ path: String) -> Void)) {
        let fileManager = FileManager.default
        if let icloudFolderURL = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent(DocumentsFolder),
            let urls = try? fileManager.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {

            if let myURL = urls.first {
                var lastPathComponent = myURL.lastPathComponent
                let folderPath = myURL.deletingLastPathComponent().path
                // if the last path component contains the “.icloud” extension. If yes the file is not on the device else the file is already downloaded.
                if lastPathComponent.contains(".icloud") {
                    lastPathComponent.removeFirst()
                    let downloadedFilePath = folderPath + "/" + lastPathComponent.replacingOccurrences(of: ".icloud", with: "")
                    var isDownloaded = false
                    while !isDownloaded {
                        if fileManager.fileExists(atPath: downloadedFilePath) {
                            isDownloaded = true
                        }
                        completion(downloadedFilePath)
                    }
                } else {
                    completion(myURL.path)
                }
            }
        }
    }

    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidStartGathering, object: query, queue: query.operationQueue) { [weak self] (_) in
            self?.notifyObservers(percent: 0, completed: false, error: nil)
            self?.processCloudFiles()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: query.operationQueue) { [weak self] (_) in
            self?.processCloudFiles()
        }
    }

    private func processCloudFiles() {
        if query.resultCount == 0 { return }
        var fileItem: NSMetadataItem?
        var fileURL: URL?

        for item in query.results {

            guard let item = item as? NSMetadataItem else { continue }
            guard let fileItemURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { continue }
            if fileItemURL.lastPathComponent.contains(fileName) {
                fileItem = item
                fileURL = fileItemURL
            }
        }

        let fileValues = try? fileURL!.resourceValues(forKeys: [URLResourceKey.ubiquitousItemIsUploadingKey])
        if let fileUploaded = fileItem?.value(forAttribute: NSMetadataUbiquitousItemIsUploadedKey) as? Bool, fileUploaded == true, fileValues?.ubiquitousItemIsUploading == false {
            notifyObservers(percent: 100, completed: true, error: nil)

        } else if let error = fileValues?.ubiquitousItemUploadingError {
            notifyObservers(percent: 0, completed: false, error: error)

        } else {
            if let fileProgress = fileItem?.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double {
                notifyObservers(percent: fileProgress, completed: false, error: nil)
            }
        }
    }

    private func notifyObservers(percent: Double, completed: Bool, error: Error?) {
        observers.allObjects.forEach {
            if let object = $0 as? BackupObserver {
                object.didFinishUploadBackup(percent: percent, completed: completed, error: error)
            }
        }
    }
}
