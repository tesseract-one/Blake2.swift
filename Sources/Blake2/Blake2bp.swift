//
//  Blake2bp.swift
//  
//
//  Created by Yehor Popovych on 08.05.2021.
//

import Foundation
#if !COCOAPODS
import CBlake2
#endif

struct Blake2bp: Blake2Impl {
    private var state: blake2bp_state
    
    init?(size: Int, key: UnsafeBufferPointer<UInt8>?) {
        state = blake2bp_state()
        let res: Int32
        if let key = key {
            res = blake2bp_init_key(&state, size, key.baseAddress, key.count)
        } else {
            res = blake2bp_init(&state, size)
        }
        guard res == 0 else {
            return nil
        }
    }
    
    mutating func update(from: UnsafeBufferPointer<UInt8>) -> Bool {
        blake2bp_update(&state, from.baseAddress, from.count) == 0
    }
    
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) -> Bool {
        blake2bp_final(&state, out.baseAddress, out.count) == 0
    }
    
    static func hash(
        out: UnsafeMutableBufferPointer<UInt8>,
        bytes: UnsafeBufferPointer<UInt8>,
        key: UnsafeBufferPointer<UInt8>?
    ) -> Bool {
        blake2bp(out.baseAddress, out.count, bytes.baseAddress, bytes.count, key?.baseAddress, key?.count ?? 0) == 0
    }
}
