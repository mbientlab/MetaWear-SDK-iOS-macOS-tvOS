/**
 * MetaWear+Firmware.swift
 * MetaWear-Swift
 *
 * Created by Stephen Schiffli on 1/9/18.
 * Copyright 2018 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab via email: hello@mbientlab.com
 */

import CoreBluetooth
import MetaWearCpp
import BoltsSwift
import iOSDFULibrary


private var initiatorCache: [MetaWear: DFUServiceInitiator] = [:]
private var dfuSourceCache: [MetaWear: TaskCompletionSource<Void>] = [:]
private var dfuControllerCache: [MetaWear: DFUServiceController] = [:]

extension MetaWear {
    /// Get a pointer to the latest firmware for this device
    public func latestFirmware() -> Task<FirmwareBuild> {
        let tasks = [readHardwareRev(), readModelNumber()]
        return Task.whenAllResult(tasks).continueOnSuccessWithTask { result -> Task<FirmwareBuild> in
            return FirmwareServer.getLatestFirmwareAsync(hardwareRev: result[0],
                                                         modelNumber: result[1])
        }
    }
    
    /// Get a pointer to the latest firmware for this device or nil if already on the latest
    public func checkForFirmwareUpdate() -> Task<FirmwareBuild?> {
        var latestBuild: FirmwareBuild?
        return latestFirmware().continueOnSuccessWithTask { result -> Task<String> in
            latestBuild = result
            return self.readFirmwareRev()
        }.continueOnSuccessWith { result in
            if result.isVersion(lessThan: latestBuild!.firmwareRev) {
                return latestBuild
            }
            return nil
        }
    }
    
    /// Install the provided firmware (or latest if none provided)
    public func updateFirmware(delegate: DFUProgressDelegate? = nil, build: FirmwareBuild? = nil) -> Task<Void> {
        var finalBuild: FirmwareBuild!
        return connectAndSetup().continueOnSuccessWithTask { _ -> Task<FirmwareBuild> in
            // Get latest if not supplied
            let task: Task<FirmwareBuild>
            if let build = build {
                task = Task<FirmwareBuild>(build)
            } else {
                task = self.latestFirmware()
            }
            return task
        }.continueOnSuccessWithTask { result -> Task<Void> in
            finalBuild = result
            guard self.isMetaBoot else {
                mbl_mw_debug_jump_to_bootloader(self.board)
                return Task<Void>.withDelay(3.0)
            }
            return Task<Void>(())
        }.continueOnSuccessWithTask { result -> Task<Void> in
            return updateMetaBoot(metaboot:self, build: finalBuild, delegate: delegate)
        }.continueWithTask {
            self.cancelConnection()
            initiatorCache.removeValue(forKey: self)
            dfuSourceCache.removeValue(forKey: self)
            dfuControllerCache.removeValue(forKey: self)
            return $0
        }
    }
}

/// Call into the actual Nordic DFU library
func runNordicInstall(metaboot: MetaWear, firmware: DFUFirmware, delegate: DFUProgressDelegate?) -> Task<Void> {
    let initiator = DFUServiceInitiator(queue: metaboot.apiAccessQueue).with(firmware: firmware)
    initiator.forceDfu = true // We also have the DIS which confuses the DFU library
    initiator.logger = metaboot
    initiator.delegate = metaboot
    initiator.progressDelegate = delegate
    
    initiatorCache[metaboot] = initiator
    let dfuSource = TaskCompletionSource<Void>()
    dfuSourceCache[metaboot] = dfuSource
    dfuControllerCache[metaboot] = initiator.start(target: metaboot.peripheral)
    return dfuSource.task
}

/// Recursive check that the correct bootloader is installed before trying DFU
func updateMetaBoot(metaboot: MetaWear, build: FirmwareBuild, delegate: DFUProgressDelegate?) -> Task<Void> {
    return metaboot.connectAndSetup().continueOnSuccessWithTask { _ in
        if let required = build.requiredBootloader, required != metaboot.info!.firmwareRevision {
            return FirmwareServer.getAllBootloaderAsync(hardwareRev: build.hardwareRev, modelNumber: build.modelNumber).continueWithTask {
                if let bootloader = $0.result?.first(where: { $0.firmwareRev == required }) {
                    return updateMetaBoot(metaboot: metaboot, build: bootloader, delegate: delegate).continueOnSuccessWithTask {
                        return updateMetaBoot(metaboot: metaboot, build: build, delegate: delegate)
                    }
                } else {
                    return Task<Void>(error: MetaWearError.operationFailed(message: "Could not perform DFU.  Firmware \(build.firmwareRev) requires bootloader version '\(required)' which does not exist."))
                }
            }
        } else {
            return build.getNordicFirmware().continueOnSuccessWithTask {
                return runNordicInstall(metaboot: metaboot, firmware: $0, delegate: delegate)
            }
        }
    }
}

extension MetaWear: DFUServiceDelegate {
    public func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .completed:
            DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
                dfuSourceCache[self]!.trySet(result: ())
            }
        default:
            break
        }
    }
    public func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        dfuSourceCache[self]?.trySet(error: MetaWearError.operationFailed(message: message))
    }
}

extension MetaWear: LoggerDelegate {
    public func logWith(_ level: iOSDFULibrary.LogLevel, message: String) {
        let newLevel: LogLevel
        switch level {
        case .debug:
            newLevel = LogLevel.debug
        case .verbose:
            newLevel = LogLevel.debug
        case .info:
            newLevel = LogLevel.info
        case .application:
            newLevel = LogLevel.info
        case .warning:
            newLevel = LogLevel.warning
        case .error:
            newLevel = LogLevel.error
        }
        logDelegate?.logWith(newLevel, message: message)
    }
}

