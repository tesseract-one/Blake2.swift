//
//  Blake2bpTests.swift
//  
//
//  Created by Yehor Popovych on 31.03.2021.
//

import XCTest
@testable import Blake2

final class Blake2bpTests: XCTestCase {
    func testSimpleApi() {
        for (_in, key, hash) in BLAKE2BP_KAT {
            let computed = try? Blake2.hash(.b2bp, size: BLAKE2B_OUTBYTES, bytes: _in, key: key)
            XCTAssertEqual(Data(hash), computed)
        }
    }
    
    func testStreamingApi() {
        var buf = [UInt8](repeating: 0, count: BLAKE2BP_KAT.count)
        for i in 0..<buf.count {
            buf[i] = UInt8(i)
        }
        for step in 1..<BLAKE2B_BLOCKBYTES {
            for i in 0..<BLAKE2BP_KAT.count {
                let (_, key, expected) = BLAKE2BP_KAT[i]
                let oBlake2 = try? Blake2(.b2bp, size: BLAKE2B_OUTBYTES, key: key)
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
