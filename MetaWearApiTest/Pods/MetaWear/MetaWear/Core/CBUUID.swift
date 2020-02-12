/**
 * CBUUID.swift
 * MetaWear-Swift
 *
 * Created by Stephen Schiffli on 12/14/17.
 * Copyright 2017 MbientLab Inc. All rights reserved.
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

/// Bluetooth ID's used by MetaWear
extension CBUUID {
    public static let metaWearService = CBUUID(string: "326A9000-85CB-9195-D9DD-464CFBBAE75A")
    public static let metaWearCommand = CBUUID(string: "326A9001-85CB-9195-D9DD-464CFBBAE75A")
    public static let metaWearNotification = CBUUID(string: "326A9006-85CB-9195-D9DD-464CFBBAE75A")
    public static let metaWearDfuService = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
    public static let batteryService = CBUUID(string: "180F")
    public static let batteryLife = CBUUID(string: "2A19")
    public static let disService = CBUUID(string: "180A")
    public static let disModelNumber = CBUUID(string: "2A24")
    public static let disSerialNumber = CBUUID(string: "2A25")
    public static let disFirmwareRev = CBUUID(string: "2A26")
    public static let disHardwareRev = CBUUID(string: "2A27")
    public static let disManufacturerName = CBUUID(string: "2A29")
}
