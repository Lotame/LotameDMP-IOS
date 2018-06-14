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

// Requires Result enum from AlamoFire for backward compatibility
public enum Result<Value> {
    case success(Value)
    case failure(Error)
    
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    public var isFailure: Bool {
        return !isSuccess
    }
    
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

/**
    The Lotame Data Management Platform
*/
@objc
open class DMP:NSObject{
    /**
    LotameDMP is a singleton.  Calls should be made to the class functions, which
    will use this sharedManager as an object.
    */
    open static let sharedManager = DMP()
    
    fileprivate static let sdkVersion = "4.1.0"
    
    /**
    Thread safety (especially for behavior data0 is handled via async and sync thread calls.
    All network calls are made asynchronously.
    */
    fileprivate static let dispatchQueue = DispatchQueue(label: "com.lotame.sync", attributes: [])
    
    /**
    Gets the IDFA or nil if it is not enabled.
    */
    open static var advertisingId: String?{
        if trackingEnabled{
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }else{
            return nil
        }
    }
    
    /**
    Structure for the behavior tracking data
    */
    fileprivate struct Behavior{
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
    fileprivate var behaviors:[Behavior] = []
    
    /**
    Tracking is enabled only if advertising id is enabled on the user's device
    */
    open static var trackingEnabled: Bool{
        return ASIdentifierManager.shared().isAdvertisingTrackingEnabled
    }
    
    /**
    The id registered with Lotame
    */
    fileprivate var clientId: String?{
        didSet{
            DMP.startNewSession()
        }
    }
    
    fileprivate var isInitialized:Bool{
        return clientId != nil && !clientId!.isEmpty
    }
    
    fileprivate static let defaultDomain = "crwdcntrl.net"
    fileprivate static let defaultProtocol = "https"
    
    /**
    The domain of the base urls for the network calls. Defaults to crwdcntrl.net
    */
    open var domain: String = DMP.defaultDomain{
        didSet{
            DMP.startNewSession()
        }
    }
    
    /**
    The protocol to use for the network calls. Defaults to https.
    Changing to http will require special settings in Info.plist to disable
    ATS.
    */
    open var httpProtocol: String = DMP.defaultProtocol{
        didSet{
            DMP.startNewSession()
        }
    }
    
    fileprivate var baseBCPUrl: String{
        return "\(httpProtocol)://bcp.\(domain.urlHostEncoded()!)/5/c=\(clientId!.urlPathEncoded()!)/mid=\(DMP.advertisingId!.urlPathEncoded()!)/e=app/dt=IDFA/sdk=\(DMP.sdkVersion)/"
    }
    
    fileprivate var baseADUrl: String{
        return "\(httpProtocol)://ad.\(domain.urlHostEncoded()!)/5/pe=y/c=\(clientId!.urlPathEncoded()!)/mid=\(DMP.advertisingId!.urlPathEncoded()!)/dt=IDFA/sdk=\(DMP.sdkVersion)/"
    }
    
    /**
    Will mark the data as a new page view
    */
    fileprivate var isNewSession = true
    
    /**
    The DMP is a singleton, use the initialize method to set the values in the singleton
    */
    fileprivate override init(){
        
    }
    
    /**
    Call this first to initialize the singleton. Only needs to be called once.
    Starts a new session, sets the domain to default "crwdcntrl.net" and httpProtocol to default "https"
    **/
    @objc open class func initialize(_ clientId: String){
        DMP.sharedManager.clientId = clientId
        DMP.sharedManager.domain = defaultDomain
        DMP.sharedManager.httpProtocol = defaultProtocol
        DMP.startNewSession()
    }
    
    /**
    Starts a new page view session
    */
    open class func startNewSession(){
        dispatchQueue.sync{
            sharedManager.isNewSession = true
        }
    }
    
    /**
     Used by objective-c code that does not support generics. Do not use in swift. Use sendBehaviorData instead
     */
    @objc open class func sendBehaviorDataWithHandler(_ handler:@escaping (_ error: NSError?)->Void) {
        sendBehaviorData{ result in
            handler(result.error as NSError?)
        }
    }
    
    /**
    Sends the collected behavior data to the Lotame server. Returns errors
    to the completion handler.
    **Note:** Does not collect data if the user has limited ad tracking turned on, but still clears behaviors.
    */
    open class func sendBehaviorData(_ completion:@escaping (_ result: Result<Data>) -> Void){
        
        dispatchQueue.async{
            guard sharedManager.isInitialized else{
                DispatchQueue.main.async{
                    completion(Result<Data>.failure(LotameError.initializeNotCalled))
                }
                return
            }
            guard DMP.trackingEnabled else{
                sharedManager.behaviors.removeAll()
                //Don't send tracking data if it user has opted out
                DispatchQueue.main.async{
                    completion(Result<Data>.failure(LotameError.trackingDisabled))
                }
                return
            }
            //Add random number for cache busting
            sharedManager.behaviors.insert(Behavior(value: arc4random_uniform(999999999).description, forKey: "rand"), at: 0)
            if sharedManager.isNewSession{
                //Add page view for new sessions
                sharedManager.behaviors.insert(Behavior(value: "y", forKey: "pv"), at: 1)
                sharedManager.isNewSession = false
            }
            
            for (index, behavior) in sharedManager.behaviors.enumerated(){
                if behavior.key == opportunityParamKey{
                    //Insert 1 'count placements' behavior if there is at least 1 opportunity
                    sharedManager.behaviors.insert(Behavior(value:"y", forKey: "dp"), at: index + 1)
                    break
                }
            }
            
            let behaviorCopy = sharedManager.behaviors
            
            guard var url = Foundation.URL(string: sharedManager.baseBCPUrl) else {
                completion(Result<Data>.failure(LotameError.invalidURL))
                return
            }
            
            // url is in the format of:
            // /5/pe=y/c=25/mid=12345-abcd/dt=IDFA/sdk=4.0.0/foo=bar/
            for behavior in behaviorCopy {
                if let behaviorValue = behavior.value {
                    url = url.appendingPathComponent("\(behavior.key)=\(behaviorValue)/");
                }
            }
            let urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 60)
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                DispatchQueue.main.async{
                    if error == nil {
                        completion(Result<Data>.success(Data()))
                    }else{
                        completion(Result<Data>.failure(LotameError.unexpectedResponse))
                    }
                }
            }.resume()
            
            sharedManager.behaviors.removeAll()
        }
    }
    
    /**
    Sends the collected behavior data to the Lotame server without a completion handler
    */
    open class func sendBehaviorData(){
        sendBehaviorData(){
            err in
            //Could log the message here
        }
    }
    
    /**
    Collects behavior data with any type and value
    */
    open class func addBehaviorData(_ value: String?, forType key: String){
        if !key.isEmpty{
            dispatchQueue.async{
                if DMP.trackingEnabled{
                    sharedManager.behaviors.append(Behavior(value: value, forKey: key))
                }
            }
        }
    }
    
    /**
    Collects a specific behavior id
    */
    open class func addBehaviorData(behaviorId: Int64){
        addBehaviorData(behaviorId.description, forType:"b")
    }
    
    fileprivate static let opportunityParamKey = "p"
    /**
    Collects a specific opportunity id
    */
    open class func addBehaviorData(opportunityId: Int64){
        addBehaviorData(opportunityId.description, forType:opportunityParamKey)
    }
    
    /**
    Used by objective-c code that does not support generics. Do not use in swift. Use getAudienceData instead
    */
    @objc open class func getAudienceDataWithHandler(_ handler:@escaping (_ profile: LotameProfile?, _ success: Bool)->Void) {
        getAudienceData{ result in
            if let resultValue = result.value, result.isSuccess {
                handler(resultValue, true)
            }else{
                handler(nil, false)
            }
        }
    }
    
    /**
    Gets the audience data via a completion handler.  The data parameter will be nil
    if there is an error.  The error will be specified in the error parameter if it is
    available.  This call is asynchronous and will not occur on the main thread. 
    In the completion handler, make sure to make any updates on the UI in main thread.
    
    **Note:** Does not get results if the user has limited ad tracking turned on
    */
    open class func getAudienceData(_ completion:@escaping (_ result: Result<LotameProfile>)->Void) {
        guard sharedManager.isInitialized else{
            DispatchQueue.main.async{
                completion(Result<LotameProfile>.failure(LotameError.initializeNotCalled))
            }
            return
        }
        guard DMP.trackingEnabled else{
            //Don't get audience data if it user has opted out
            DispatchQueue.main.async{
                completion(Result<LotameProfile>.failure(LotameError.trackingDisabled))
            }
            return
        }
        dispatchQueue.async{
            guard let baseURL = URL(string: sharedManager.baseADUrl) else {
                completion(Result<LotameProfile>.failure(LotameError.invalidURL))
                return
            }
            let req = URLRequest(url: baseURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 60)
            
            URLSession.shared.dataTask(with: req) { data, response, error in
                DispatchQueue.main.async{
                    if let data = data,
                        let responseJSON = (try? JSONSerialization.jsonObject(with: data, options: [])) as? NSDictionary {
                        completion(Result<LotameProfile>.success(LotameProfile(json: responseJSON)))
                    } else {
                        completion(Result<LotameProfile>.failure(LotameError.unexpectedResponse))
                    }
                }
            }.resume()
        }
    }

    /**
    Send an HTTP or HTTPs request using the supplied URL pattern.
    This pattern can contain two replacement macros, {deviceid} and {deviceidtype},
    which will be replaced before performing the HTTP(s) call.
    */
    
    open class func sendRequest(urlPattern:String,_ completion:@escaping (_ result: Result<LotameProfile>)->Void) {
        
        dispatchQueue.async{
            
            guard sharedManager.isInitialized else{
                DispatchQueue.main.async{
                    completion(Result<LotameProfile>.failure(LotameError.initializeNotCalled))
                }
                return
            }
            
            guard DMP.trackingEnabled else{
                DispatchQueue.main.async{
                    completion(Result<LotameProfile>.failure(LotameError.trackingDisabled))
                }
                return
            }

            guard let mid = DMP.advertisingId?.urlPathEncoded(), !mid.isEmpty  else {
                DispatchQueue.main.async{
                    completion(Result<LotameProfile>.failure(LotameError.invalidID))
                }
                return
            }
            
            var newStringPattern = urlPattern.replacingOccurrences(of:"{deviceid}",with: mid)
            newStringPattern = newStringPattern.replacingOccurrences(of:"{deviceidtype}",with:"IDFA")
            
            guard let newUrlPattern = URL(string: newStringPattern) else {
                completion(Result<LotameProfile>.failure(LotameError.invalidURL))
                return
            }
            
            let req = URLRequest(url: newUrlPattern, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 60)
            
            URLSession.shared.dataTask(with: req).resume()
        }
    }
    
}

//MARK - Extension to add encoding for String
extension String {
    func urlPathEncoded() -> String?{
        let characterSet = NSMutableCharacterSet(charactersIn: "!*'\"();:@&=+$,/?#[]% ").inverted
        return addingPercentEncoding(withAllowedCharacters: characterSet)
    }
    
    func urlHostEncoded() -> String?{
        return addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)
    }
}
