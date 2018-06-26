/**
 * MetaWear.swift
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
import BoltsSwift


public enum MetaWearError: Error {
    case operationFailed(message: String)
    case bluetoothUnsupported
    case bluetoothUnauthorized
    case bluetoothPoweredOff
}

extension MetaWearError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        case .bluetoothUnsupported:
            return "Bluetooth unsupported on this platform"
        case .bluetoothUnauthorized:
            return "Bluetooth unauthorized in this App"
        case .bluetoothPoweredOff:
            return "Bluetooth powered off"
        }
    }
}

// Folder to store device information
fileprivate let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
fileprivate let adQueue = DispatchQueue(label: "com.mbientlab.adQueue")

public class MetaWear: NSObject {
    public var logDelegate: LogDelegate?
    public let peripheral: CBPeripheral
    public internal(set) weak var scanner: MetaWearScanner?
    public internal(set) var board: OpaquePointer!
    public internal(set) var advertisementData: [String : Any] {
        get {
            return adQueue.sync { advertisementDataImpl }
        }
        set {
            adQueue.sync { advertisementDataImpl = newValue }
        }
    }
    public internal(set) var rssi: Int = 0
    public internal(set) var mac: String?
    public internal(set) var info: DeviceInformation?
    public internal(set) var isConnectedAndSetup = false
    public var isMetaBoot: Bool {
        let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
        return services?.contains(.metaWearDfuService) ?? false
    }
    public var name: String {
        // peripheral.name may be cached, use the name from advertising data
        let adName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        return adName ?? peripheral.name ?? "MetaWear"
    }
    public var advertisementReceived: (() -> Void)?
    public var uniqueUrl: URL {
        var url = appSupportDirectory.appendingPathComponent("com.mbientlab.devices", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        url.appendPathComponent(peripheral.identifier.uuidString + ".file")
        return url
    }
    public var apiAccessQueue: DispatchQueue {
        return scanner?.bleQueue ?? DispatchQueue.global()
    }
    public var apiAccessExecutor: Executor {
        return Executor.queue(apiAccessQueue)
    }
    
    public func averageRSSI(lastNSeconds: Double = 5.0) -> Double? {
        let filteredRSSI = rssiHistory.filter { -$0.0.timeIntervalSinceNow < lastNSeconds }
        guard filteredRSSI.count > 0 else {
            return nil
        }
        let sumArray = filteredRSSI.reduce(0.0) { $0 + $1.1 }
        return sumArray / Double(filteredRSSI.count)
    }
    
    // The result of the task returned can be used to watch for disconnects
    public func connectAndSetup() -> Task<Task<MetaWear>> {
        let source = TaskCompletionSource<Task<MetaWear>>()
        apiAccessQueue.async {
            guard !self.isConnectedAndSetup else {
                let disconnectSource = TaskCompletionSource<MetaWear>()
                self.disconnectionSources.append(disconnectSource)
                source.trySet(result: disconnectSource.task)
                return
            }
            self.connectionSources.append(source)
            if self.connectionSources.count == 1 {
                self.scanner?.connect(self)
            }
        }
        return source.task
    }
    
    public func cancelConnection() {
        scanner?.cancelConnection(self)
    }
    
    public func remember() {
        scanner?.remember(self)
    }
    
    public func forget() {
        scanner?.forget(self)
    }
    
    public func serialize() -> [UInt8] {
        var count: UInt32 = 0
        let start = mbl_mw_metawearboard_serialize(board, &count)
        let data = Array(UnsafeBufferPointer(start: start, count: Int(count)))
        mbl_mw_memory_free(start)
        return data
    }
    
    public func deserialize(_ _data: [UInt8]) {
        var data = _data
        mbl_mw_metawearboard_deserialize(board, &data, UInt32(data.count))
    }
    
    public func readHardwareRev() -> Task<String> {
        return readCharacteristic(.disService, .disHardwareRev).continueOnSuccessWith {
            return String(data: $0, encoding: .utf8) ?? ""
        }
    }
    
    public func readModelNumber() -> Task<String> {
        return readCharacteristic(.disService, .disModelNumber).continueOnSuccessWith {
            return String(data: $0, encoding: .utf8) ?? ""
        }
    }
    
    public func readFirmwareRev() -> Task<String> {
        return readCharacteristic(.disService, .disFirmwareRev).continueOnSuccessWith {
            return String(data: $0, encoding: .utf8) ?? ""
        }
    }
    
    public func latestFirmware() -> Task<FirmwareBuild> {
        let tasks = [readHardwareRev(), readModelNumber()]
        return Task.whenAllResult(tasks).continueOnSuccessWithTask { result -> Task<FirmwareBuild> in
            return FirmwareServer.getLatestFirmwareAsync(hardwareRev: result[0], modelNumber: result[1])
        }
    }
    
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
    
    public func getCharacteristic(_ serviceUUID: CBUUID,
                                  _ characteristicUUID: CBUUID) -> (error: Error?, characteristic: CBCharacteristic?)  {
        guard self.isConnectedAndSetup else {
            return (MetaWearError.operationFailed(message: "call connectAndSetup before performing operations"), nil)
        }
        guard let service = self.peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            return (MetaWearError.operationFailed(message: "service not found"), nil)
        }
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            return (MetaWearError.operationFailed(message: "characteristics not found"), nil)
        }
        return (nil, characteristic)
    }
    
    public func readCharacteristic(_ serviceUUID: CBUUID, _ characteristicUUID: CBUUID) -> Task<Data> {
        let source = TaskCompletionSource<Data>()
        apiAccessQueue.async {
            let result = self.getCharacteristic(serviceUUID, characteristicUUID)
            guard let characteristic = result.characteristic else {
                source.trySet(error: result.error!)
                return
            }
            var tmp = self.localReadCallbacks[characteristic] ?? []
            tmp.append(source)
            self.localReadCallbacks[characteristic] = tmp
            self.peripheral.readValue(for: characteristic)
        }
        return source.task
    }
    
    /// Internal details below
    fileprivate var gattCharMap: [MblMwGattChar: CBCharacteristic] = [:]
    fileprivate var subscribeCompleteCallbacks: [CBCharacteristic: MblMwFnVoidVoidPtrInt] = [:]
    fileprivate var onDataCallbacks: [CBCharacteristic: MblMwFnIntVoidPtrArray] = [:]
    fileprivate var onReadCallbacks: [CBCharacteristic: MblMwFnIntVoidPtrArray] = [:]
    fileprivate var onDisconnectCallback: MblMwFnVoidVoidPtrInt?
    fileprivate var disconnectionSources: [TaskCompletionSource<MetaWear>] = []
    fileprivate var connectionSources: [TaskCompletionSource<Task<MetaWear>>] = []
    fileprivate var localReadCallbacks: [CBCharacteristic: [TaskCompletionSource<Data>]] = [:]
    fileprivate var advertisementDataImpl: [String : Any] = [:]
    
    fileprivate var serviceCount = 0
    var rssiHistory: [(Date, Double)] = []

    init(peripheral: CBPeripheral, scanner: MetaWearScanner) {
        self.peripheral = peripheral
        self.scanner = scanner
        super.init()
        self.peripheral.delegate = self
        var connection = MblMwBtleConnection(context: bridge(obj: self),
                                             write_gatt_char: writeGattChar,
                                             read_gatt_char: readGattChar,
                                             enable_notifications: enableNotifications,
                                             on_disconnect: onDisconnect)
        self.board = mbl_mw_metawearboard_create(&connection)
        // TODO: evaluate if the timeout provides value
        mbl_mw_metawearboard_set_time_for_response(self.board, 0)
        self.mac = UserDefaults.standard.string(forKey: "com.mbientlab.macstorage." + peripheral.identifier.uuidString)
    }
    
    func didConnect() {
        // Perform a service discovery and setup
        peripheral.discoverServices([
            .metaWearService,
            .metaWearDfuService,
            .batteryService,
            .disService
            ])
    }
    func didFailToConnect(error: Error?) {
        invokeConnectionHandlers(error: error, cancelled: false)
        invokeDisconnectionHandlers(error: error)
    }
    func didDisconnectPeripheral(error: Error?) {
        invokeConnectionHandlers(error: error, cancelled: error == nil)
        invokeDisconnectionHandlers(error: error)
    }
    func invokeDisconnectionHandlers(error: Error?) {
        assert(DispatchQueue.isBleQueue)
        isConnectedAndSetup = false
        // Inform the C++ SDK
        onDisconnectCallback?(UnsafeRawPointer(board), 0)
        onDisconnectCallback = nil
        
        let unexpected = (error != nil) && (error as? CBError)?.code != .peripheralDisconnected
        disconnectionSources.forEach { unexpected ? $0.set(error: error!) : $0.set(result: self) }
        disconnectionSources.removeAll(keepingCapacity: true)
        
        gattCharMap = [:]
        subscribeCompleteCallbacks = [:]
        onDataCallbacks = [:]
        onReadCallbacks = [:]
        localReadCallbacks.forEach { $0.value.forEach { $0.trySet(error: MetaWearError.operationFailed(message: "disconnected before read finished")) } }
        localReadCallbacks.removeAll(keepingCapacity: true)
    }
    func invokeConnectionHandlers(error: Error?, cancelled: Bool) {
        assert(DispatchQueue.isBleQueue)
        if !cancelled && error == nil {
            self.isConnectedAndSetup = true
        }
        // Clear out the connectionSources array now because we use the
        // length as an indication of a pending operation, and if any of
        // the callback call connectAndSetup, we need the right thing to happen
        let localConnectionSources = connectionSources
        connectionSources.removeAll(keepingCapacity: true)
        
        if let error = error {
            localConnectionSources.forEach { $0.trySet(error: error) }
        } else if cancelled {
            localConnectionSources.forEach { $0.tryCancel() }
        } else {
            let source = TaskCompletionSource<MetaWear>()
            disconnectionSources.append(source)
            localConnectionSources.forEach { $0.trySet(result: source.task) }
        }
    }
    fileprivate func getCharacteristic(_ characteristicPtr: UnsafePointer<MblMwGattChar>?) -> CBCharacteristic? {
        guard let characteristicPtr = characteristicPtr else {
            return nil
        }
        if let characteristic = gattCharMap[characteristicPtr.pointee] {
            return characteristic
        }
        
        let serviceUUID = characteristicPtr.pointee.serviceUUID
        let _service = peripheral.services?.first { service -> Bool in
            return service.uuid == serviceUUID
        }
        guard let service = _service else {
            return nil
        }
        
        let characteristicUUID = characteristicPtr.pointee.characteristicUUID
        let _characteristic = service.characteristics?.first { characteristic -> Bool in
            return characteristic.uuid == characteristicUUID
        }
        guard let characteristic = _characteristic else {
            return nil
        }
        
        gattCharMap[characteristicPtr.pointee] = characteristic
        return characteristic
    }
}

extension MetaWear: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        gattCharMap = [:]
        serviceCount = 0
        for service in peripheral.services! {
            switch service.uuid {
            case .metaWearService:
                peripheral.discoverCharacteristics([
                    .metaWearCommand,
                    .metaWearNotification], for: service)
            case .batteryService:
                peripheral.discoverCharacteristics([.batteryLife], for: service)
            case .disService:
                peripheral.discoverCharacteristics(
                    [.disManufacturerName,
                     .disSerialNumber,
                     .disHardwareRev,
                     .disFirmwareRev,
                     .disModelNumber], for: service)
            case .metaWearDfuService:
                break // Expected service, but we don't need to discover its characteristics
            default:
                let error = MetaWearError.operationFailed(message: "MetaWear device contained an unexpected BLE service.  Please try connection again.")
                self.invokeConnectionHandlers(error: error, cancelled: false)
                self.invokeDisconnectionHandlers(error: error)
                self.cancelConnection()
                break
            }
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard !isMetaBoot else {
            apiAccessQueue.async {
                self.invokeConnectionHandlers(error: nil, cancelled: false)
            }
            return
        }
        serviceCount += 1
        if serviceCount == 3 {
            // Setup the CPP SDK
            mbl_mw_metawearboard_initialize(board, bridgeRetained(obj: self)) { (context, board, code) in
                let device: MetaWear = bridgeTransfer(ptr: context!)
                let error = code != 0 ? MetaWearError.operationFailed(message: "initialized failed: \(code)") : nil
                // Finished if we had an error
                guard error == nil else {
                    device.apiAccessQueue.async {
                        device.invokeConnectionHandlers(error: error, cancelled: false)
                        device.cancelConnection()
                    }
                    return
                }
                // Grab the device info
                let rawInfo = mbl_mw_metawearboard_get_device_information(device.board)
                device.info = rawInfo?.pointee.convert()
                mbl_mw_memory_free(UnsafeMutableRawPointer(mutating: rawInfo))
                // Grab and cache the mac address if needed
                var task = Task<()>(())
                if device.mac == nil, let signal = mbl_mw_settings_get_mac_data_signal(board) {
                    let source = TaskCompletionSource<String>()
                    mbl_mw_datasignal_subscribe(signal, bridgeRetained(obj: source)) { (context, dataPtr) in
                        let source: TaskCompletionSource<String> = bridgeTransfer(ptr: context!)
                        if let dataPtr = dataPtr {
                            source.set(result: dataPtr.pointee.valueAs())
                        } else {
                            source.set(error: MetaWearError.operationFailed(message: "failed not read mac"))
                        }
                    }
                    mbl_mw_datasignal_read(signal)
                    task = source.task.continueWith {
                        mbl_mw_datasignal_unsubscribe(signal)
                        device.mac = $0.result
                        UserDefaults.standard.set(device.mac , forKey: "com.mbientlab.macstorage." + device.peripheral.identifier.uuidString)
                    }
                }
                // Finish off the connections
                task.continueWith(device.apiAccessExecutor) { _ in
                    device.invokeConnectionHandlers(error: nil, cancelled: false)
                }
            }
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            logDelegate?.logWith(.error, message: "didUpdateValueForCharacteristic \(error!)")
            return
        }
        if characteristic.uuid == .metaWearNotification {
            logDelegate?.logWith(.info, message: "Received: \(characteristic.value?.hexEncodedString() ?? "N/A")")
        } else {
            logDelegate?.logWith(.info, message: "didUpdateValueForCharacteristic \(characteristic)")
        }
        guard let data = characteristic.value else {
            return
        }
        if let onRead = onReadCallbacks[characteristic] {
            data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> () in
                let _ = onRead(UnsafeRawPointer(board), bytes, UInt8(data.count))
            }
            onReadCallbacks.removeValue(forKey: characteristic)
        }
        if let onData = onDataCallbacks[characteristic] {
            data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> () in
                let _ = onData(UnsafeRawPointer(board), bytes, UInt8(data.count))
            }
        }
        if let sources = localReadCallbacks.removeValue(forKey: characteristic) {
            sources.forEach { $0.trySet(result: data) }
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // didWriteValueFor
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        logDelegate?.logWith(.info, message: "didUpdateNotificationStateFor \(characteristic)")
        subscribeCompleteCallbacks[characteristic]?(UnsafeRawPointer(board), error == nil ? 0 : 1)
    }
}

fileprivate var commandCount = 0
// Global callback functions
fileprivate func writeGattChar(context: UnsafeMutableRawPointer?,
                   caller: UnsafeRawPointer?,
                   writeType: MblMwGattCharWriteType,
                   characteristicPtr: UnsafePointer<MblMwGattChar>?,
                   valuePtr: UnsafePointer<UInt8>?,
                   length: UInt8) {
    let device: MetaWear = bridge(ptr: context!)
    if let charToWrite = device.getCharacteristic(characteristicPtr) {
        let data = Data(bytes: valuePtr!, count: Int(length))
        device.logDelegate?.logWith(.info, message: "Writing: \(charToWrite.uuid) \(data.hexEncodedString())")
        // Throttle by having every Nth request wait for response
        commandCount += 1
        let type: CBCharacteristicWriteType = commandCount % 10 == 0 ? .withResponse : .withoutResponse
        device.peripheral.writeValue(data, for: charToWrite, type: type)
    }
}

fileprivate func readGattChar(context: UnsafeMutableRawPointer?,
                  caller: UnsafeRawPointer?,
                  characteristicPtr: UnsafePointer<MblMwGattChar>?,
                  callback: MblMwFnIntVoidPtrArray?) {
    let device: MetaWear = bridge(ptr: context!)
    if let charToRead = device.getCharacteristic(characteristicPtr) {
        // Save the callback
        device.onReadCallbacks[charToRead] = callback
        // Request the read
        device.peripheral.readValue(for: charToRead)
    }
}

fileprivate func enableNotifications(context: UnsafeMutableRawPointer?,
                         caller: UnsafeRawPointer?,
                         characteristicPtr: UnsafePointer<MblMwGattChar>?,
                         onData: MblMwFnIntVoidPtrArray?,
                         subscribeComplete: MblMwFnVoidVoidPtrInt?) {
    let device: MetaWear = bridge(ptr: context!)
    if let charToNotify = device.getCharacteristic(characteristicPtr) {
        // Save the callbacks
        device.onDataCallbacks[charToNotify] = onData
        device.subscribeCompleteCallbacks[charToNotify] = subscribeComplete
        // Turn on the notification stream
        device.peripheral.setNotifyValue(true, for: charToNotify)
    } else {
        subscribeComplete?(caller, 1)
    }
}

fileprivate func onDisconnect(context: UnsafeMutableRawPointer?,
                  caller: UnsafeRawPointer?,
                  handler: MblMwFnVoidVoidPtrInt?) {
    let device: MetaWear = bridge(ptr: context!)
    device.onDisconnectCallback = handler
}

extension Data {
    public func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
