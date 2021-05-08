//
//  Blake2xsTests.swift
//  
//
//  Created by Yehor Popovych on 31.03.2021.
//

import XCTest
@testable import Blake2

final class Blake2xsTests: XCTestCase {
    /* Testing length of outputs rather than inputs */
    /* (Test of input lengths mostly covered by blake2s tests) */
    
    func testSimpleApi() {
        for (_in, key, hash) in BLAKE2XS_KAT {
            let computed = try? Blake2.hash(.b2xs, size: hash.count, bytes: _in, key: key)
            XCTAssertEqual(Data(hash), computed)
        }
    }
    
    func testStreamingApi() {
        var buf = [UInt8](repeating: 0, count: 256)
        for i in 0..<buf.count {
            buf[i] = UInt8(i)
        }
        for step in 1..<BLAKE2S_BLOCKBYTES {
            for outlen in 1...256 {
                let (_, key, expected) = BLAKE2XS_KAT[outlen - 1]
                let oBlake2 = try? Blake2(.b2xs, size: outlen, key: key)
                XCTAssertNotNil(oBlake2)
                guard var blake2 = oBlake2 else { continue }
                
                var mlen = 256, start = 0
                
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
