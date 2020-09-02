import XCTest

import vapor_csrfTests

var tests = [XCTestCaseEntry]()
tests += vapor_csrfTests.allTests()
XCTMain(tests)
