# Blake2.swift

![🐧 linux: ready](https://img.shields.io/badge/%F0%9F%90%A7%20linux-ready-red.svg)
[![GitHub license](https://img.shields.io/badge/license-Apache%202.0-lightgrey.svg)](LICENSE)
[![Build Status](https://github.com/tesseract-one/Blake2.swift/workflows/Build%20&%20Tests/badge.svg?branch=main)](https://github.com/tesseract-one/Blake2.swift/actions/workflows/build.yml?query=branch%3Amain)
[![GitHub release](https://img.shields.io/github/release/tesseract-one/Blake2.swift.svg)](https://github.com/tesseract-one/Blake2.swift/releases)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods version](https://img.shields.io/cocoapods/v/Blake2.svg)](https://cocoapods.org/pods/Blake2)
![Platform macOS | iOS | tvOS | watchOS | Linux](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-orange.svg)

Swift wrapper for [reference C implementation](https://github.com/BLAKE2/BLAKE2) of [BLAKE2](https://en.wikipedia.org/wiki/BLAKE_(hash_function)#BLAKE2) hash functions.

## Installation

Blake2 deploys to macOS, iOS, tvOS, watchOS and Linux. It has been tested on the latest OS releases only however, as the module uses very few platform-provided APIs, there should be very few issues with earlier versions.

Setup instructions:

- **Swift Package Manager:**
  Add this to the dependency section of your `Package.swift` manifest:

    ```Swift
    .package(url: "https://github.com/tesseract-one/Blake2.swift.git", from: "0.1.0")
    ```

- **CocoaPods:** Put this in your `Podfile`:

    ```Ruby
    pod 'Blake2', '~> 0.1'
    ```

## Usage Examples

```Swift
import Blake2

let data = Data("some data for hashing".utf8)

// Simple hash api. 64 byte Blake2b hash.
let hash = try! Blake2.hash(.b2b, size: 64, data: data)
print("Hash", hash)

// Streaming hash api. 64 byte Blake2b hash.
// Create hasher object
var hasher = try! Blake2(.b2b, size: 64)
// insert data by chunks
hasher.update(data)
// and then finalize hasher
let hash2 = try! hasher.finalize()
print("Hash", hash2)
```

## License

Blake2.swift can be used, distributed and modified under [the Apache 2.0 license](LICENSE).
