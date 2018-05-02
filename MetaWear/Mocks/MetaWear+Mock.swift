/**
 * MockMetaWear.swift
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
import MetaWearCpp

class MockPeripheral: CBPeripheral {
    private var mockName: String?
    override var name: String? {
        get { return mockName }
        set { mockName = newValue }
    }
    private var mockIdentifier: UUID
    override var identifier: UUID {
        get { return mockIdentifier }
        set { mockIdentifier = newValue }
    }
    private init(id: String, name: String? = nil) {
        self.mockName = name
        self.mockIdentifier = UUID(uuidString: id)!
    }
    static func create(id: String, name: String? = nil) -> CBPeripheral {
        let peripheral = MockPeripheral(id: id, name: name)
        // This is needed to prevent crashing when disposed
        peripheral.addObserver(peripheral, forKeyPath: #keyPath(MockPeripheral.delegate), options: [], context: nil)
        return peripheral
    }
}

extension DeviceInformation {
    static let metaMotionC = DeviceInformation(
        manufacturer:  "MbientLab Inc",
        modelNumber: "6",
        serialNumber: "FFFFFF",
        firmwareRevision: "1.3.6",
        hardwareRevision: "0.1"
    )
    static let metaMotionR = DeviceInformation(
        manufacturer:  "MbientLab Inc",
        modelNumber: "5",
        serialNumber: "FFFFFF",
        firmwareRevision: "1.3.6",
        hardwareRevision: "0.2"
    )
}

extension MetaWear {
    static func spoof(name: String = "unittest",
                      id: String = "CC5CEEF1-C8B9-47BF-9B5D-E7329CED353D",
                      mac: String = "BA:AA:AD:F0:00:0D",
                      info: DeviceInformation = .metaMotionC) -> MetaWear {
        let peripheral = MockPeripheral.create(id: id, name: name)
        let device = MetaWear(peripheral: peripheral, scanner: MetaWearScanner.shared)
        device.mac = mac
        device.info = info
        return device
    }
}
