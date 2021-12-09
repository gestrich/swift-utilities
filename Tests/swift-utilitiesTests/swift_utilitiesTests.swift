import XCTest
@testable import swift_utilities

final class swift_utilitiesTests: XCTestCase {
    
    
    //MARK: String parsing tests
    
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
    
    
    //MARK: Prompt Tests: These require interaction so disabled
    
    func testPromptForSelection() {
//        let res = promptForSelection(title: "Test", displayOneBasedIndex: false, options: ["First", "Second"])
//        print(res)
    }
    
    func testPromptForText(){
//        let res = promptForText(title: "Provide Input ", defaultText: nil)
//        print(res)
    }
    
    func testPromptForYesNo(){
//        let res = promptForYesNo(question: "What do you want to do?")
//        print(res)
    }
}
