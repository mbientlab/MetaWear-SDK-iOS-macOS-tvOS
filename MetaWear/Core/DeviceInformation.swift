/**
 * DeviceInformation.swift
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/3/18.
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

import MetaWearCpp

/// Container of information about a MetaWear board
public struct DeviceInformation {
    public let manufacturer: String
    public let modelNumber: String
    public let serialNumber: String
    public let firmwareRevision: String
    public let hardwareRevision: String
    
    public init(manufacturer: String,
                modelNumber: String,
                serialNumber: String,
                firmwareRevision: String,
                hardwareRevision: String) {
        self.manufacturer = manufacturer
        self.modelNumber = modelNumber
        self.serialNumber = serialNumber
        self.firmwareRevision = firmwareRevision
        self.hardwareRevision = hardwareRevision
    }
}

extension MblMwDeviceInformation {
    /// Used to bridge between MetaWearCpp classes and native managed Swift struct
    func convert() -> DeviceInformation {
        return DeviceInformation(manufacturer: String(cString: manufacturer),
                                 modelNumber: String(cString: model_number),
                                 serialNumber: String(cString: serial_number),
                                 firmwareRevision: String(cString: firmware_revision),
                                 hardwareRevision: String(cString: hardware_revision))
    }
}
