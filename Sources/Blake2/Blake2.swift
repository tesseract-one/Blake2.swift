//
//  Blake2.swift
//  
//
//  Created by Yehor Popovych on 08.05.2021.
//

import Foundation

public enum Blake2Error: Swift.Error {
    case initializationError
    case finalizationError
    case hashingError
}

public protocol Blake2Hash {
    var size: Int { get }
    init?(size: Int, key: UnsafeRawBufferPointer?)
    mutating func update(from: UnsafeRawBufferPointer) -> Bool
    mutating func finalize(out: UnsafeMutableRawBufferPointer) -> Bool
    static func hash(
        out: UnsafeMutableRawBufferPointer,
        bytes: UnsafeRawBufferPointer,
        key: UnsafeRawBufferPointer?
    ) -> Bool
}

public extension Blake2Hash {
    @inlinable init(size: Int) throws {
        try self.init(size: size, key: nil as Data?)
    }
    
    @inlinable init<K: DataPtrRepresentable>(size: Int, key: K?) throws {
        let impl = key.withPtr { Self(size: size, key: $0) }
        guard let hasher = impl else { throw Blake2Error.initializationError }
        self = hasher
    }
    
    @inlinable mutating func update<D: DataPtrRepresentable>(_ data: D) {
        guard size > 0 else { return }
        let _ = data.withPtr { self.update(from: $0) }
    }
    
    @inlinable mutating func finalize() throws -> Data {
        var data = Data(repeating: 0, count: size)
        let res = data.withMutPtr { self.finalize(out: $0) }
        guard res else { throw Blake2Error.finalizationError }
        return data
    }
    
    @inlinable static func hash<D: DataPtrRepresentable>(
        size: Int, data: D
    ) throws -> Data {
        try hash(size: size, data: data, key: nil as Data?)
    }
    
    @inlinable static func hash<D, K>(size: Int, data: D, key: K?) throws -> Data
        where D: DataPtrRepresentable, K: DataPtrRepresentable
    {
        var out: Data = Data(repeating: 0, count: size)
        let res = out.mutJoin2(data, key) { out, data, key in
            hash(out: out, bytes: data, key: key)
        }
        guard res else { throw Blake2Error.hashingError }
        return out
    }
}
