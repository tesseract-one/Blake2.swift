import XCTest

import Blake2bTests

var tests = [XCTestCaseEntry]()
tests += Blake2bTests.__allTests()

XCTMain(tests)
