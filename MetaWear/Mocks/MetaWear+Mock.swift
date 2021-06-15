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

/// Fake peripheral that case be instantiated in the iOS simulator
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
    private weak var mockDelegate: CBPeripheralDelegate?
    override var delegate: CBPeripheralDelegate? {
        get { return mockDelegate }
        set { mockDelegate = newValue }
    }
    private var mockServices: [CBService]?
    override var services: [CBService]? {
        get { return mockServices }
        set { mockServices = newValue }
    }
    private var mockState = CBPeripheralState.disconnected
    override var state: CBPeripheralState {
        get { return mockState }
        set { mockState = newValue }
    }
    override var canSendWriteWithoutResponse: Bool {
        return true
    }
    private var info: DeviceInformation
    private var notification: CBMutableCharacteristic
    private var modules: [UInt8: MockModule] = [:]
    private func addModule(_ module: MockModule) {
        modules[module.modId] = module
    }
    
    private convenience init(id: String, info: DeviceInformation, name: String? = nil) {
        // TO DO - FIX MOCKS
        self.init(id: id, info: info)
        self.mockName = name
        self.info = info
        self.notification = CBMutableCharacteristic(type: .metaWearNotification, properties: .notify, value: nil, permissions: .readable)
        self.mockIdentifier = UUID(uuidString: id)!
    }
    
    static func create(id: String, info: DeviceInformation, name: String? = nil) -> CBPeripheral {
        let peripheral = MockPeripheral(id: id, info: info, name: name)
        
        peripheral.addModule(MockModule.mechanicalSwitch(peripheral: peripheral))
        peripheral.addModule(MockModule.led(peripheral: peripheral))
        peripheral.addModule(MockModule.accelBMI160(peripheral: peripheral))
        peripheral.addModule(MockModule.iBeacon(peripheral: peripheral))
        peripheral.addModule(MockModule.dataProcessor(peripheral: peripheral))
        peripheral.addModule(MockModule.event(peripheral: peripheral))
        peripheral.addModule(MockModule.logging(peripheral: peripheral))
        peripheral.addModule(MockModule.timer(peripheral: peripheral))
        peripheral.addModule(MockModule.macro(peripheral: peripheral))
        peripheral.addModule(MockModule.settings(peripheral: peripheral))
        peripheral.addModule(MockModule.magBMM150(peripheral: peripheral))
        peripheral.addModule(MockModule.gyroBMI160(peripheral: peripheral))
        peripheral.addModule(MockModule.sensorFusion(peripheral: peripheral))
        peripheral.addModule(MockModule.testDebug(peripheral: peripheral))
        //        // This is needed to prevent crashing when disposed
        //        peripheral.addObserver(peripheral, forKeyPath: #keyPath(MockPeripheral.delegate), options: [], context: nil)
        return peripheral
    }
    
    override func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        let message = data.message
        if let module = modules[message.modId] {
            module.processMessage(message)
        } else if message.regId == 0x80 {
            // Response to mod info reads with a null response
            messageSend(modId: message.modId, regId: message.regId, notifyEn: true, data: nil)
        }
    }
    
    override func readValue(for characteristic: CBCharacteristic) {
        var error: Error? = nil
        let mCharacteristic = characteristic as! CBMutableCharacteristic
        
        switch characteristic.uuid {
        case .disModelNumber:
            mCharacteristic.value = info.modelNumber.data(using: .utf8)!
        case .disSerialNumber:
            mCharacteristic.value = info.serialNumber.data(using: .utf8)!
        case .disFirmwareRev:
            mCharacteristic.value = info.firmwareRevision.data(using: .utf8)!
        case .disHardwareRev:
            mCharacteristic.value = info.hardwareRevision.data(using: .utf8)!
        case .disManufacturerName:
            mCharacteristic.value = info.manufacturer.data(using: .utf8)!
        case .batteryLife:
            mCharacteristic.value = Data([99])
        default:
            error = MetaWearError.operationFailed(message: "can't read characteristic")
        }
        
        MockCentralManager.shared.bleQueue.async {
            self.mockDelegate?.peripheral?(self, didUpdateValueFor: characteristic, error: error)
        }
    }
    override func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        MockCentralManager.shared.bleQueue.async {
            self.mockDelegate?.peripheral?(self, didUpdateNotificationStateFor: characteristic, error: nil)
        }
    }
    
    override func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        MockCentralManager.shared.bleQueue.async {
            self.services = [
                CBMutableService(type: CBUUID.metaWearService, primary: true),
                CBMutableService(type: CBUUID.disService, primary: false),
                CBMutableService(type: CBUUID.batteryService, primary: false)
            ]
            self.mockDelegate?.peripheral?(self, didDiscoverServices: nil)
        }
    }
    
    override func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        MockCentralManager.shared.bleQueue.async {
            if let mService = service as? CBMutableService {
                switch service.uuid {
                case .metaWearService:
                    mService.characteristics = [
                        self.notification,
                        CBMutableCharacteristic(type: .metaWearCommand, properties: [.writeWithoutResponse, .write], value: nil, permissions: .writeable),
                    ]
                case .disService:
                    mService.characteristics = [
                        CBMutableCharacteristic(type: .disModelNumber, properties: .read, value: nil, permissions: .readable),
                        CBMutableCharacteristic(type: .disSerialNumber, properties: .read, value: nil, permissions: .readable),
                        CBMutableCharacteristic(type: .disFirmwareRev, properties: .read, value: nil, permissions: .readable),
                        CBMutableCharacteristic(type: .disHardwareRev, properties: .read, value: nil, permissions: .readable),
                        CBMutableCharacteristic(type: .disManufacturerName, properties: .read, value: nil, permissions: .readable)
                    ]
                case .batteryService:
                    mService.characteristics = [
                        CBMutableCharacteristic(type: .batteryLife, properties: .read, value: nil, permissions: .readable),
                    ]
                default:
                    break
                }
            }
            self.mockDelegate?.peripheral?(self, didDiscoverCharacteristicsFor: service, error: nil)
        }
    }
    
    func messageSend(modId: UInt8, regId: UInt8, notifyEn: Bool, data: Data?) {
        if (notifyEn) {
            MockCentralManager.shared.bleQueue.async {
                var header = Data([modId, regId])
                if let data = data {
                    header.append(data)
                }
                self.notification.value = header
                self.mockDelegate?.peripheral?(self, didUpdateValueFor: self.notification, error: nil)
            }
        }
    }
}

extension DeviceInformation {
    public static let metaMotionC = DeviceInformation(
        manufacturer:  "MbientLab Inc",
        modelNumber: "6",
        serialNumber: "FFFFFF",
        firmwareRevision: "1.3.6",
        hardwareRevision: "0.1"
    )
    public static let metaMotionR = DeviceInformation(
        manufacturer:  "MbientLab Inc",
        modelNumber: "5",
        serialNumber: "FFFFFF",
        firmwareRevision: "1.3.6",
        hardwareRevision: "0.2"
    )
    public static let metaMotionRL = DeviceInformation(
        manufacturer:  "MbientLab Inc",
        modelNumber: "5",
        serialNumber: "FFFFFF",
        firmwareRevision: "1.3.6",
        hardwareRevision: "0.6"
    )
    public static let metaMotionS = DeviceInformation(
        manufacturer:  "MbientLab Inc",
        modelNumber: "8",
        serialNumber: "FFFFFF",
        firmwareRevision: "1.3.6",
        hardwareRevision: "0.1"
    )
}

extension MetaWear {
    /// Create a fake MetaWear that can be instantiated in the iOS simulator for Unit Tests
    public static func spoof(name: String = "unittest",
                             id: String = "CC5CEEF1-C8B9-47BF-9B5D-E7329CED353D",
                             mac: String = "BA:AA:AD:F0:00:0D",
                             info: DeviceInformation = .metaMotionC) -> MetaWear {
        let peripheral = MockPeripheral.create(id: id, info: info, name: name)
        let device = MetaWear(peripheral: peripheral, scanner: MockCentralManager.shared)
        MockCentralManager.shared.deviceMap[peripheral] = device
        device.mac = mac
        device.info = info
        return device
    }
}

