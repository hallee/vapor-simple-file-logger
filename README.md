<p align="center">
    <a href="https://vapor.codes">
        <img src="Logo.svg" width="361" height="64" alt="Simple File Logger Logo">
    </a>
    <br>
    <br>
    <a href="https://vapor.codes">
        <img src="http://img.shields.io/badge/vapor-3.0-brightgreen.svg" alt="Vapor 3">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
</p>

## Overview

A simple [Vapor](https://vapor.codes) `Logger` provider for outputting server logs to log files.

Simple File Logger outputs separate files based on the log's `LogLevel`. Debug logs are output to `debug.log`, error logs to `error.log`, and so on. By default, logs are output to:

| Linux | macOS |
| ----- | ----- |
| `/var/log/Vapor/` | `~/Library/Caches/Vapor/` |

You can change `Vapor/` to an arbitrary directory by changing the `executableName` during setup.

## Installation

Add this dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/hallee/vapor-simple-file-logger.git", from: "1.0.1"),
],
```

And add `"SimpleFileLogger"` as a dependency to your app's target.

## Setup

In `configure.swift`:

```swift
services.register(SimpleFileLogger.self)
config.prefer(SimpleFileLogger.self, for: Logger.self)
```

To define an executable name and include timestamps, you can provide configuration:

```swift
services.register(Logger.self) { container -> SimpleFileLogger in
    return SimpleFileLogger(executableName: "hal.codes", 
                            includeTimestamps: true)
}
config.prefer(SimpleFileLogger.self, for: Logger.self)
```

## Usage

You can create a logger anywhere in your Vapor application with access to its `Container` with:

```swift
Container.make(Logger.self)
```

For example, to log all the requests to your server:

```swift
router.get(PathComponent.catchall) { req in
    let logger = try? req.sharedContainer.make(Logger.self)
    logger?.debug(req.description)
}
```