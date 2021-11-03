/**
 * FirmwareServer.swift
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
import BoltsSwift


/// Possible errors when retrieving firmwares from the MbientLab servers
public enum FirmwareError: Error {
    /// If server is down or not responding
    case badServerResponse
    /// Unable to find a compatible firmware
    case noAvailableFirmware(message: String)
    /// Likely to never occur, unless device runs out of space
    case cannotSaveFile(message: String)
}

public let session = URLSession(configuration: .ephemeral)

/// Used for interfacing with the MbientLab firmware server
public class FirmwareServer {

    /// Find all compatible firmware for the given device type
    public static func getAllFirmwareAsync(hardwareRev: String,
                                           modelNumber: String,
                                           buildFlavor: String = "vanilla") -> Task<[FirmwareBuild]> {
        let source = TaskCompletionSource<[FirmwareBuild]>()
        // To get the latest firmware version we parse the json from our website, make sure to do
        // this on a backgroud thread to avoid hanging the UI.
        let request = URLRequest(url: URL(string: "https://mbientlab.com/releases/metawear/info2.json")!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10)
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                source.trySet(error: error!)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                source.trySet(error: FirmwareError.badServerResponse)
                return
            }
            guard httpResponse.statusCode == 200 else {
                source.trySet(error: FirmwareError.noAvailableFirmware(message: "Firmware URL \(request.url!) returned code \(httpResponse.statusCode)"))
                return
            }
            
            guard let info = try? JSONSerialization.jsonObject(with: data!) as? [String: [String: [String: [String: [String: String]]]]] else {
                source.trySet(error: FirmwareError.badServerResponse)
                return
            }
            let sdkVersion = Bundle(for: MetaWear.self).infoDictionary?["CFBundleShortVersionString"] as! String
            var allFirmwares: [FirmwareBuild] = []
            if let potentialVersions = info[hardwareRev]?[modelNumber]?[buildFlavor] {
                let validVersions = potentialVersions.filter { sdkVersion.isVersion(greaterThanOrEqualTo: $1["min-ios-version"]!) }
                let sortedVersions = validVersions.sorted { $0.key.isVersion(lessThan: $1.key) }
                allFirmwares = sortedVersions.map {
                    FirmwareBuild(hardwareRev: hardwareRev,
                                  modelNumber: modelNumber,
                                  buildFlavor: buildFlavor,
                                  firmwareRev: $0,
                                  filename: $1["filename"]!,
                                  requiredBootloader: $1["required-bootloader"]!)
                }
            }
            
            if allFirmwares.count == 0 {
                source.trySet(error: FirmwareError.noAvailableFirmware(message: "No valid firmware releases found.  Please update your application and if problem persists, email developers@mbientlab.com"))
            }
            source.trySet(result: allFirmwares)
        }.resume()
        return source.task
    }
    
    /// Find all compatible bootloaders for the given device type
    public static func getAllBootloaderAsync(hardwareRev: String, modelNumber: String) -> Task<[FirmwareBuild]> {
        return FirmwareServer.getAllFirmwareAsync(hardwareRev: hardwareRev, modelNumber: modelNumber, buildFlavor: "bootloader")
    }
    
    /// Get only the most recent firmware
    public static func getLatestFirmwareAsync(hardwareRev: String,
                                              modelNumber: String,
                                              buildFlavor: String = "vanilla") -> Task<FirmwareBuild> {
        return FirmwareServer.getAllFirmwareAsync(hardwareRev: hardwareRev,
                                                  modelNumber: modelNumber,
                                                  buildFlavor: buildFlavor).continueOnSuccessWith { result in
            return result.last!
        }
    }
    
    /// Try to find the the given firmware version
    public static func getVersionAsync(hardwareRev: String,
                                       modelNumber: String,
                                       firmwareRev: String,
                                       buildFlavor: String = "vanilla",
                                       requiredBootloader: String? = nil) -> Task<FirmwareBuild> {
        var build = FirmwareBuild(hardwareRev: hardwareRev,
                                  modelNumber: modelNumber,
                                  buildFlavor: buildFlavor,
                                  firmwareRev: firmwareRev,
                                  filename: "firmware.zip",
                                  requiredBootloader: requiredBootloader)
        return build.firmwareURL.downloadAsync().continueWithTask { t -> Task<URL> in
            if !t.faulted {
                return t
            }
            build = FirmwareBuild(hardwareRev: hardwareRev,
                                  modelNumber: modelNumber,
                                  buildFlavor: buildFlavor,
                                  firmwareRev: firmwareRev,
                                  filename: "firmware.bin",
                                  requiredBootloader: requiredBootloader)
            return build.firmwareURL.downloadAsync()
        }.continueOnSuccessWith { _ in
            return build
        }
    }
}


extension URL {
    /// Download a URL to a local file
    public func downloadAsync() -> Task<URL> {
        let source = TaskCompletionSource<URL>()
        // Go grab the file at the URL
        let url = self
#if DEBUG
        print("Downloading... \(url)")
#endif
        session.downloadTask(with: url) { (location, response, error) in
            guard error == nil else {
                source.trySet(error: error!)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                source.trySet(error: FirmwareError.badServerResponse)
                return
            }
            guard httpResponse.statusCode == 200 else {
                source.trySet(error: FirmwareError.noAvailableFirmware(message: "URL \(url) returned code \(httpResponse.statusCode)"))
                return
            }
            // If no download error, then copy the file to a permanent place.  Note the location
            // variable suppiled is invalid once this block returns.
            do {
                let tempUrl = try FileManager.default.url(for: .itemReplacementDirectory,
                                                             in: .userDomainMask,
                                                             appropriateFor: location,
                                                             create: true).appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.removeItem(at: tempUrl)
                try FileManager.default.copyItem(at: location!, to: tempUrl)
                source.trySet(result: tempUrl)
#if DEBUG
                print("Download Complete")
#endif
            } catch {
                source.trySet(error: FirmwareError.cannotSaveFile(message: "Couldn't find temp directory to store firmware file.  Please report issue to developers@mbientlab.com"))
            }
        }.resume()
        return source.task
    }
}
