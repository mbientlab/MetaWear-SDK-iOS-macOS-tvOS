/**
 * ScannerModel.swift
 * MetaWear-Swift
 *
 * Created by Stephen Schiffli on 1/22/18.
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

/// Callbacks from ScannerModel
public protocol ScannerModelDelegate: AnyObject {
    func scannerModel(_ scannerModel: ScannerModel, didAddItemAt idx: Int)
    func scannerModel(_ scannerModel: ScannerModel, confirmBlinkingItem item: ScannerModelItem, callback: @escaping (Bool) -> Void)
    func scannerModel(_ scannerModel: ScannerModel, errorDidOccur error: Error)
}

/// Common code used for creating BLE scanner UIs where the user can select/deselect devices
public class ScannerModel {
    public weak var delegate: ScannerModelDelegate?
    /// All the discovered devices
    public var items: [ScannerModelItem] = []
    
    let scanner: MetaWearScanner
    let adTimeout: Double
    let isIncluded: (MetaWear) -> Bool
    var connectingItem: ScannerModelItem?
    
    public init(delegate: ScannerModelDelegate,
                scanner: MetaWearScanner =  MetaWearScanner.shared,
                adTimeout: Double = 5.0,
                isIncluded: @escaping (MetaWear) -> Bool = { _ in return true }) {
        self.delegate = delegate
        self.scanner = scanner
        self.adTimeout = adTimeout
        self.isIncluded = isIncluded
    }
    
    public var isScanning = false {
        didSet {
            guard oldValue != isScanning else {
                return
            }
            guard isScanning else {
                scanner.stopScan()
                items.forEach { $0.watchdogStop() }
                return
            }
            scanner.startScan(allowDuplicates: true) { [weak self] device in
                guard let _self = self else {
                    return
                }
                guard _self.isIncluded(device) else {
                    return
                }
                DispatchQueue.main.async {
                    if let item = _self.items.first(where: { $0.device == device }) {
                        item.watchdogReset()
                        item.stateDidChange?()
                    } else {
                        _self.items.append(ScannerModelItem(device, _self))
                        _self.delegate?.scannerModel(_self, didAddItemAt: _self.items.count - 1)
                    }
                }
            }
        }
    }
    
    func didToggle(_ item: ScannerModelItem) {
        guard item.isConnecting else {
            item.device.cancelConnection()
            return
        }
        connectingItem = item
        items.forEach { $0.stateDidChange?() }
        
        item.device.connectAndSetup().continueWith { t in
            let resetState = {
                self.connectingItem = nil
                item.isConnecting = false
                self.items.forEach { $0.stateDidChange?() }
            }
            guard !t.cancelled && !t.faulted else {
                resetState()
                if let error = t.error {
                    DispatchQueue.main.async {
                        self.delegate?.scannerModel(self, errorDidOccur: error)
                    }
                }
                return
            }
            // The connection could have synd an unknown MAC address
            item.stateDidChange?()
            item.device.flashLED(color: .green, intensity: 1.0, _repeat: 60)
            DispatchQueue.main.async {
                self.delegate?.scannerModel(self, confirmBlinkingItem: item) { (confirmed) in
                    resetState()
                    item.device.turnOffLed()
                    if !confirmed {
                        mbl_mw_debug_disconnect(item.device.board)
                    }
                }
            }
        }
    }
}


public class ScannerModelItem {
    public let device: MetaWear
    public internal(set) var isConnecting = false
    weak var parent: ScannerModel?
    var adWatchdog: Timer?
    /// See if the connect button should be enabled 
    public var connectButtonEnabled: Bool {
        let someoneConnecting = parent?.connectingItem != nil
        return !someoneConnecting || isConnecting
    }
    /// Listen for changes that would require changes to the UI
    public var stateDidChange: (() -> Void)? {
        didSet {
            stateDidChange?()
        }
    }
    
    init(_ device: MetaWear, _ parent: ScannerModel?) {
        self.device = device
        self.parent = parent
        watchdogReset()
    }
    
    /// The UI can expose a 'Connect' button for each device, which in turn should call this
    public func toggleConnect() {
        isConnecting = !isConnecting
        parent?.didToggle(self)
    }

    func watchdogReset() {
        DispatchQueue.main.async {
            self.adWatchdog?.invalidate()
            self.adWatchdog = Timer.scheduledTimer(withTimeInterval: (self.parent?.adTimeout ?? 5.0) + 0.1, repeats: false) { [weak self] t in
                self?.stateDidChange?()
            }
        }
    }
    func watchdogStop() {
        DispatchQueue.main.async {
            self.adWatchdog?.invalidate()
            self.adWatchdog = nil
        }
    }
}
