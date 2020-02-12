/**
 * MetaWearScanner.swift
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
import BoltsSwift


fileprivate let rememberedDevicesKey = "com.mbientlab.rememberedDevices"
fileprivate var scannerCount = 0

/// Scanner utility, make is simple to start scanning for MetaWear devices without
/// having to understand all of CoreBluetooth
public class MetaWearScanner: NSObject {
    public static let shared = MetaWearScanner()
    public static let sharedRestore = MetaWearScanner(restoreIdentifier: "MetaWearScanner.shared")
    public var central: CBCentralManager! = nil
    /// All devices that have been discovered in one way or another by this central
    public var deviceMap: [CBPeripheral: MetaWear] = [:]
    public var didUpdateState: ((CBCentralManager) -> Void)? {
        didSet {
            didUpdateState?(central)
        }
    }
    
    public init(restoreIdentifier: String? = nil) {
        super.init()
        let options: [String : Any] = restoreIdentifier == nil ? [:] : [CBCentralManagerOptionRestoreIdentifierKey: restoreIdentifier!]
        self.central = CBCentralManager(delegate: self,
                                        queue: bleQueue,
                                        options: options)
    }
    
    /// Start the scaning process for MetaWear or MetaBoot devices
    public func startScan(allowDuplicates: Bool, callback: @escaping (MetaWear) -> Void) {
        runWhenPoweredOn {
            self.callback = callback
            self.central.scanForPeripherals(withServices: [.metaWearService,
                                                           .metaWearDfuService],
                                            options: [CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicates])
            // Restart scanning if BLE state toggles off then on
            self.runOnPowerOff.append { [unowned self] in
                if let callback = self.callback {
                    self.startScan(allowDuplicates: allowDuplicates, callback: callback)
                }
            }
        }
    }
    
    /// Stop scanning
    public func stopScan() {
        self.callback = nil
        runWhenPoweredOn {
            self.central.stopScan()
        }
    }
    
    /// List of devices stored via `MetaWear.remember()`
    public func retrieveSavedMetaWearsAsync() -> Task<[MetaWear]> {
        let source = TaskCompletionSource<[MetaWear]>()
        runWhenPoweredOn {
            var devices: [MetaWear] = []
            if let ids = UserDefaults.standard.stringArray(forKey: rememberedDevicesKey) {
                let uuids = ids.map { UUID(uuidString: $0)! }
                let peripherals = self.central.retrievePeripherals(withIdentifiers: uuids)
                devices = peripherals.map { peripheral -> MetaWear in
                    let device = self.deviceMap[peripheral] ?? MetaWear(peripheral: peripheral, scanner: self)
                    self.deviceMap[peripheral] = device
                    return device
                }
            }
            source.trySet(result: devices)
        }
        return source.task
    }
    
    /// List of devices that are already connected
    /// This is useful to check after state was restored
    public func retrieveConnectedMetaWearsAsync() -> Task<[MetaWear]> {
        let source = TaskCompletionSource<[MetaWear]>()
        runWhenPoweredOn {
            var devices: [MetaWear] = []
            let peripherals = self.central.retrieveConnectedPeripherals(withServices: [.metaWearService,
                                                                                       .metaWearDfuService])
            devices = peripherals.map { peripheral -> MetaWear in
                let device = self.deviceMap[peripheral] ?? MetaWear(peripheral: peripheral, scanner: self)
                self.deviceMap[peripheral] = device
                return device
            }
            source.trySet(result: devices)
        }
        return source.task
    }
    
    // Internal details below
    var allowDuplicates: Bool = false
    var callback: ((MetaWear) -> Void)?
    var isScanning = false
    var centralStateUpdateSources: [TaskCompletionSource<()>] = []
    var runOnPowerOn: [() -> Void] = []
    var runOnPowerOff: [() -> Void] = []
    public let bleQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.mbientlab.bleQueue\(scannerCount)")
        scannerCount += 1
        queue.setSpecific(key: bleQueueKey, value: bleQueueValue)
        return queue
    }()
    
    func connect(_ device: MetaWear) {
        runWhenPoweredOn {
            self.central.connect(device.peripheral)
        }
    }
    
    func cancelConnection(_ device: MetaWear) {
        runWhenPoweredOn {
            self.central.cancelPeripheralConnection(device.peripheral)
        }
    }
    
    func runWhenPoweredOn(_ code: @escaping () -> Void) {
        bleQueue.async {
            if self.central.state == .poweredOn {
               code()
            } else {
                self.runOnPowerOn.append(code)
            }
        }
    }
    
    func remember(_ device: MetaWear) {
        let idString = device.peripheral.identifier.uuidString
        var devices = UserDefaults.standard.stringArray(forKey: rememberedDevicesKey) ?? []
        if !devices.contains(idString) {
            devices.append(idString)
        }
        UserDefaults.standard.set(devices, forKey: rememberedDevicesKey)
    }
    func forget(_ device: MetaWear) {
        var devices = UserDefaults.standard.stringArray(forKey: rememberedDevicesKey)
        if let idx = devices?.firstIndex(of: device.peripheral.identifier.uuidString) {
            devices?.remove(at: idx)
            UserDefaults.standard.set(devices, forKey: rememberedDevicesKey)
        }
    }
    
    func updateCentralStateSource(_ source: TaskCompletionSource<()>) {
        switch central.state {
        case .unknown:
            break // Updates are imminent, so wait
        case .resetting:
            break // Updates are imminent, so wait
        case .unsupported:
            source.set(error: MetaWearError.bluetoothUnsupported)
        case .unauthorized:
            source.set(error: MetaWearError.bluetoothUnauthorized)
        case .poweredOff:
            source.set(error: MetaWearError.bluetoothPoweredOff)
        case .poweredOn:
            source.set(result: ())
        @unknown default:
            fatalError("new central.state values, please update.")
        }
    }
    
    func centralStateTask() -> Task<()> {
        let source = TaskCompletionSource<()>()
        bleQueue.async {
            self.updateCentralStateSource(source)
            if !source.task.completed {
                self.centralStateUpdateSources.append(source)
            }
        }
        return source.task
    }
}

fileprivate let bleQueueKey = DispatchSpecificKey<Int>()
fileprivate let bleQueueValue = 1111
extension DispatchQueue {
    class var isBleQueue: Bool {
        return DispatchQueue.getSpecific(key: bleQueueKey) == bleQueueValue
    }
}

extension MetaWearScanner: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        didUpdateState?(central)
        
        // TODO: This seems like an iOS bug.  If bluetooth powers off the
        // peripherials disconnect, but we don't get a deviceDidDisconnect callback.
        if central.state != .poweredOn {
            deviceMap.forEach { $0.value.didDisconnectPeripheral(error: MetaWearError.bluetoothPoweredOff) }
        }
        // Execute all commands when the central is ready
        if central.state == .poweredOn {
            let localRunOnPowerOn = runOnPowerOn
            runOnPowerOn.removeAll()
            localRunOnPowerOn.forEach { $0() }
        } else if central.state == .poweredOff {
            let localRunOnPowerOff = runOnPowerOff
            runOnPowerOff.removeAll()
            localRunOnPowerOff.forEach { $0() }
        }

        centralStateUpdateSources.forEach { self.updateCentralStateSource($0) }
        centralStateUpdateSources = centralStateUpdateSources.filter { !$0.task.completed }
    }
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = deviceMap[peripheral] ?? MetaWear(peripheral: peripheral, scanner: self)
        deviceMap[peripheral] = device
        device.didDiscover(advertisementData: advertisementData, rssi: RSSI)
        callback?(device)
    }
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        deviceMap[peripheral]?.didConnect()
    }
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        deviceMap[peripheral]?.didFailToConnect(error: error)
    }
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        deviceMap[peripheral]?.didDisconnectPeripheral(error: error)
    }
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        // As an SDK, we arn't sure what operations the user is acutally doing.
        // You should place code in didFinishLaunchingWithOptions to kick off any tasks
        // you expect to take place
        
        // An array (an instance of NSArray) of CBPeripheral objects that contains
        // all of the peripherals that were connected to the central manager
        // (or had a connection pending) at the time the app was terminated by the system.
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                let device = MetaWear(peripheral: peripheral, scanner: self)
                self.deviceMap[peripheral] = device
            }
        }
    }
}
