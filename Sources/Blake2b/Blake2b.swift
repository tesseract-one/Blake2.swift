//
//  Blake2b.swift
//  
//
//  Created by Yehor Popovych on 08.05.2021.
//

import Foundation
#if !COCOAPODS
import CBlake2b
#endif

public struct Blake2b {
    private var state: blake2b_state
    private var size: Int
    
    public init?(size: Int, key: [UInt8]? = nil) {
        self.state = blake2b_state()
        self.size = size
        let res: Int32
        if let key = key {
            res = blake2b_init_key(&state, size, key, key.count)
        } else {
            res = blake2b_init(&state, size)
        }
        guard res == 0 else {
            return nil
        }
    }
    
    public mutating func update(_ data: Data) {
        guard size > 0 else { return }
        data.withUnsafeBytes { bytes in
            let din = bytes.bindMemory(to: UInt8.self)
            blake2b_update(&state, din.baseAddress, din.count)
        }
    }
    
    public mutating func update(_ bytes: [UInt8]) {
        guard size > 0 else { return }
        blake2b_update(&state, bytes, bytes.count)
    }
    
    public mutating func finalize() -> Data? {
        guard size > 0 else { return nil }
        var out = Data(repeating: 0, count: size)
        size = -1
        let result: Int32 = out.withUnsafeMutableBytes { ptr in
            let out = ptr.bindMemory(to: UInt8.self)
            return blake2b_final(&self.state, out.baseAddress, out.count)
        }
        return result == 0 ? out : nil
    }
    
    public static func hash(size: Int, data: Data, key: [UInt8]? = nil) -> Data? {
        var out = Data(repeating: 0, count: size)
        let result: Int32 = out.withUnsafeMutableBytes { ptr in
            data.withUnsafeBytes { dptr in
                let out = ptr.bindMemory(to: UInt8.self)
                let bytes = dptr.bindMemory(to: UInt8.self)
                return blake2b(out.baseAddress, out.count, bytes.baseAddress, bytes.count, key, key?.count ?? 0)
            }
        }
        return result == 0 ? out : nil
    }
    
    public static func hash(size: Int, bytes: [UInt8], key: [UInt8]? = nil) -> Data? {
        var out = Data(repeating: 0, count: size)
        let result: Int32 = out.withUnsafeMutableBytes { ptr in
            let out = ptr.bindMemory(to: UInt8.self)
            return blake2b(out.baseAddress, out.count, bytes, bytes.count, key, key?.count ?? 0)
        }
        return result == 0 ? out : nil
    }
}
