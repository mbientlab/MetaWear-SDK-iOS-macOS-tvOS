/**
 * FirmwareBuild.swift
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
import iOSDFULibrary

/// Describes location of a firmware file
public struct FirmwareBuild {
    public let hardwareRev: String
    public let modelNumber: String
    public let buildFlavor: String
    public let firmwareRev: String
    public let filename: String
    public let requiredBootloader: String?
    
    public let firmwareURL: URL
    
    public init(hardwareRev: String,
                modelNumber: String,
                buildFlavor: String,
                firmwareRev: String,
                filename: String,
                requiredBootloader: String?) {
        self.hardwareRev = hardwareRev
        self.modelNumber = modelNumber
        self.buildFlavor = buildFlavor
        self.firmwareRev = firmwareRev
        self.filename = filename
        self.requiredBootloader = requiredBootloader
        
        self.firmwareURL = URL(string: "https://mbientlab.com/releases/metawear/\(hardwareRev)/\(modelNumber)/\(buildFlavor)/\(firmwareRev)/\(filename)")!
    }
    
    public init(hardwareRev: String,
                modelNumber: String,
                firmwareRev: String,
                customUrl: URL,
                filename: String? = nil,
                buildFlavor: String? = nil,
                requiredBootloader: String? = nil) {
        self.hardwareRev = hardwareRev
        self.modelNumber = modelNumber
        self.buildFlavor = buildFlavor ?? "vanilla"
        self.firmwareRev = firmwareRev
        self.filename = filename ?? "firmware.bin"
        self.requiredBootloader = requiredBootloader

        self.firmwareURL = customUrl
    }
    
    func getNordicFirmware() -> Task<DFUFirmware> {
        let task = firmwareURL.isFileURL ? Task<URL>(firmwareURL) : firmwareURL.downloadAsync()
        return task.continueOnSuccessWithTask { fileUrl in
            var selectedFirmware: DFUFirmware?
            if fileUrl.pathExtension.caseInsensitiveCompare("zip") == .orderedSame {
                selectedFirmware = DFUFirmware(urlToZipFile: fileUrl)
            } else {
                selectedFirmware = DFUFirmware(urlToBinOrHexFile: fileUrl, urlToDatFile: nil, type: .application)
            }
            guard let firmware = selectedFirmware else {
                return Task<DFUFirmware>(error: MetaWearError.operationFailed(message: "invalid dfu file chosen '\(fileUrl.lastPathComponent)'"))
            }
            return Task<DFUFirmware>(firmware)
        }
    }
}
