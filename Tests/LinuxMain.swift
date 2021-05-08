import XCTest

import Blake2Tests

var tests = [XCTestCaseEntry]()
tests += Blake2Tests.__allTests()

XCTMain(tests)
