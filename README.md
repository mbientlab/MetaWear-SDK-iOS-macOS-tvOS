# MetaWear  SDK for iOS/macOS/tvOS/watchOS by MBIENTLAB

[![Platforms](https://img.shields.io/cocoapods/p/MetaWear.svg?style=flat)](http://cocoapods.org/pods/MetaWear)
[![License](https://img.shields.io/cocoapods/l/MetaWear.svg?style=flat)](https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/blob/master/LICENSE.md)
[![Version](https://img.shields.io/cocoapods/v/MetaWear.svg?style=flat)](http://cocoapods.org/pods/MetaWear)

![alt tag](https://raw.githubusercontent.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/master/Images/Metawear.png)

SDK for creating MetaWear apps that run in the Apple ecosystem.  

This is a thin wrapper around the [MetaWear C++ API](https://github.com/mbientlab/MetaWear-SDK-Cpp) so you will find the C++ [documentation](https://mbientlab.com/cppdocs/latest/) and [API reference](https://mbientlab.com/docs/metawear/cpp/latest/globals.html) useful.

Also, check out the starter [App](https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/tree/master/StarterProject) and the very through example App [App](https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/tree/master/ExampleApp) for sample code.

### Overview

[MetaWear](https://mbientlab.com) is a complete development and production platform for wearable and connected device applications.

MetaWear features a number of sensors and peripherals all easily controllable over Bluetooth 4.0/5.0 Low Energy using this SDK, no firmware or hardware experience needed!

The MetaWear hardware comes pre-loaded with a wirelessly upgradeable firmware, so it keeps getting more powerful over time.

### Requirements
- [MetaWear board](https://mbientlab.com/store/)
- [Apple ID](https://appleid.apple.com/), you can now get started for free!  Once you are ready to submit an App to the App Store, you need a paid [Apple Developer Account](https://developer.apple.com/programs/ios/).
- Device running iOS 10.0 or later with Bluetooth 4.0/5.0 (iOS 13+, XCODE12+, BLE5.0 recommended)

> REQUIREMENT NOTES  
The iOS simulator doesn’t support Bluetooth 4.0/5.0, so test apps must be run on a real iOS device which requires a developer account.  Bluetooth 4.0 available on iPhone 4S+, iPad 3rd generation+, or iPod Touch 5th generation.

*BLUETOOTH IS NOT SUPPORTED IN THE SIMULATOR*

### License
See the [License](https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/blob/master/LICENSE.md)

### Support
Reach out to the [community](https://mbientlab.com/community/) if you encounter any problems, or just want to chat :)

## Getting Started

### Pre-Installation

#### Xcode
You need to be profficient with [Xcode](https://developer.apple.com/xcode/) development to use these APIs.

#### Swift
Our APIs are written and supported in [Swift](https://developer.apple.com/swift/).

#### CocoaPods
[CocoaPods](https://cocoapods.org/) is a dependency manager for Swift and Objective-C Cocoa projects. It has over 79 thousand libraries and is used in over 3 million apps. CocoaPods can help you scale your projects elegantly.

CocoaPods is built with Ruby and is installable with the default Ruby available on macOS. We recommend you use the default ruby.

Using the default Ruby install can require you to use sudo when installing gems. Further installation instructions are in the guides.

```sh
sudo gem install cocoapods
```
### Installation
[MetaWear](https://cocoapods.org/pods/MetaWear) is available through CocoaPods. To install it, simply add the following line to your Podfile:

Then list the dependencies in a text file named Podfile in your Xcode project directory:

```ruby
platform :ios, '8.0'
use_frameworks!
target 'MyApp' do
    // LOCAL
    pod "MetaWear", :subspecs => ['UI', 'AsyncUtils', 'Mocks', 'DFU']
    // COCOA POD
    pod "MetaWear"
    // COCOA POD RELEASE SPECIFIC
    pod "MetaWear", '~> '4.0.1'
end
```
Tip: CocoaPods provides a pod init command to create a Podfile with smart defaults. You should use it.

Now you can install the dependencies in your project:

```sh
pod install
```

It might be good to update:

```sh
pod update
```

Make sure to always open the Xcode workspace instead of the project file when building your project:

```sh
open App.xcworkspace
```
Now you can import your dependencies e.g.:

```sh
#import MetaWear
```

### Usage
Require the metawear package

```swift
import MetaWear
import MetaWearCpp
```

Call Swift APIs:
```swift
device.flashLED(color: .green, intensity: 1.0)
```

Or direct CPP SDK calls:
```swift
var pattern = MblMwLedPattern(high_intensity: 31,
                              low_intensity: 31,
                              rise_time_ms: 0,
                              high_time_ms: 2000,
                              fall_time_ms: 0,
                              pulse_duration_ms: 2000,
                              delay_time_ms: 0,
                              repeat_count: 0xFF)
mbl_mw_led_stop_and_clear(device.board)
mbl_mw_led_write_pattern(device.board, &pattern, color)
mbl_mw_led_play(device.board)
```
Or a mix of both as you can see in the example below.

### Example

Here is a walkthrough to showcase a very basic connect and toggle LED operation.
```swift
MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
    // We found a MetaWear board, see if it is close
    if device.rssi.intValue > -50 {
        // Hooray! We found a MetaWear board, so stop scanning for more
        MetaWearScanner.shared.stopScan()
        // Connect to the board we found
        device.connectAndSetup().continueWith { t in
            if let error = t.error {
                // Sorry we couldn't connect
                print(error)
            } else {
                // Hooray! We connected to a MetaWear board, so flash its LED!
                var pattern = MblMwLedPattern()
                mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_PULSE)
                mbl_mw_led_stop_and_clear(device.board)
                mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_GREEN)
                mbl_mw_led_play(device.board)
            }
        }
    }
}
```

### Tutorials
Tutorials can be found [here](https://mbientlab.com/tutorials/).
