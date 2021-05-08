//
//  Blake2.swift
//  
//
//  Created by Yehor Popovych on 08.05.2021.
//

import Foundation

protocol Blake2Impl {
    init?(size: Int, key: UnsafeBufferPointer<UInt8>?)
    mutating func update(from: UnsafeBufferPointer<UInt8>) -> Bool
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) -> Bool
    static func hash(
        out: UnsafeMutableBufferPointer<UInt8>,
        bytes: UnsafeBufferPointer<UInt8>,
        key: UnsafeBufferPointer<UInt8>?
    ) -> Bool
}

public struct Blake2 {
    public enum B2Type {
        case b2b
        case b2bp
        case b2s
        case b2sp
        case b2xb
        case b2xs
    }
    
    public enum Error: Swift.Error {
        case initializationError
        case alreadyFinalized
        case finalizationError
        case hashingError
    }
    
    public init(_ type: B2Type, size: Int, key: [UInt8]? = nil) throws {
        let impl: Blake2Impl?
        if let key = key {
            impl = key.withUnsafeBufferPointer { bytes in
                Self.implementation(for: type).init(size: size, key: bytes)
            }
        } else {
            impl = Self.implementation(for: type).init(size: size, key: nil)
        }
        guard let implementation = impl else { throw Error.initializationError }
        self.implementation = implementation
        self.size = size
    }
    
    public mutating func update(_ data: Data) {
        guard size > 0 else { return }
        let _ = data.withUnsafeBytes { bytes in
            self.implementation.update(from: bytes.bindMemory(to: UInt8.self))
        }
    }
    public mutating func update(_ bytes: [UInt8]) {
        guard size > 0 else { return }
        let _ = bytes.withUnsafeBufferPointer { bytes in
            self.implementation.update(from: bytes)
        }
    }
    
    public mutating func finalize() throws -> Data {
        guard size >= 0 else { throw Error.alreadyFinalized }
        var data = Data(repeating: 0, count: size)
        let res = data.withUnsafeMutableBytes { bytes in
            self.implementation.finalize(out: bytes.bindMemory(to: UInt8.self))
        }
        size = -1
        guard res else { throw Error.finalizationError }
        return data
    }
    
    public static func hash(_ type: B2Type, size: Int, data: Data, key: [UInt8]? = nil) throws -> Data {
        let res: Bool
        var out: Data = Data(repeating: 0, count: size)
        if let key = key {
            res = out.withUnsafeMutableBytes { out in
                key.withUnsafeBufferPointer { key in
                    data.withUnsafeBytes { data in
                        implementation(for: type).hash(
                            out: out.bindMemory(to: UInt8.self),
                            bytes: data.bindMemory(to: UInt8.self), key: key
                        )
                    }
                }
            }
        } else {
            res = out.withUnsafeMutableBytes { out in
                data.withUnsafeBytes { data in
                    implementation(for: type).hash(
                        out: out.bindMemory(to: UInt8.self),
                        bytes: data.bindMemory(to: UInt8.self), key: nil
                    )
                }
            }
        }
        guard res else { throw Error.hashingError }
        return out
    }
    
    public static func hash(_ type: B2Type, size: Int, bytes: [UInt8], key: [UInt8]? = nil) throws -> Data {
        let res: Bool
        var out: Data = Data(repeating: 0, count: size)
        if let key = key {
            res = out.withUnsafeMutableBytes { out in
                key.withUnsafeBufferPointer { key in
                    bytes.withUnsafeBufferPointer { bytes in
                        implementation(for: type).hash(
                            out: out.bindMemory(to: UInt8.self),
                            bytes: bytes, key: key
                        )
                    }
                }
            }
        } else {
            res = out.withUnsafeMutableBytes { out in
                bytes.withUnsafeBufferPointer { bytes in
                    implementation(for: type).hash(
                        out: out.bindMemory(to: UInt8.self),
                        bytes: bytes, key: nil
                    )
                }
            }
        }
        guard res else { throw Error.hashingError }
        return out
    }
    
    private var implementation: Blake2Impl
    private var size: Int
    
    private static func implementation(for type: B2Type) -> Blake2Impl.Type {
        switch type {
        case .b2b: return Blake2b.self
        case .b2s: return Blake2s.self
        case .b2bp: return Blake2bp.self
        case .b2sp: return Blake2sp.self
        case .b2xb: return Blake2xb.self
        case .b2xs: return Blake2xs.self
        }
    }
}
