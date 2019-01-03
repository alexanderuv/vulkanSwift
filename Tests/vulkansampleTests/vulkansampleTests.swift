import XCTest
@testable import vulkansample

final class vulkansampleTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(vulkansample().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
