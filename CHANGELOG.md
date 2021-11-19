# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [4.1.3] - 2021-11-19
### Update
- Update CPP lib 

## [4.1.2] - 2021-11-18
### Update
- Update CPP lib 

## [4.1.1] - 2021-11-16
### Update
- Update CPP lib 
- Add more tests 

## [4.1.0] - 2021-11-03
### Update and Error Fix
- Update iOSDUFLibrary 
- Remove Mocks 
- Update CPP lib (fix odr bug)
- Add more Tests
- Lower required versions 

## [4.0.2] - 2021-08-05
### Update
- Update iOSDUFLibrary pod for Swift 5.5 CBPeripheral API change 

## [4.0.1] - 2021-06-15
### Update
- General update and cleanup (no major changes)

## [4.0.0] - 2021-03-22
### Update
- Update pods and new CPP SDK 0.20.0
- Update tests
- Update for MMS
- Update some helper functions (processors)

## [3.4.3] - 2021-01-04
### Update
- Update pods and new CPP SDK 0.19.1

## [3.4.2] - 2020-02-12
### Fixed
- Pull request from user to add debug statement and make bleQueue public 

## [3.4.1] - 2020-02-11
### Fixed
- Issue between repo and cocoapods 

## [3.4.0] - 2019-09-28
### Changed
- Updated Bolts-Swift
- Updated iOSDFULibrary 
- iOS13 support 
- iOS13 default ios build settings for StarterProject + Bluetooth requirements 

## [3.3.0] - 2019-05-03
### Changed
- MetaWear-SDK-Cpp v0.18.4.
- Swift 5

### Fixed
- Macro programming could drop commands if more than 16 were issued in rapid succession

## [3.2.0] - 2019-02-12
### Changed
- MetaWear-SDK-Cpp v0.18.0.
- Restart scanning if BLE state toggles off then on

### Fixed
Removed MBL_MW_ prefix from constants to fix duplicate symbol errors.

## [3.1.11] - 2018-12-12
### Changed
- Updated iOSDFULibrary to 4.2.2

## [3.1.10] - 2018-12-05
### Added
- Mock gyro and sensor fusion

### Changed
- Switching Projects to original build system for Xcode 10 (workaround for CocoaPod issue)
- MetaWear-SDK-Cpp v0.17.0

### Fixed
- macOS StarterProject

### Added
- Mock magnetometer

## [3.1.9] - 2018-09-13
### Changed
- Changing MetaWearScanner.shared to a non-restorable type.  It requires exta steps, so people should have to opt in by using MetaWearScanner.sharedRestore instead 

### Fixed
- Threading issues when accessing advertisement data (name, rssi, and averageRssi)

## [3.1.8] - 2018-08-24
### Added
- Support for MblMwBoschAnyMotion and MblMwCalibrationState data types

### Changed
- MetaWear-SDK-Cpp v0.16.3

## [3.1.7] - 2018-08-12
### Added
- MetaWear.readRSSI - get RSSI value after connection
- More mocked modules with spoof'd MetaWear's

### Fixed
- MetaBoot status not updated if scanning wasn't used

## [3.1.6] - 2018-07-31
### Added
- MetaWearScanner.retrieveConnectedMetaWearsAsync function

### Changed
- Save CBPeripheral's retrieved in willRestoreState

## [3.1.5] - 2018-07-27
### Added
- Bluetooth State Restoration on MetaWearScanner.shared

### Changed
- CPP submodule accessed with https instead of git protocol

## [3.1.4] - 2018-07-23
### Changed
- Updated Podspec with the swift-version key and latest Bolts-Swift 1.4.0
- MetaWear-SDK-Cpp v0.16.0

## [3.1.3] - 2018-07-16
### Added
- Documentation for basic features of this API.
- Scripts to generate API reference docs.
- DFU subspec for handing firmware updates.  New cases where bootloader change is required.

### Changed
- Update Cpp API to [v0.14.0](https://github.com/mbientlab/MetaWear-SDK-Cpp/releases/tag/0.14.0).
- connectAndSetup will read device info if in MetaBoot mode.

### Fixed
- connectAndSetup could sometimes hang, canSendWriteWithoutResponse only valid after a first write.
- UI helpers didn't always invoke delegate methods on Main Thread.

