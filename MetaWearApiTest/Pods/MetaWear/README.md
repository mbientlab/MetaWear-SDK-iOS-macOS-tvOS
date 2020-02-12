# MetaWear  SDK for iOS/macOS/tvOS/watchOS by MBIENTLAB

[![Platforms](https://img.shields.io/cocoapods/p/MetaWear.svg?style=flat)](http://cocoapods.org/pods/MetaWear)
[![License](https://img.shields.io/cocoapods/l/MetaWear.svg?style=flat)](https://mbientlab.com/license)
[![Version](https://img.shields.io/cocoapods/v/MetaWear.svg?style=flat)](http://cocoapods.org/pods/MetaWear)

![alt tag](https://raw.githubusercontent.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/master/Images/Metawear.png)

SDK for creating MetaWear apps that run in the Apple ecosystem.  This is a thin wrapper around the [MetaWear C++ API](https://github.com/mbientlab/MetaWear-SDK-Cpp) so you will find the C++ [documentation](https://mbientlab.com/cppdocs/latest/) and [API reference](https://mbientlab.com/docs/metawear/cpp/latest/globals.html) useful.

### Overview

[MetaWear](https://mbientlab.com) is a complete development and production platform for wearable and connected device applications.

MetaWear features a number of sensors and peripherals all easily controllable over Bluetooth 4.0 Low Energy using this SDK, no firmware or hardware experience needed!

The MetaWear hardware comes pre-loaded with a wirelessly upgradeable firmware, so it keeps getting more powerful over time.

### Requirements
- [MetaWear board](https://mbientlab.com/store/)
- [Apple ID](https://appleid.apple.com/), you can now get started for free!  Once you are ready to submit an App to the App Store, you need a paid [Apple Developer Account](https://developer.apple.com/programs/ios/).
- Device running iOS 10.0 or later with Bluetooth 4.0

> REQUIREMENT NOTES  
The iOS simulator doesn’t support Bluetooth 4.0, so test apps must be run on a real iOS device which requires a developer account.  Bluetooth 4.0 available on iPhone 4S+, iPad 3rd generation+, or iPod Touch 5th generation.

### License
See the [License](https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/blob/master/LICENSE)

### Support
Reach out to the [community](https://mbientlab.com/community/) if you encounter any problems, or just want to chat :)

## Getting Started

### Installation

MetaWear is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MetaWear", :subspecs => ['UI', 'AsyncUtils', 'Mocks', 'DFU']
```

For first time CocoaPods users we have a detailed [video guide](https://youtu.be/VTb_EDv5j7A).

### Simple API Test

Here is a walkthrough to showcase a very basic connect and toggle LED operation.

First, import the framework header files like this:
```swift
import MetaWear
import MetaWearCpp
```

Then add the following code wherever appropriate to make the LED flash green:
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
Now run the app! 

*BLUETOOTH IS NOT SUPPORTED IN THE SIMULATOR*


