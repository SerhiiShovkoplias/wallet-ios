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

enum BackupWalletError: Error {
    case noAnyBackups
    case unzipError
}

extension BackupWalletError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noAnyBackups:
            return NSLocalizedString("You have not any wallet backup", comment: "'No any wallet backup' error description")
        case .unzipError:
            return NSLocalizedString("Can't unarchive wallet from iCloud beckup", comment: "unarchive wallet error description")
        }

    }
}

protocol BackupObserver: AnyObject {
    func didFinishUploadBackup(percent: Double, completed: Bool, error: Error?)
}

class Backup: NSObject {

    var query: NSMetadataQuery!

    private let containerIdentifier = "iCloud.com.tari.wallet"
    private let backupFolder = TariLib.shared.tariWallet?.publicKey.0?.hex.0
    private let directory = TariLib.shared.databaseDirectory
    private let fileName = TariLib.databaseName

    private var observers = NSPointerArray.weakObjects()

    var inProgress: Bool = false
    private(set) var progressValue: Double = 0.0

    static let shared = Backup()

    override init() {
        super.init()
        initialiseQuery()
        addNotificationObservers()
    }

    func initialiseQuery() {
        query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)
    }

    func addObserver(_ observer: BackupObserver) {
        observers.addObject(observer)
    }

    // returns true if backup of current wallet is exist
    func isBackupExist() -> Bool {
        let fileManager = FileManager.default
        guard let backupFolder = backupFolder else { return false }
        if let icloudFolderURL = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent(backupFolder),
            let urls = try? fileManager.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {
            if let _ = urls.first(where: { $0.absoluteString.contains(backupFolder) }) {
                return true
            }
        }
        return false
    }

    func createWalletBackup() throws {
        guard
            let fileURL = try zipBackupFiles(),
            let backupFolder = backupFolder,
            let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent(backupFolder)
            else { return }

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

    func restoreWallet(completion: (_ success: Bool) -> Void) throws {
        let wallets = existsWallets()

        guard
            let firstWallet = wallets.first,
            let dbDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { throw BackupWalletError.noAnyBackups }

        do {
            try Backup.shared.restoreBackup(walletFolder: firstWallet, to: dbDirectory) { (success) in
                completion(success)
            }
        } catch {
            throw error
        }
    }
}

// MARK: - private methods
extension Backup {
    private func restoreBackup(walletFolder: String, to directory: URL, completion:((_ success: Bool) -> Void)) throws {
        downloadBackup(walletFolder: walletFolder) { [weak self] in
            guard let zippedBackup = $0,
                ((try? self?.unzipBackup(url: zippedBackup, to: directory)) != nil) else {
                    completion(false)
                    throw BackupWalletError.unzipError
            }
            completion(true)
        }
    }

    private func downloadBackup(walletFolder: String, completion:((_ url: URL?) throws -> Void)) {
        let fileManager = FileManager.default
        if let icloudFolderURL = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent(walletFolder),
            let urls = try? fileManager.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {

            if let backupUrl = urls.first(where: { $0.absoluteString.contains(walletFolder) }) {
                var lastPathComponent = backupUrl.lastPathComponent
                let folderPath = backupUrl.deletingLastPathComponent().path
                // if the last path component contains the “.icloud” extension. If yes the file is not on the device else the file is already downloaded.

                if lastPathComponent.contains(".icloud") {
                    lastPathComponent.removeFirst()
                    let downloadedFilePath = folderPath + "/" + lastPathComponent.replacingOccurrences(of: ".icloud", with: "")
                    var isDownloaded = false
                    try? fileManager.startDownloadingUbiquitousItem(at: backupUrl)

                    while !isDownloaded {
                        if fileManager.fileExists(atPath: downloadedFilePath) {
                            isDownloaded = true
                            try? completion(URL(fileURLWithPath: downloadedFilePath))
                        }
                    }
                } else {
                    try? completion(backupUrl)
                }
            } else {
                try? completion(nil)
            }
        } else {
            try? completion(nil)
        }
    }

    private func existsWallets() -> [String] {
        let fileManager = FileManager.default
        var wallets = [String]()
        if let icloudFolderURL = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier) {
            let urls = try? fileManager.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: [])
            urls?.forEach({
                if $0.lastPathComponent != "Documents" {
                    wallets.append($0.lastPathComponent)
                }
            })
        }
        return wallets
    }

    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidStartGathering, object: query, queue: query.operationQueue) { [weak self] (_) in
            self?.notifyObservers(percent: 0, completed: false, error: nil)
            self?.inProgress = true
            self?.progressValue = 0.0
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
            progressValue = 0.0
            inProgress = false
        } else if let error = fileValues?.ubiquitousItemUploadingError {
            notifyObservers(percent: 0, completed: false, error: error)
            progressValue = 0.0
            inProgress = false
        } else {
            if let fileProgress = fileItem?.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double {
                notifyObservers(percent: fileProgress, completed: false, error: nil)
                progressValue = fileProgress
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

    private func unzipBackup(url: URL, to directory: URL) throws {
        do {
            try FileManager.default.unzipItem(at: url, to: directory)
        } catch {
            throw error
        }
    }

    private func zipBackupFiles() throws -> URL? {
        guard let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) else {
            return nil
        }
        do {
            try FileManager().zipItem(at: directory, to: archiveURL)
            return archiveURL
        } catch {
            throw error
        }
    }
}
