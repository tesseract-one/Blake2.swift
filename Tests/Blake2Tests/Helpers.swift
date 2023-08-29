//
//  Helpers.swift
//  
//
//  Created by Yehor Popovych on 29/08/2023.
//

import Foundation


struct Blake2Test: Decodable {
    public let hash: String
    public let `in`: Data
    public let key: Data
    public let out: Data
}

extension JSONDecoder.DataDecodingStrategy {
    static let hex: Self = .custom { decoder in
        var container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let data = string.data(using: .ascii), data.count % 2 == 0 else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Not a hex value: " + string)
            )
        }
        let prefix = string.hasPrefix("0x") ? 2 : 0
        let parsed: Data = try data.withUnsafeBytes() { hex in
            var result = Data()
            result.reserveCapacity((hex.count - prefix) / 2)
            var current: UInt8? = nil
            for indx in prefix ..< hex.count {
                let v: UInt8
                switch hex[indx] {
                case let c where c <= 57: v = c - 48
                case let c where c >= 65 && c <= 70: v = c - 55
                case let c where c >= 97: v = c - 87
                default:
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Not a hex value: " + string)
                    )
                }
                if let val = current {
                    result.append(val << 4 | v)
                    current = nil
                } else {
                    current = v
                }
            }
            return result
        }
        return parsed
    }
}

extension Array where Element == Blake2Test {
    var blake2b: Self { filter { $0.hash == "blake2b" } }
    var blake2s: Self { filter { $0.hash == "blake2s" } }
    var blake2bp: Self { filter { $0.hash == "blake2bp" } }
    var blake2sp: Self { filter { $0.hash == "blake2sp" } }
    var blake2xb: Self { filter { $0.hash == "blake2xb" } }
    var blake2xs: Self { filter { $0.hash == "blake2xs" } }
    
    var unkeyed: Self { filter { $0.key.count == 0 } }
    var keyed: Self { filter { $0.key.count > 0 } }
}

class Resources {
    private var blake2kat: [Blake2Test]? = nil
    
    func fileUrl(name: String) -> URL {
        // Bundle.url(forResource:) should be used for both
        // but it crashes on Linux (CoreFoundation memory management bug)
        // so we have this workaround
        #if os(Linux) || os(Windows)
        return Bundle.module.bundleURL.appendingPathComponent(name)
        #else
        return Bundle.module.url(forResource: name,
                                 withExtension: nil,
                                 subdirectory: nil)!
        #endif
    }
    
    func blake2tests() -> [Blake2Test] {
        guard let b2k = blake2kat else {
            let data = try! Data(contentsOf: fileUrl(name: "blake2-kat.json"))
            let decoder = JSONDecoder()
            decoder.dataDecodingStrategy = .hex
            blake2kat = try! decoder.decode([Blake2Test].self, from: data)
            return blake2kat!
        }
        return b2k
    }
    
    static let inst = Resources()
}

#if !SWIFT_PACKAGE
extension Foundation.Bundle {
    // Load xctest bundle
    static var module = Bundle(for: Resources.self)
}
#endif

