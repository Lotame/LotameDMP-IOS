# LotameDMP-IOS
This open source library can be leveraged by Lotame clients to collect data from within their iOS applications.

[![Version](https://img.shields.io/cocoapods/v/LotameDMP.svg?style=flat)](http://cocoapods.org/pods/LotameDMP)
[![License](https://img.shields.io/cocoapods/l/LotameDMP.svg?style=flat)](http://cocoapods.org/pods/LotameDMP)
[![Platform](https://img.shields.io/cocoapods/p/LotameDMP.svg?style=flat)](http://cocoapods.org/pods/LotameDMP)

## Requirements

LotameDMP requires Xcode 8 and at least iOS 8.0.  It will work with Swift or Objective-C.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8 or OS X Sierra (10.12).**

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 1.2.1 is required to build LotameDMP. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate LotameDMP into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'LotameDMP', '~> 4.0'
```

Then, run the following command:

```bash
$ pod install
```

Add the following elements to your project's Info.plist file to configure ATS:

```xml
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>crwdcntrl.net</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSExceptionRequiresForwardSecrecy</key>
                <false/>
            </dict>
        </dict>
    </dict>
```

## Usage

LotameDMP must be imported by any file using the library.

```swift
import LotameDMP
```

or for objective-c

```objective-c
#import "LotameDMP-Swift.h"
```

### Initialization

LotameDMP is a singleton that must be initialized with a client id once before using it.  Run the following command before executing any other calls:

```swift
DMP.initialize("YOUR_CLIENT_ID_NUMBER")
```

or for objective-c

```objective-c
[DMP initialize:@"YOUR_CLIENT_ID_NUMBER_"];
```

The initialize call starts a new session and sets the domain and protocols to their default values (https://*.crwdcntrl.net)

### Send Behaviors

Behavior Data is collected through one of the add commands:

```swift
DMP.addBehaviorData("value", forType: "type")
DMP.addBehaviorData(behaviorId: 1)
DMP.addBehaviorData(opportunityId: 1)
```

or for objective-c

```objective-c
[DMP addBehaviorData:@"value" forType: @"type"];
[DMP addBehaviorDataWithBehaviorId: 1];
[DMP addBehaviorDataWithOpportunityId: 1];
```

It must be sent to the server to record the behaviors:

```swift
DMP.sendBehaviorData()
```

or for objective-c

```objective-c
[DMP sendBehaviorData];
```

If you're interested in the success or failure of sending the data, use a completion handler:

```swift
DMP.sendBehaviorData(){
	result in
	if result.isSuccess{
		//Success
	} else{
		//Failure
	}
}
```

### Get Audience Data

Get the audience data with the following command:

```swift
DMP.getAudienceData{
	result in
	if let profile = result.value{
		//Successful request, use LotameProfile object
	} else {
		//result.error will contain an error object
	}
}
```

or for objective-c

```objective-c
[DMP getAudienceDataWithHandler:^(LotameProfile * _Nullable profile, BOOL success) {
        if (success) { //Check for success
            //Successful request, use LotameProfile object
        }
}];
```

The completion handler uses a Result enum to indicate success or failure.

### Start a New Session

To indicate that a new session has started, use the following command:

```swift
DMP.startNewSession()
```

or for objective-c

```objective-c
[DMP startNewSession];
```

## About this version

Version 4.0.0 updates the code to Swift 3, since Xcode 8.3.2 dropped support for Swift 2.3.

The previous version of Lotame `3.0.1` had a dependency on Alamofire `2.0`. This dependency has been updated to Alamofire `4.4`. If your project leveraged Alamofire, please see their migration guide for updating your network calls.

Note to code maintainers: when changing the version, make sure to update these 3 locations:

1. `LotameDMP.podspec`
1. Git tag
1. `sdkVersion` in `DMP.swift`

## License

LotameDMP is available under the MIT license. See the LICENSE file for more info.

