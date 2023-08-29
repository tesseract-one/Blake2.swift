//
//  Blake2bpTests.swift
//  
//
//  Created by Yehor Popovych on 31.03.2021.
//

import XCTest
@testable import Blake2

final class Blake2bpTests: XCTestCase {
    let tests = Resources.inst.blake2tests().blake2bp
    
    func testSimpleApi() {
        for test in tests {
            let computed = try? Blake2bp.hash(size: BLAKE2B_OUTBYTES,
                                              data: test.in, key: test.key)
            XCTAssertEqual(test.out, computed)
        }
    }
    
    func testStreamingApi() {
        let tests = self.tests.keyed
        var buf = [UInt8](repeating: 0, count: tests.count)
        for i in 0..<buf.count {
            buf[i] = UInt8(i)
        }
        for step in 1..<BLAKE2B_BLOCKBYTES {
            for i in 0..<tests.count {
                let test = tests[i]
                let oBlake2 = try? Blake2bp(size: BLAKE2B_OUTBYTES, key: test.key)
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
                XCTAssertEqual(test.out, hash)
            }
        }
    }
}
