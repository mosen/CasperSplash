import XCTest

class JAMFLogTests: XCTestCase {

    var log: JAMFLog?
    
    override func setUp() {
        super.setUp()
        
        self.log = JAMFLog(path: "/var/log/jamf.log")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        self.log = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReadAsync() {
        if self.log == nil {
            XCTFail("JAMFLog object could not be constructed")
        }
        
        let expectation = self.expectation(description: "Waiting for JAMF Log to be read")
        
        self.log?.read()
        
        self.waitForExpectations(timeout: 3) { (err) in
            print("Expectation Finished")
        }
    }

}
