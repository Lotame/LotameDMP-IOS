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

pod 'LotameDMP', '~> 4.1'
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

### Carthage

Carthage is a dependency manager alternative to CocoaPods.

Youc can install Carthage using Homebrew:

```
$ brew update
$ brew install carthage
```

Create a file named `Cartfile`, and add the following text:

```
github "Lotame/LotameDMP-IOS" ~> 4.1
```

Run `carthage update`. 

This generates the following file:

```
./Carthage/Build/iOS/LotameDMP.framework
```

To install:

1. Open Xcode and go to **Target** > **General** > **Embedded Binaries**
1. Drag the `LotameDMP.framework` into the **Embedded Binaries** section. 
1. When prompted, check the box for **Copy items if needed**. 


### Drag-and-drop installation

Within this repository, navigate to the `dist` folder. You should see the following contents:

```
./dist/tag-4.1.0-swift-3.1-framework.zip
```

Download and unzip this file. You should see a folder containing the `LotameDMP.framework`. 

To install:

1. Open Xcode and go to **Target** > **General** > **Embedded Binaries**
1. Drag the `LotameDMP.framework` into the **Embedded Binaries** section. 
1. When prompted, check the box for **Copy items if needed**. 

**Note**: In order for drag-and-drop to work, you must be using the same version of Swift as the pre-compiled framework. The distribution folder contents are labeled with the tag and Swift version, so you know the code state and Swift compatability, respectively. If you're using a different version of Swift, you have a few options:

1. Use CocoaPods
1. Use Carthage
1. Download the repo, and run the `./build_framework.sh` script. This generates a framework zip file in the `dist` folder.

## Usage

LotameDMP must be imported by any file using the library.

```swift
import LotameDMP
```

or for Objective-C

```objective-c
#import "LotameDMP-Swift.h"
```

### Initialization

LotameDMP is a singleton that must be initialized with a client id once before using it.  Run the following command before executing any other calls:

```swift
DMP.initialize("YOUR_CLIENT_ID_NUMBER")
```

or for Objective-C

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

or for Objective-C

```objective-c
[DMP addBehaviorData:@"value" forType: @"type"];
[DMP addBehaviorDataWithBehaviorId: 1];
[DMP addBehaviorDataWithOpportunityId: 1];
```

It must be sent to the server to record the behaviors:

```swift
DMP.sendBehaviorData()
```

or for Objective-C

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

or for Objective-C

```objective-c
[DMP sendBehaviorDataWithHandler: ^(NSError * _Nullable error){
    if (error != nil){
        //Failure
    } else {
        //Success
    }
}];
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

or for Objective-C

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

or for Objective-C

```objective-c
[DMP startNewSession];
```

## About this version

Version 4.1.0 removes dependencies on AlamoFire and SwiftyJSON. It also generates a .Framework file for drag-and-drop installation.

Version 4.0.0 updates the code to Swift 3, since Xcode 8.3.2 dropped support for Swift 2.3.

The previous version of Lotame `3.0.1` had a dependency on Alamofire `2.0`. This dependency has been updated to Alamofire `4.4`. If your project leveraged Alamofire, please see their migration guide for updating your network calls.

Note to code maintainers: when changing the version, make sure to update these 3 locations:

1. `LotameDMP.podspec`
1. Git tag
1. `sdkVersion` in `DMP.swift`

## Note to maintainers

When a new version of Swift is released, run the `./build_framework.sh` script. This will generate a new zip file in the `dist` folder, labeled with the current git tag and Swift version of your local Mac. Push the generated zip file to the repo.

## License

LotameDMP is available under the MIT license. See the LICENSE file for more info.

