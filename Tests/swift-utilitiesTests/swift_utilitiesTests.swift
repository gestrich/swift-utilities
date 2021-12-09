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
        XCTAssertEqual("test-string".getPartBefore(toSearch: "nonhit"), "")
        XCTAssertEqual("test-test-string".getPartBefore(toSearch: "test"), "")
        XCTAssertEqual("string-string-test-test".getPartBefore(toSearch: "test"), "string-string-")
        XCTAssertEqual("".getPartBefore(toSearch: "test"), "")
    }
    
    func testGetPartBeforeAndIncluding() {
        XCTAssertEqual("test-string".getPartBeforeAndIncluding(toSearch: "-string"), "test-string")
        XCTAssertEqual("test-string".getPartBeforeAndIncluding(toSearch: "nonhit"), "")
        XCTAssertEqual("test-test-string".getPartBeforeAndIncluding(toSearch: "test"), "test")
        XCTAssertEqual("string-string-test-test".getPartBeforeAndIncluding(toSearch: "test"), "string-string-test")
        XCTAssertEqual("".getPartBeforeAndIncluding(toSearch: "test"), "")
    }
    
    func testGetPartAfter() {
        XCTAssertEqual("test-string".getPartAfter(toSearch: "test"), "-string")
        XCTAssertEqual("test-string".getPartAfter(toSearch: "nonhit"), "")
        XCTAssertEqual("test-test-string".getPartAfter(toSearch: "test"), "-test-string")
        XCTAssertEqual("".getPartAfter(toSearch: "test"), "")
    }
    
    func testGetPartAfterandIncluding() {
        XCTAssertEqual("test-string".getPartAfterAndIncluding(toSearch: "test"), "test-string")
        XCTAssertEqual("test-string".getPartAfterAndIncluding(toSearch: "nonhit"), "")
        XCTAssertEqual("test-test-string".getPartAfterAndIncluding(toSearch: "test"), "test-test-string")
        XCTAssertEqual("".getPartAfterAndIncluding(toSearch: "test"), "")
    }

    static var allTests = [
        ("testFileUtils", testFileUtils),
    ]
}
