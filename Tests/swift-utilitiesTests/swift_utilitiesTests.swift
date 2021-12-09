import XCTest
@testable import swift_utilities

final class swift_utilitiesTests: XCTestCase {
    func testFileUtils() {
        let matches = filenamesMatching(pattern:"Screen.*", directory:"/Users/bill/Desktop")
        for match in matches {
            print(match)
        }
    }
    
    func testGetPartBefore() {
        XCTAssertEqual("test-string".getPartBefore(toSearch: "-string"), "test")
        XCTAssertEqual("test-string".getPartAfter(toSearch: "nonhit"), "")
        XCTAssertEqual("test-test-string".getPartBefore(toSearch: "test"), "")
        XCTAssertEqual("string-string-test-test".getPartBefore(toSearch: "test"), "string-string-")
        XCTAssertEqual("".getPartBefore(toSearch: "test"), "")
    }
    
    func testGetPartAfter() {
        XCTAssertEqual("test-string".getPartAfter(toSearch: "test"), "-string")
        XCTAssertEqual("test-string".getPartAfter(toSearch: "nonhit"), "")
        XCTAssertEqual("test-test-string".getPartAfter(toSearch: "test"), "-test-string")
        XCTAssertEqual("".getPartAfter(toSearch: "test"), "")
    }

    static var allTests = [
        ("testFileUtils", testFileUtils),
    ]
}
