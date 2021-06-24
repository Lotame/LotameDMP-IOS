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
    
    let mockProfile: NSDictionary = [
        "Profile": [
            "pid":"ccd93ea4d2b2182cdb480a28c93b83f5",
            "Audiences": [
                "Audience":[
                    ["id":"60519","abbr":"OCR_Matchflow_Segment_37_2"],
                    ["id":"13023","abbr":"usonBusitp"],
                    ["id":"99961","abbr":""]
                ]
            ]
        ]
    ]
    
    func testGetAudienceMock() {
        let expectation = self.expectation(description: "asynchronous request")
        DMP.initialize("99")
        DMP.sharedManager.domain = "testhost.com"
        
        HTTPStubs.stubRequests(passingTest: {
            (request: URLRequest) -> Bool in
            return request.url?.host?.hasSuffix("testhost.com") ?? false
            }, withStubResponse: {
                (request: URLRequest) -> HTTPStubsResponse in
                return HTTPStubsResponse(jsonObject: self.mockProfile, statusCode:200, headers:nil)
        })
        
        
        DMP.getAudienceData{
            result in
            
            XCTAssertNotNil(result.value, "Profile must exist")
            let profileObject = self.mockProfile["Profile"] as! [String: Any]
            let pid = profileObject["pid"] as! String
            XCTAssertEqual(pid, result.value?.pid, "Profile object id must match the mock")
            XCTAssertEqual("60519", result.value?.audiences[0].id, "First audience object must match the mock")
            XCTAssertEqual("OCR_Matchflow_Segment_37_2", result.value?.audiences[0].abbreviation, "First audience object must match the mock")
            XCTAssertEqual(result.value!.jsonString!, self.mockProfile.rawString()!, "Json generation should work correctly")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testGetAudienceFromServer(){
        let expectation = self.expectation(description: "asynchronous request")
        DMP.initialize("205")
        DMP.getAudienceData{
            result in
            XCTAssertNotNil(result.value, "Profile must exist")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testSendDataToServer(){
        let expectation = self.expectation(description: "asynchronous request")
        DMP.initialize("25")
        DMP.addBehaviorData("test", forType: "t")
        DMP.sendBehaviorData{
            result in
            XCTAssertTrue(result.isSuccess, "Sending must not throw errors")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testSendBlankType(){
        let expectation = self.expectation(description: "asynchronous request")
        DMP.initialize("25")
        DMP.addBehaviorData(nil, forType: "")
        DMP.sendBehaviorData{
            result in
            XCTAssertTrue(result.isSuccess, "Sending must not throw errors")
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testFailGetAudienceWhenUninitialized(){
        let expectation = self.expectation(description: "asynchronous request")
        DMP.initialize("")
        
        DMP.getAudienceData{
            result in
            XCTAssertTrue(result.isFailure, "Initialization error should throw")
            XCTAssertEqual(LotameError.initializeNotCalled._code, result.error!._code, "Should send initialization error")
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testFailBehaviorWhenUninitialized(){
        let expectation = self.expectation(description: "asynchronous request")
        DMP.initialize("")
        DMP.sendBehaviorData(){
            result in
            XCTAssertTrue(result.isFailure, "Initialization error should throw")
            XCTAssertEqual(LotameError.initializeNotCalled._code, result.error!._code, "Should send initialization error")
            expectation.fulfill()
            
        }
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testIgnoreError(){
        DMP.sendBehaviorData()
    }
    
    fileprivate static let dispatchQueue = DispatchQueue(label: "com.lotame.testsync", attributes: [])
    func testAsynchronous(){
        
        DMP.initialize("25")
        
        for _ in 1...10{
            let expectationSend = self.expectation(description: "send behavior request")
            let expectationGet = self.expectation(description: "get audience request")
            Tests.dispatchQueue.async {
                DMP.addBehaviorData("test", forType: "t")
                
                DMP.sendBehaviorData{
                    result in
                    XCTAssertTrue(result.isSuccess, "Sending must not throw errors")
                    expectationSend.fulfill()
                }
                
            }
            Tests.dispatchQueue.async{
                
                DMP.getAudienceData {
                    result in
                    XCTAssertNotNil(result.value, "Profile must exist")
                    expectationGet.fulfill()
                }
                
            }
        }
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
}
