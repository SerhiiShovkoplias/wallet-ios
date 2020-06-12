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

enum ICloudBackupWalletError: Error {
    case failedToCreateArchive
    case noAnyBackups
    case unzipError
    case dbFileNotFound
    case iCloudContainerNotFound
    case unableCreateBackupFolder
    case privateKeyError
}

extension ICloudBackupWalletError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedToCreateArchive:
            return NSLocalizedString("Failed to create wallet backup archive", comment: "backup archive error description")
        case .noAnyBackups:
            return NSLocalizedString("You have not any wallet backup", comment: "'No any wallet backup' error description")
        case .unzipError:
            return NSLocalizedString("Unable to unarchive wallet from iCloud backup", comment: "unarchive wallet error description")
        case .dbFileNotFound:
            return NSLocalizedString("Unable to create wallet backup. File not found", comment: "sqlite file not found error description")
        case .iCloudContainerNotFound:
            return NSLocalizedString("Unable to create wallet backup. iCloud container not found", comment: "iCloud container not found error description")
        case .unableCreateBackupFolder:
            return NSLocalizedString("Unable to create backup folder", comment: "Unable to create backup folder error descroption")
        case .privateKeyError:
            return NSLocalizedString("Unable to restore wallet. Private key error", comment: "Unable to restore wallet private key error descroption")
        }
    }
}

protocol ICloudBackupObserver: AnyObject {
    func didFinishUploadBackup(percent: Double, completed: Bool, error: Error?)
}

class ICloudBackup: NSObject {

    var query: NSMetadataQuery!

    private let containerIdentifier = "iCloud.com.tari.wallet"
    private let directory = TariLib.shared.databaseDirectory
    private let fileName = "Tari-Aurora-Backup"
    private var observers = NSPointerArray.weakObjects()

    var inProgress: Bool = false
    private(set) var progressValue: Double = 0.0

    static let shared = ICloudBackup()

    override init() {
        super.init()
        initialiseQuery()
        addNotificationObservers()
    }

    func initialiseQuery() {
        query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K LIKE '*.zip'", NSMetadataItemFSNameKey)
    }

    func addObserver(_ observer: ICloudBackupObserver) {
        observers.addObject(observer)
    }

    // returns true if backup of current wallet is exist
    func isBackupExist() -> Bool {
        let fileManager = FileManager.default
        guard let backupFolder = TariLib.shared.tariWallet?.publicKey.0?.hex.0 else { return false }

        do {
            let icloudFolderURL = try iCloudDirectory()

            if let urls = try? fileManager.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {
                if let _ = urls.first(where: { $0.absoluteString.contains(backupFolder) }) { return true }
            }
        } catch {
            return false
        }

        return false
    }

    func createWalletBackup() throws {
        guard let backupFolder = TariLib.shared.tariWallet?.publicKey.0?.hex.0 else { throw ICloudBackupWalletError.iCloudContainerNotFound }

        let fileURL = try zipBackupFiles()
        let containerURL = try iCloudDirectory().appendingPathComponent(backupFolder)

        if !FileManager.default.fileExists(atPath: containerURL.path) {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
        }
        let backupFileURL = containerURL.appendingPathComponent(fileURL.lastPathComponent)
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

    func restoreWallet(completion: () -> Void) throws {
        Keychain.logout()
        let wallets = try existsWallets()
        guard let firstWallet = wallets.first else { return }

        let dbDirectory = TariLib.shared.databaseDirectory
        try FileManager.default.createDirectory(at: dbDirectory, withIntermediateDirectories: true, attributes: nil)

        try ICloudBackup.shared.restoreBackup(walletFolder: firstWallet, to: dbDirectory) {
            let privateKey = PrivateKey()
            let (privateKeyHex, hexError) = privateKey.hex

            if hexError != nil {
                try FileManager.default.removeItem(at: dbDirectory)
                throw ICloudBackupWalletError.privateKeyError
            }

            //Save to keychain and then ensure it's there (If one exists already in the keychain this will overwrite it)
            TariLib.shared.storedPrivateKey = privateKeyHex
            guard TariLib.shared.storedPrivateKey != nil else {
                TariLogger.error("Failed to save private key to keychain")
                try FileManager.default.removeItem(at: dbDirectory)
                throw ICloudBackupWalletError.privateKeyError
            }
            completion()
        }
    }
}

// MARK: - private methods
extension ICloudBackup {
    private func restoreBackup(walletFolder: String, to directory: URL, completion:(() throws -> Void)) throws {
        try downloadBackup(walletFolder: walletFolder) { zippedBackup in
            try unzipBackup(url: zippedBackup, to: directory)
            try completion()
        }
    }

    private func downloadBackup(walletFolder: String, completion:((_ url: URL) throws -> Void)) throws {
        let fileManager = FileManager.default
        let icloudFolderURL = try iCloudDirectory().appendingPathComponent(walletFolder)
        let urls = try fileManager.contentsOfDirectory(atURL: icloudFolderURL, sortedBy: .created, options: [])

        if let backupUrl = urls.last {
            var lastPathComponent = backupUrl.lastPathComponent
            let folderPath = backupUrl.deletingLastPathComponent().path
            // if the last path component contains the “.icloud” extension. If yes the file is not on the device else the file is already downloaded.

            if lastPathComponent.contains(".icloud") {
                lastPathComponent.removeFirst()
                let downloadedFilePath = folderPath + "/" + lastPathComponent.replacingOccurrences(of: ".icloud", with: "")
                var isDownloaded = false
                try fileManager.startDownloadingUbiquitousItem(at: backupUrl)

                while !isDownloaded {
                    if fileManager.fileExists(atPath: downloadedFilePath) {
                        isDownloaded = true
                        try completion(URL(fileURLWithPath: downloadedFilePath))
                    }
                }
            } else {
                try completion(backupUrl)
            }
        }
    }

    private func existsWallets() throws -> [String] {
        var wallets = [String]()
        let icloudFolderURL = try iCloudDirectory()
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: [])
            urls.forEach({
                if $0.lastPathComponent != "Documents" {
                    wallets.append($0.lastPathComponent)
                }
            })
            if wallets.isEmpty {
                throw ICloudBackupWalletError.noAnyBackups
            }
            return wallets
        } catch {
            throw ICloudBackupWalletError.noAnyBackups
        }
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
            try? cleanTempDirectory()
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
            if let object = $0 as? ICloudBackupObserver {
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

    private func zipBackupFiles() throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let dateString = dateFormatter.string(from: Date())
        let archiveName = "\(fileName)_\(dateString).zip"

        let tempDirectory = try tempZipDirectory()
        let archiveURL = tempDirectory.appendingPathComponent(archiveName)

        if let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: directory.path) {
            guard
                let files = enumerator.allObjects as? [String],
                let sqlite3File = files.first(where: { $0.hasSuffix(".sqlite3")})
                else {
                    throw ICloudBackupWalletError.dbFileNotFound
            }
            try FileManager().zipItem(at: directory.appendingPathComponent(sqlite3File), to: archiveURL)
            return archiveURL
        }
        throw ICloudBackupWalletError.dbFileNotFound
    }

    private func iCloudDirectory() throws -> URL {
        guard let url = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier)?.appendingPathComponent("Tari-Wallet-Backups") else {
            throw ICloudBackupWalletError.iCloudContainerNotFound
        }
        return url
    }

    private func tempZipDirectory() throws -> URL {
        if let tempZipDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Backups") {

            if !FileManager.default.fileExists(atPath: tempZipDirectory.path) {
                try FileManager.default.createDirectory(at: tempZipDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            return tempZipDirectory
        } else { throw ICloudBackupWalletError.failedToCreateArchive }
    }

    private func cleanTempDirectory() throws {
        let directory = try tempZipDirectory()
        try FileManager.default.removeItem(at: directory)
    }
}
