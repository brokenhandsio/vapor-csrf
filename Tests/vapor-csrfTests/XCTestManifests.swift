import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(vapor_csrfTests.allTests),
    ]
}
#endif
