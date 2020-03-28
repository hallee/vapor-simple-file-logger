//
//  SimpleFileLogger.swift
//  SimpleFileLogger
//
//  Created by Hal Lee on 9/8/18.
//

import Vapor

public final class SimpleFileLogger: Logger {

    let executableName: String
    let includeTimestamps: Bool
    let fileManager = FileManager.default
    let fileQueue = DispatchQueue.init(label: "vaporSimpleFileLogger", qos: .utility)
    var fileHandles = [URL: Foundation.FileHandle]()
    let excludeLogLevels: [LogLevel]

    lazy var logDirectoryURL: URL? = {
        var baseURL: URL?
        #if os(macOS)
        /// ~/Library/Caches/
        if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            baseURL = url
        } else { print("Unable to find caches directory.") }
        #endif
        #if os(Linux)
        baseURL = URL(fileURLWithPath: "/var/log/")
        #endif

        /// Append executable name; ~/Library/Caches/executableName/ (macOS),
        /// or /var/log/executableName/ (Linux)
        do {
            if let executableURL = baseURL?.appendingPathComponent(executableName, isDirectory: true) {
                try fileManager.createDirectory(at: executableURL, withIntermediateDirectories: true, attributes: nil)
                baseURL = executableURL
            }
        } catch { print("Unable to create \(executableName) log directory.") }

        return baseURL
    }()

    public init(executableName: String = "Vapor", includeTimestamps: Bool = false, excludeLogLevels: [LogLevel] = []) {
        // TODO: sanitize executableName for path use
        self.executableName = executableName
        self.includeTimestamps = includeTimestamps
        self.excludeLogLevels = excludeLogLevels
    }

    deinit {
        for (_, handle) in fileHandles {
            handle.closeFile()
        }
    }

    public func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        guard !excludeLogLevels.contains(where: { $0.description == level.description }) else { return }
        let fileName = level.description.lowercased() + ".log"
        var output = "[ \(level.description) ] \(string) (\(file):\(line))"
        if includeTimestamps {
            output = "\(Date() ) " + output
        }
        saveToFile(output, fileName: fileName)
    }

    func saveToFile(_ string: String, fileName: String) {
        guard let baseURL = logDirectoryURL else { return }

        fileQueue.async {
            let url = baseURL.appendingPathComponent(fileName, isDirectory: false)
            let output = string + "\n"

            do {
                if !self.fileManager.fileExists(atPath: url.path) {
                    try output.write(to: url, atomically: true, encoding: .utf8)
                } else {
                    let fileHandle = try self.fileHandle(for: url)
                    fileHandle.seekToEndOfFile()
                    if let data = output.data(using: .utf8) {
                        fileHandle.write(data)
                    }
                }
            } catch {
                print("SimpleFileLogger could not write to file \(url).")
            }
        }
    }

    /// Retrieves an opened FileHandle for the given file URL,
    /// or creates a new one.
    func fileHandle(for url: URL) throws -> Foundation.FileHandle {
        if let opened = fileHandles[url] {
            return opened
        } else {
            let handle = try FileHandle(forWritingTo: url)
            fileHandles[url] = handle
            return handle
        }
    }

}

extension SimpleFileLogger: ServiceType {

    public static var serviceSupports: [Any.Type] {
        return [Logger.self]
    }

    public static func makeService(for worker: Container) throws -> SimpleFileLogger {
        return SimpleFileLogger()
    }

}
