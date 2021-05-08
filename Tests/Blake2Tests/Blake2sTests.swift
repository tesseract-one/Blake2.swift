//
//  Blake2sTests.swift
//  
//
//  Created by Yehor Popovych on 31.03.2021.
//

import XCTest
@testable import Blake2

let BLAKE2S_OUTBYTES = 32
let BLAKE2S_BLOCKBYTES = 64

final class Blake2sTests: XCTestCase {
    func testSimpleApi() {
        for (_in, key, hash) in BLAKE2S_KAT {
            let computed = try? Blake2.hash(.b2s, size: BLAKE2S_OUTBYTES, bytes: _in, key: key)
            XCTAssertEqual(Data(hash), computed)
        }
    }
    
    func testStreamingApi() {
        var buf = [UInt8](repeating: 0, count: BLAKE2S_KAT.count)
        for i in 0..<buf.count {
            buf[i] = UInt8(i)
        }
        for step in 1..<BLAKE2S_BLOCKBYTES {
            for i in 0..<BLAKE2S_KAT.count {
                let (_, key, expected) = BLAKE2S_KAT[i]
                let oBlake2 = try? Blake2(.b2s, size: BLAKE2S_OUTBYTES, key: key)
                XCTAssertNotNil(oBlake2)
                guard var blake2 = oBlake2 else { continue }
                
                var mlen = i, start = 0
                
                while mlen >= step {
                    blake2.update(Array(buf[start..<start+step]))
                    start += step
                    mlen -= step
                }
                blake2.update(Array(buf[start..<start+mlen]))
                let hash = try? blake2.finalize()
                XCTAssertEqual(Data(expected), hash)
            }
        }
    }
}