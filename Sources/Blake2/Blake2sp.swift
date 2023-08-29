//
//  Blake2sp.swift
//  
//
//  Created by Yehor Popovych on 08.05.2021.
//

import Foundation
#if !COCOAPODS
import CBlake2
#endif

public struct Blake2sp: Blake2Hash {
    public let size: Int
    private var state: blake2sp_state
    
    public init?(size: Int, key: UnsafeRawBufferPointer?) {
        self.size = size
        self.state = blake2sp_state()
        let res: Int32
        if let key = key {
            res = blake2sp_init_key(&state, size, key.baseAddress, key.count)
        } else {
            res = blake2sp_init(&state, size)
        }
        guard res == 0 else {
            return nil
        }
    }
    
    public mutating func update(from: UnsafeRawBufferPointer) -> Bool {
        blake2sp_update(&state, from.baseAddress, from.count) == 0
    }
    
    public mutating func finalize(out: UnsafeMutableRawBufferPointer) -> Bool {
        blake2sp_final(&state, out.baseAddress, out.count) == 0
    }
    
    public static func hash(
        out: UnsafeMutableRawBufferPointer,
        bytes: UnsafeRawBufferPointer,
        key: UnsafeRawBufferPointer?
    ) -> Bool {
        blake2sp(out.baseAddress, out.count, bytes.baseAddress, bytes.count,
                 key?.baseAddress, key?.count ?? 0) == 0
    }
}
