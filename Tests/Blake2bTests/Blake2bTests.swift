//
//  VrfTests.swift
//  
//
//  Created by Yehor Popovych on 31.03.2021.
//

import XCTest
@testable import Blake2b

let BLAKE2B_BLOCKBYTES = 128

final class Blake2bTests: XCTestCase {
    func testSimpleApi() {
        for (_in, key, hash) in BLAKE2B_KAT {
            let computed = Blake2b.hash(size: 64, bytes: _in, key: key)
            XCTAssertEqual(Data(hash), computed)
        }
    }
    
    func testStreamingApi() {
        var buf = [UInt8](repeating: 0, count: BLAKE2B_KAT.count)
        for i in 0..<buf.count {
            buf[i] = UInt8(i)
        }
        for step in 1..<BLAKE2B_BLOCKBYTES {
            for i in 0..<BLAKE2B_KAT.count {
                let (_, key, expected) = BLAKE2B_KAT[i]
                let blake2 = Blake2b(size: 64, key: key)
                XCTAssertNotNil(blake2)
                guard var blake2 = blake2 else { continue }
                
                var mlen = i, start = 0
                
                while mlen >= step {
                    blake2.update(Array(buf[start..<start+step]))
                    start += step
                    mlen -= step
                }
                blake2.update(Array(buf[start..<start+mlen]))
                let hash = blake2.finalize()
                XCTAssertEqual(Data(expected), hash)
            }
        }
    }
}


