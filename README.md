# MetaWear SDK for iOS/OS X/tvOS by MBIENTLAB

[![Platforms](https://img.shields.io/cocoapods/p/MetaWear.svg?style=flat)](http://cocoapods.org/pods/MetaWear)
[![License](https://img.shields.io/cocoapods/l/MetaWear.svg?style=flat)](https://mbientlab.com/license)
[![Version](https://img.shields.io/cocoapods/v/MetaWear.svg?style=flat)](http://cocoapods.org/pods/MetaWear)

[![Build Status](https://jenkins.schiffli.us/buildStatus/icon?job=MetaWear-SDK-iOS-macOS-tvOS)](https://jenkins.schiffli.us/job/MetaWear-SDK-iOS-macOS-tvOS)
[![Codecov](https://img.shields.io/codecov/c/github/mbientlab/MetaWear-SDK-iOS-macOS-tvOS.svg?maxAge=2592000)](https://codecov.io/github/mbientlab/MetaWear-SDK-iOS-macOS-tvOS?branch=master)

![alt tag](https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/blob/master/Images/Metawear.png)

### Overview

[MetaWear](https://mbientlab.com) is a complete development and production platform for wearable and connected device applications.

MetaWear features a number of sensors and peripherals all easily controllable over Bluetooth 4.0 Low Energy using this SDK, no firmware or hardware experience needed!

The MetaWear hardware comes pre-loaded with a wirelessly upgradeable firmware, so it keeps getting more powerful over time.

### Requirements
- [MetaWear board](https://mbientlab.com/store/)
- [Apple ID](https://appleid.apple.com/), you can now get started for free!  Once you are ready to submit an App to the App Store, you need a paid [Apple Developer Account](https://developer.apple.com/programs/ios/).
- Device running iOS 8.0 or later with Bluetooth 4.0

> REQUIREMENT NOTES  
The iOS simulator doesn’t support Bluetooth 4.0, so test apps must be run on a real iOS device which requires a developer account.  Bluetooth 4.0 available on iPhone 4S+, iPad 3rd generation+, or iPod Touch 5th generation.

### License
See the [License](https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/blob/master/LICENSE)

### Support
Reach out to the [community](http://community.mbientlab.com) if you encounter any problems, or just want to chat :)

## Getting Started

### Installation

MetaWear is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MetaWear"
```
For first time CocoaPods users we have a detailed [video guide](https://youtu.be/VTb_EDv5j7A).

### Simple API Test

Here is a walkthrough to showcase a very basic connect and toggle LED operation.

First, import the framework header files like this:
```swift
import MetaWear
```

Then add the following code wherever appropriate to make the LED flash green:
```swift
MBLMetaWearManager.shared().startScanForMetaWears() { array in
    // Hooray! We found a MetaWear board, so stop scanning for more
    MBLMetaWearManager.shared().stopScan()
    // Connect to the board we found
    if let device = array.first {
        device.connectAsync().success() { _ in
            // Hooray! We connected to a MetaWear board, so flash its LED!
            device.led?.flashColorAsync(UIColor.green, withIntensity: 0.5)
        }.failure() { error in
            // Sorry we couldn't connect
            print(error)
        }
    }
}
```
Now run the app! 

*BLUETOOTH IS NOT SUPPORTED IN THE SIMULATOR* but we do include a simulated MetaWear for use with basic testing, however, it does not have all the features of a real MetaWear.

### Sample iOS App

We have a sample iOS App on the [App Store](https://itunes.apple.com/us/app/metawear/id920878581) and the source can be found on our [GitHub Page](https://github.com/mbientlab/Metawear-SampleiOSApp).

The sample iOS App demonstrates the base functionality of the various MetaWear modules and serves as a good starting point for developers.

### API Documentation

See the [iOS Guide](https://mbientlab.com/iosdocs/latest/)
