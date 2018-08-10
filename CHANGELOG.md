# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- MetaWear.readRSSI - get RSSI value after connection

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

