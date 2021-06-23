//
//  LotameProfile.swift
//
// Created by Dan Rusk
// The MIT License (MIT)
//
// Copyright (c) 2021 Lotame
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

@objc
open class LotameProfile: NSObject{
    public let pid:String
    public let panoramaId:String
    @objc open var audiences: [LotameAudience] = []
    
    @objc open var jsonString:String? {
        return json.rawString()
    }
    
    /** 
     
     {
        "Profile" : {
            "panoramaId": "acdefghijklmnopqrstuvwxyz1234567890"
            "pid" : "ccd93ea4d2b2182cdb480a28c93b83f5"
        }
     }
     
     // or with audiences:
     
     {
        "panoramaId": "acdefghijklmnopqrstuvwxyz1234567890"
        "pid" : "M518E7D21-89E6-4A57-919E-B4FAF3CFFB87",
        "Audiences" : {
            "Audience" : [
                {
                    "id" : "141",
                    "abbr" : "all"
                }
            ]
        }
     }
     
     */
    open var json: NSDictionary {
        return [
            "Profile": [
                "panoramaId": panoramaId,
                "pid": pid,
                "Audiences": [
                    "Audience": audiences.map{["id":$0.id, "abbr": $0.abbreviation]}
                ]
            ],
        ]
    }
    
    override init(){
        //Blank for obj-c calls
        pid = ""
        panoramaId = ""
    }
    
    /** Sample payload
     
     {
        "Profile" : {
            "Audiences" : {
                "Audience" : [
                    {
                        "id" : "141",
                        "abbr" : "all"
                    }
                ]
            },
            "panoramaId": "acdefghijklmnopqrstuvwxyz1234567890"
            "pid" : "M518E7D21-89E6-4A57-919E-B4FAF3CFFB87",
            "tpid" : "cc1f57b175293b739496e9d58c6a7ba9"
        }
     }
     
     */
    init(json: NSDictionary){
        // If there's no Profile property, there's no use continuing.
        guard let profile = json["Profile"] as? [String: Any] else {
            // pid must be initialized
            pid = ""
            panoramaId = ""
            return
        }
        // Extract the pid
        pid = profile["pid"] as? String ?? ""
        panoramaId = profile["panoramaId"] as? String ?? ""
        guard let audiencesObject = profile["Audiences"] as? [String: Any],
            let audiencesArray = audiencesObject["Audience"] as? [NSDictionary] else { return }
        let audienceArrayParsed = audiencesArray.map { audienceDictionary in
            return LotameAudience(json: audienceDictionary)
        }
        audiences += audienceArrayParsed
    }
}


