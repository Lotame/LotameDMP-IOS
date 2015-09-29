import UIKit
import XCTest
import LotameDMP
import OHHTTPStubs


class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let mockProfile = ["Profile": ["pid":"ccd93ea4d2b2182cdb480a28c93b83f5","Audiences": ["Audience":[["id":"60519","abbr":"OCR_Matchflow_Segment_37_2"],["id":"13023","abbr":"usonBusitp"],["id":"99961","abbr":""]]]]]
    
    func testGetAudienceMock() {
        let expectation = self.expectationWithDescription("asynchronous request")
        DMP.initialize("99")
        DMP.sharedManager.domain = "testhost.com"
        
        OHHTTPStubs.stubRequestsPassingTest({
            (request: NSURLRequest) -> Bool in
            return request.URL?.host?.hasSuffix("testhost.com") ?? false
            }, withStubResponse: {
                (request: NSURLRequest) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(JSONObject: self.mockProfile, statusCode:200, headers:nil)
        })
        
        
        DMP.getAudienceData{
            result in
            
            XCTAssertNotNil(result.value, "Profile must exist")
            XCTAssertEqual(self.mockProfile["Profile"]!["pid"]!.description, result.value?.pid, "Profile object id must match the mock")
            XCTAssertEqual("60519", result.value?.audiences[0].id, "First audience object must match the mock")
            XCTAssertEqual("OCR_Matchflow_Segment_37_2", result.value?.audiences[0].abbreviation, "First audience object must match the mock")
            XCTAssertEqual(result.value?.jsonString!, JSON(self.mockProfile).rawString()!, "Json generation should work correctly")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testGetAudienceFromServer(){
        let expectation = self.expectationWithDescription("asynchronous request")
        DMP.initialize("205")
        DMP.getAudienceData{
            result in
            XCTAssertNotNil(result.value, "Profile must exist")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testSendDataToServer(){
        let expectation = self.expectationWithDescription("asynchronous request")
        DMP.initialize("25")
        DMP.addBehaviorData("test", forType: "t")
        DMP.sendBehaviorData{
            result in
            XCTAssertTrue(result.isSuccess, "Sending must not throw errors")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testSendBlankType(){
        let expectation = self.expectationWithDescription("asynchronous request")
        DMP.initialize("25")
        DMP.addBehaviorData(nil, forType: "")
        DMP.sendBehaviorData{
            result in
            XCTAssertTrue(result.isSuccess, "Sending must not throw errors")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testFailGetAudienceWhenUninitialized(){
        let expectation = self.expectationWithDescription("asynchronous request")
        DMP.initialize("")
        
        DMP.getAudienceData{
            result in
            XCTAssertTrue(result.isFailure, "Initialization error should throw")
            XCTAssertEqual(LotameError.InitializeNotCalled._code, result.error!._code, "Should send initialization error")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testFailBehaviorWhenUninitialized(){
        let expectation = self.expectationWithDescription("asynchronous request")
        DMP.initialize("")
        DMP.sendBehaviorData(){
            result in
            XCTAssertTrue(result.isFailure, "Initialization error should throw")
            XCTAssertEqual(LotameError.InitializeNotCalled._code, result.error!._code, "Should send initialization error")
            expectation.fulfill()
            
        }
        
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testIgnoreError(){
        DMP.sendBehaviorData()
    }
    
    private static let dispatchQueue = dispatch_queue_create("com.lotame.testsync", nil)
    func testAsynchronous(){
        
        DMP.initialize("25")
        
        for _ in 1...10{
            let expectationSend = self.expectationWithDescription("send behavior request")
            let expectationGet = self.expectationWithDescription("get audience request")
            dispatch_async(Tests.dispatchQueue) {
                DMP.addBehaviorData("test", forType: "t")
                
                DMP.sendBehaviorData{
                    result in
                    XCTAssertTrue(result.isSuccess, "Sending must not throw errors")
                    expectationSend.fulfill()
                }
                
            }
            dispatch_async(Tests.dispatchQueue){
                
                DMP.getAudienceData {
                    result in
                    XCTAssertNotNil(result.value, "Profile must exist")
                    expectationGet.fulfill()
                }
                
            }
        }
        
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
}
