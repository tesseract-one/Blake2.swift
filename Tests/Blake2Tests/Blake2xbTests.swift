//
//  Blake2xbTests.swift
//  
//
//  Created by Yehor Popovych on 31.03.2021.
//

import XCTest
@testable import Blake2

final class Blake2xbTests: XCTestCase {
    let tests = Resources.inst.blake2tests().blake2xb
    
    /* Testing length of outputs rather than inputs */
    /* (Test of input lengths mostly covered by blake2s tests) */
    
    func testSimpleApi() {
        for test in tests {
            let computed = try? Blake2xb.hash(size: test.out.count,
                                              data: test.in, key: test.key)
            XCTAssertEqual(test.out, computed)
        }
    }
    
    func testStreamingApi() {
        let tests = self.tests.keyed
        var buf = [UInt8](repeating: 0, count: 256)
        for i in 0..<buf.count {
            buf[i] = UInt8(i)
        }
        for step in 1..<BLAKE2B_BLOCKBYTES {
            for outlen in 1...256 {
                let test = tests[outlen - 1]
                let oBlake2 = try? Blake2xb(size: outlen, key: test.key)
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
                XCTAssertEqual(test.out, hash)
            }
        }
    }
}
