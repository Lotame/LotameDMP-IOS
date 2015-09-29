# LotameDMP

[![Version](https://img.shields.io/cocoapods/v/LotameDMP.svg?style=flat)](http://cocoapods.org/pods/LotameDMP)
[![License](https://img.shields.io/cocoapods/l/LotameDMP.svg?style=flat)](http://cocoapods.org/pods/LotameDMP)
[![Platform](https://img.shields.io/cocoapods/p/LotameDMP.svg?style=flat)](http://cocoapods.org/pods/LotameDMP)

## Requirements

LotameDMP requires Xcode 7 and swift 2.0.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8 or OS X Mavericks (10.9).**

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.38.2 is required to build LotameDMP. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate LotameDMP into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'LotameDMP', '~> 3.0'
```

Then, run the following command:

```bash
$ pod install
```

LotameDMP is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LotameDMP"
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

### Initialization

LotameDMP is a singleton that must be intiialized with a client id once before using it.  Run the following command before executing any other calls:

```swift
DMP.initialize("YOUR_CLIENT_ID_NUMBER")
```

The initialize call starts a new session and sets the domain and protocols to their default values (https://*.crwdcntrl.net)

### Send Behaviors

Behavior Data is collected through one of the add commands:

```swift
DMP.addBehaviorData("value", forType: "type")
DMP.addBehaviorData(behaviorId: 1)
DMP.addBehaviorData(opportunityId: 1)
```

It must be sent to the server to record the behaviors:

```swift
DMP.sendBehaviorData()
```

### Get Audience Data

Get the audience data with the following command:

```
DMP.getAudienceData{
	result in
	if let profile = result.value{
		//Successful request, use LotameProfile object
	} else {
		//result.error will contain an error object
	}
}
```

The completion handler uses a Result enum to indicate success or failure.

## Author

Dan Rusk, djrusk@gmail.com

## License

LotameDMP is available under the MIT license. See the LICENSE file for more info.
