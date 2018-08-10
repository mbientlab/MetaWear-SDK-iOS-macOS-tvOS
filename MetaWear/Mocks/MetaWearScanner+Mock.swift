/**
 * MetaWearScanner+Mock.swift
 * MetaWear-Swift
 *
 * Created by Stephen Schiffli on 7/23/18.
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


/// Fake peripheral that case be instantiated in the iOS simulator
public class MockCentralManager: CBCentralManager {
    public static let shared = MetaWearScanner.spoof()
    
    private weak var mockDelegate: CBCentralManagerDelegate?
    private var mockQueue: DispatchQueue
    private var mockOptions: [String : Any]?
    
    private var mockState = CBManagerState.unknown
    public override var state: CBManagerState {
        get { return mockState }
        set { mockState = newValue }
    }
    
    public init(delegate: CBCentralManagerDelegate, queue: DispatchQueue, options: [String : Any]? = nil) {
        mockDelegate = delegate
        mockQueue = queue
        mockOptions = options
        super.init(delegate: nil, queue: nil, options: nil)
        // Let them know we are ready
        queue.async {
            self.mockState = .poweredOn
            self.mockDelegate?.centralManagerDidUpdateState(self)
        }
    }
    
    public override func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) {
        if let mPeripheral = peripheral as? MockPeripheral {
            mPeripheral.state = .connecting
        }
        mockQueue.async {
            if let mPeripheral = peripheral as? MockPeripheral {
                mPeripheral.state = .connected
            }
            self.mockDelegate?.centralManager?(self, didConnect: peripheral)
        }
    }
    public override func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        if let mPeripheral = peripheral as? MockPeripheral {
            mPeripheral.state = .disconnecting
        }
        mockQueue.async {
            if let mPeripheral = peripheral as? MockPeripheral {
                mPeripheral.state = .disconnected
            }
            self.mockDelegate?.centralManager?(self, didDisconnectPeripheral: peripheral, error: nil)
        }
    }
}

extension MetaWearScanner {
    public static func spoof() -> MetaWearScanner {
        let spoof = MetaWearScanner()
        spoof.central = MockCentralManager(delegate: spoof, queue: spoof.bleQueue)
        return spoof
    }
}

