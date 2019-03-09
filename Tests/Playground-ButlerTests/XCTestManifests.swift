import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Playground_ButlerTests.allTests),
    ]
}
#endif