import XCTest
@testable import swift_utilities

final class swift_utilitiesTests: XCTestCase {
    func testFileUtils() {
        let matches = filenamesMatching(pattern:"Screen.*", directory:"/Users/bill/Desktop")
        for match in matches {
            print(match)
        }
    }

    static var allTests = [
        ("testFileUtils", testFileUtils),
    ]
}
