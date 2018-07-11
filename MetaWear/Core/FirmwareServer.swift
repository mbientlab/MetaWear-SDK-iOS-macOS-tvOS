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


public enum FirmwareError: Error {
    case badServerResponse
    case noAvailableFirmware(message: String)
    case cannotSaveFile(message: String)
}

public class FirmwareServer {
    // Due to a bug in the Nordic SoftDevice and Bootloader, the firmware crosses a one way bridge at
    // version 1.3.8 (bootloader 0.2.2).  Any firmware versions prior to 1.3.8 (bootloader 0.2.1) must
    // first install version 1.3.8 before installing version 1.4.0 (bootloader 0.3.0) or greater.
    // Once at 1.3.8 (bootloader 0.2.2) or greater we cannot install older versions.
    public static func getAllFirmwareAsync(hardwareRev: String,
                                           modelNumber: String,
                                           currentFirmware: String? = nil,
                                           currentBootloader: String? = nil,
                                           buildFlavor: String = "vanilla") -> Task<[FirmwareBuild]> {
        let source = TaskCompletionSource<[FirmwareBuild]>()
        // To get the latest firmware version we parse the json from our website, make sure to do
        // this on a backgroud thread to avoid hanging the UI.
        let request = URLRequest(url: URL(string: "https://mbientlab.com/releases/metawear/info1.json")!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
            if let potentialVersions = info?[hardwareRev]?[modelNumber]?[buildFlavor] {
                var validVersions = potentialVersions.filter { sdkVersion.isVersion(greaterThanOrEqualTo: $1["min-ios-version"] ?? "0") }
                
                // Handle the bridge
                if let capAtBridge = shouldCapAtBridge(currentFirmware: currentFirmware, currentBootloader: currentBootloader) {
                    validVersions = validVersions.filter {
                        return capAtBridge ? $0.key.isVersion(lessThanOrEqualTo: "1.3.8") :
                                             $0.key.isVersion(greaterThanOrEqualTo: "1.3.8")
                    }
                }
                
                let sortedVersions = validVersions.sorted { $0.key < $1.key }
                allFirmwares = sortedVersions.map {
                    FirmwareBuild(hardwareRev: hardwareRev,
                                  modelNumber: modelNumber,
                                  firmwareRev: $0,
                                  filename: $1["filename"] ?? "firmware.bin",
                                  buildFlavor: buildFlavor)
                }
            }
            
            if allFirmwares.count == 0 {
                source.trySet(error: FirmwareError.noAvailableFirmware(message: "No valid firmware releases found.  Please update your application and if problem persists, email developers@mbientlab.com"))
            }
            source.trySet(result: allFirmwares)
        }.resume()
        return source.task
    }
    
    // Check with side of the firmware bridge we are on
    static func shouldCapAtBridge(currentFirmware: String? = nil, currentBootloader: String? = nil) -> Bool? {
        assert(currentFirmware == nil || currentBootloader == nil)
        if let currentFirmware = currentFirmware {
            return currentFirmware.isVersion(lessThan: "1.3.8")
        } else if let currentBootloader = currentBootloader {
            return currentBootloader.isVersion(lessThan: "0.2.2")
        }
        return nil
    }
    
    public static func getLatestFirmwareAsync(hardwareRev: String, modelNumber: String, buildFlavor: String = "vanilla") -> Task<FirmwareBuild> {
        return FirmwareServer.getAllFirmwareAsync(hardwareRev: hardwareRev, modelNumber: modelNumber, buildFlavor: buildFlavor).continueOnSuccessWith { result in
            return result.last!
        }
    }
    
    public static func getVersionAsync(hardwareRev: String,
                                       modelNumber: String,
                                       firmwareRev: String) -> Task<URL> {
        var build = FirmwareBuild(hardwareRev: hardwareRev,
                                  modelNumber: modelNumber,
                                  firmwareRev: firmwareRev,
                                  filename: "firmware.zip")
        return build.firmwareURL.downloadAsync().continueWithTask { t -> Task<URL> in
            if !t.faulted {
                return t
            }
            build = FirmwareBuild(hardwareRev: hardwareRev,
                                  modelNumber: modelNumber,
                                  firmwareRev: firmwareRev,
                                  filename: "firmware.bin")
            return build.firmwareURL.downloadAsync()
        }
    }
}


extension URL {
    public func downloadAsync() -> Task<URL> {
        let source = TaskCompletionSource<URL>()
        // Go grab the file at the URL
        let url = self
        print("Downloading... \(url)")
        URLSession.shared.downloadTask(with: url) { (location, response, error) in
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
                print("Download Complete")
            } catch {
                source.trySet(error: FirmwareError.cannotSaveFile(message: "Couldn't find temp directory to store firmware file.  Please report issue to developers@mbientlab.com"))
            }
        }.resume()
        return source.task
    }
}
