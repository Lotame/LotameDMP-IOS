//
//  LotameDMP.swift
//
// Created by Dan Rusk
// The MIT License (MIT)
//
// Copyright (c) 2015 Lotame
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation
import AdSupport
import Alamofire

/**
    The Lotame Data Management Platform
*/
public class DMP{
    /**
    LotameDMP is a singleton.  Calls should be made to the class functions, which
    will use this sharedManager as an object.
    */
    public static let sharedManager = DMP()
    
    /**
    Thread safety (especially for behavior data0 is handled via async and sync thread calls.
    All network calls are made asynchronously.
    */
    private static let dispatchQueue = dispatch_queue_create("com.lotame.sync", nil)
    
    /**
    Gets the IDFA or nil if it is not enabled.
    */
    public static var advertisingId: String?{
        if ASIdentifierManager.sharedManager().advertisingTrackingEnabled{
            return ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
        }else{
            return nil
        }
    }
    
    /**
    Structure for the behavior tracking data
    */
    private struct Behavior{
        var key: String
        var value: String?
        init(value: String?, forKey: String){
            self.key = forKey
            self.value = value
        }
    }
    
    /**
    The accumulated behavior tracking data. This is reset after each sendBehaviorData call.
    */
    private var behaviors:[Behavior] = []
    
    /**
    Tracking is enabled only if advertising id is enabled on the user's device
    */
    public static var trackingEnabled: Bool{
        return DMP.advertisingId != nil
    }
    
    /**
    The id registered with Lotame
    */
    private var clientId: String?{
        didSet{
            DMP.startNewSession()
        }
    }
    
    private var isInitialized:Bool{
        return clientId != nil && !clientId!.isEmpty
    }
    
    /**
    The domain of the base urls for the network calls. Defaults to crwdcntrl.net
    */
    public var domain: String = "crwdcntrl.net"{
        didSet{
            DMP.startNewSession()
        }
    }
    
    /**
    The protocol to use for the network calls. Defaults to https
    */
    public var httpProtocol: String = "https"{
        didSet{
            DMP.startNewSession()
        }
    }
    
    private var baseBCPUrl: String{
        return "\(httpProtocol)://bcp.\(domain.urlHostEncoded()!)/5/c=\(clientId!.urlPathEncoded()!)/mid=\(DMP.advertisingId!.urlPathEncoded()!)/e=app/dt=IDFA/sdk=3.0/"
    }
    
    private var baseADUrl: String{
        return "\(httpProtocol)://ad.\(domain.urlHostEncoded()!)/5/pe=y/c=\(clientId!.urlPathEncoded()!)/mid=\(DMP.advertisingId!.urlPathEncoded()!)/"
    }
    
    /**
    Will mark the data as a new page view
    */
    private var isNewSession = true
    
    /**
    The DMP is a singleton, use the initialize method to set the values in the singleton
    */
    private init(){
        
    }
    
    /**
    Call this first to initialize the singleton. Only needs to be called once.
    **/
    public class func initialize(clientId: String){
        DMP.sharedManager.clientId = clientId
        DMP.startNewSession()
    }
    
    /**
    Starts a new page view session
    */
    class func startNewSession(){
        dispatch_sync(dispatchQueue){
            sharedManager.isNewSession = true
            if let clientId = DMP.sharedManager.clientId where !clientId.isEmpty{
                if DMP.trackingEnabled && DMP.sharedManager.clientId != nil{
                    Router.baseBCPString = DMP.sharedManager.baseBCPUrl
                    Router.baseADString = DMP.sharedManager.baseADUrl
                }
            }
        }
    }
    
    /**
    Sends the collected behavior data to the Lotame server. Returns errors
    to the completion handler.
    **Note:** Does not collect data if the user has limited ad tracking turned on, but still clears behaviors.
    */
    public class func sendBehaviorData(completion:(error: ErrorType?) -> Void) throws{
        guard sharedManager.isInitialized else{
            throw LotameError.InitializeNotCalled
        }
        dispatch_async(dispatchQueue){
            if !DMP.trackingEnabled{
                sharedManager.behaviors.removeAll()
                //Don't send tracking data if it user has opted out
                completion(error: LotameError.TrackingDisabled)
                return
            }
            //Add random number for cache busting
            sharedManager.behaviors.insert(Behavior(value: arc4random_uniform(999999999).description, forKey: "rand"), atIndex: 0)
            if sharedManager.isNewSession{
                //Add page view for new sessions
                sharedManager.behaviors.insert(Behavior(value: "y", forKey: "pv"), atIndex: 1)
                sharedManager.isNewSession = false
            }
            
            for (index, behavior) in sharedManager.behaviors.enumerate(){
                if behavior.key == opportunityParamKey{
                    //Insert 1 'count placements' behavior if there is at least 1 opportunity
                    sharedManager.behaviors.insert(Behavior(value:"y", forKey: "dp"), atIndex: index + 1)
                    break
                }
            }
            
            let behaviorCopy = sharedManager.behaviors
            Alamofire.request(Router.SendBehaviorData(params: behaviorCopy))
                .validate().response{
                    _, _, _, err in
                    completion(error:err)
                }
            sharedManager.behaviors.removeAll()
        }
    }
    
    /**
    Sends the collected behavior data to the Lotame server without a completion handler
    */
    public class func sendBehaviorData() throws{
        try sendBehaviorData(){
            err in
            //Could log the message here
        }
    }
    
    /**
    Collects behavior data with any type and value
    */
    public class func addBehaviorData(value: String?, forType key: String){
        dispatch_async(dispatchQueue){
            if DMP.trackingEnabled{
                sharedManager.behaviors.append(Behavior(value: value, forKey: key))
            }
        }
    }
    
    /**
    Collects a specific behavior id
    */
    public class func addBehaviorData(behaviorId behaviorId: Int64){
        addBehaviorData(behaviorId.description, forType:"b")
    }
    
    private static let opportunityParamKey = "p"
    /**
    Collects a specific opportunity id
    */
    public class func addBehaviorData(opportunityId opportunityId: Int64){
        addBehaviorData(opportunityId.description, forType:opportunityParamKey)
    }
    
    /**
    Gets the audience data via a completion handler.  The data parameter will be nil
    if there is an error.  The error will be specified in the error parameter if it is
    available.  This call is asynchronous and will not occur on the main thread. 
    In the completion handler, make sure to make any updates on the UI in main thread.
    
    **Note:** Does not get results if the user has limited ad tracking turned on
    */
    public class func getAudienceData(completion:(data:LotameProfile?, error: ErrorType?)->Void) throws {
        guard sharedManager.isInitialized else{
            throw LotameError.InitializeNotCalled
        }
        if !DMP.trackingEnabled{
            //Don't get audience data if it user has opted out
            completion(data: nil, error: LotameError.TrackingDisabled)
            return
        }
        dispatch_async(dispatchQueue){
            Alamofire.request(Router.AudienceData(params: nil))
                .validate()
                .responseJSON(options: .AllowFragments){
                    req, res, result in
                    if let value = result.value where res?.statusCode == 200 && result.isSuccess{
                        completion(data:LotameProfile(json: JSON(value)), error: nil)
                    }
                    else{
                        completion(data: nil, error: result.error)
                    }
            }
        }
    }
    
    /**
    Handles building the URLs for each of the requests
    */
    private enum Router: URLRequestConvertible{
        static var baseBCPString = ""
        static var baseADString = ""
        
        case SendBehaviorData(params: [Behavior]?)
        case AudienceData(params: [Behavior]?)
        
        var URLRequest: NSMutableURLRequest{
            
            var behaviors:[Behavior]?
            var URL: NSURL?
            switch self{
            case .AudienceData(let params):
                URL = NSURL(string: Router.baseBCPString)
                behaviors = params
            case .SendBehaviorData(let params):
                URL = NSURL(string: Router.baseADString)
                behaviors = params
            }
            
            //convert behaviors to params
            var params: [String: AnyObject] = [:]
            if let behaviors = behaviors{
                for behavior in behaviors{
                    params[behavior.key] = behavior.value ?? ""
                }
            }
            
            let mutableURLRequest = NSMutableURLRequest(URL: URL!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 60)
            return Alamofire.ParameterEncoding.Custom(Router.paramCustomURLPathEncode).encode(mutableURLRequest, parameters: params).0
        }
        
        /**
        Appends the parameters as paths to the url
        */
        private static let paramCustomURLPathEncode: (convertible: URLRequestConvertible, params: [String:AnyObject]?) -> (NSMutableURLRequest, NSError?) = {
            (convertible, params) -> (NSMutableURLRequest, NSError?) in
            //Append the params to the URL as paths
            var mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
            var urlString = mutableRequest.URLString
            
            if let params = params{
                for (key, val) in params{
                    if let valString = val as? String where !valString.isEmpty {
                        urlString += "\(key.urlPathEncoded())=\(valString.urlPathEncoded())/"
                    }else{
                        urlString += "\(key.urlPathEncoded())/"
                    }
                }
            }
            
            mutableRequest.URL = NSURL(string: urlString)
            
            return (mutableRequest, nil)
        }
        
    }
    
}

//MARK - Extension to add encoding for String
extension String {
    func urlPathEncoded() -> String?{
        let characterSet = NSMutableCharacterSet(charactersInString: "!*'\"();:@&=+$,/?#[]% ").invertedSet
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
    
    func urlHostEncoded() -> String?{
        return stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    }
}
