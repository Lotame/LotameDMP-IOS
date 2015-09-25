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
        
        
        try! DMP.getAudienceData{
            profile, err in
            XCTAssertNotNil(profile, "Profile must exist")
            XCTAssertEqual(self.mockProfile["Profile"]!["pid"]!.description, profile?.pid, "Profile object id must match the mock")
            XCTAssertEqual("60519", profile?.audiences[0].id, "First audience object must match the mock")
            XCTAssertEqual("OCR_Matchflow_Segment_37_2", profile?.audiences[0].abbreviation, "First audience object must match the mock")
            XCTAssertEqual(profile?.jsonString!, JSON(self.mockProfile).rawString()!, "Json generation should work correctly")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(120.0, handler: nil)
    }
    
    func testFailGetAudienceWhenUninitialized(){
        do{
            try DMP.getAudienceData{
                profile, err in
            }
        } catch LotameError.InitializeNotCalled{
            //Proper error
            return
        } catch{
            XCTFail("Should send initialization error")
        }
        XCTFail("No errors sent!")
    }
    
    func testFailBehaviorWhenUninitialized(){
        do{
            try DMP.sendBehaviorData()
        } catch LotameError.InitializeNotCalled{
            //Proper error
            return
        } catch{
            XCTFail("Should send initialization error")
        }
        XCTFail("No errors sent!")
    }
    
    func testIgnoreError(){
        _ = try? DMP.sendBehaviorData()
    }
    
}
