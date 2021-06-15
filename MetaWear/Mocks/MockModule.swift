/**
 * MockModule.swift
 * MetaWear-Swift
 *
 * Created by Stephen Schiffli on 8/1/18.
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

import Foundation

struct MessagePayload {
    let modId: UInt8
    let regId: UInt8
    let data: Data
}

extension Data {
    var message: MessagePayload {
        return MessagePayload(modId: self[0], regId: self[1], data: Data(suffix(from: 2)))
    }
}

typealias MessageHandler = (MessagePayload) -> Void
typealias NotificationMessageHandle = (MessagePayload, Bool) -> Void

class MockModule {
    let peripheral: MockPeripheral
    let modId: UInt8
    var handlers: [UInt8: MessageHandler] = [:]
    var entries: [UInt8] = Array(0...0xFF)
    
    init(peripheral: MockPeripheral, modId: UInt8, modImpl: UInt8, modRev: UInt8, extra: Data? = nil) {
        self.peripheral = peripheral
        self.modId = modId
        
        var data = Data([modImpl, modRev])
        if let extra = extra {
            data.append(extra)
        }
        handleRead(regId: 0) {
            peripheral.messageSend(modId: $0.modId, regId: $0.regId, notifyEn: true, data: data)
        }
    }
    
    func processMessage(_ payload: MessagePayload) {
        if let handler = handlers[payload.regId] {
            handler(payload)
        }
    }
    
    func handleRead(regId: UInt8, handler: @escaping MessageHandler) {
        handlers[regId | 0x80] = handler
    }
    
    func handleWrite(regId: UInt8, handler: @escaping MessageHandler) {
        handlers[regId] = handler
    }
    
    func handleNotification(regId: UInt8, handler: @escaping NotificationMessageHandle) {
        handlers[regId] = { payload in
            handler(payload, payload.data[0] != 0)
        }
    }
    
    static func mechanicalSwitch(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x1
        return MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 0)
    }
    
    static func led(peripheral: MockPeripheral) -> MockModule {
        let extra = Data([0x3, 0x0])
        let modId: UInt8 = 0x2
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 1, extra: extra)
        return module
    }
    
    static func accelBMI160(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x3
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 1, modRev: 2)
        return module
    }
    
    static func accelBMI270(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x3
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 4, modRev: 0)
        return module
    }
    
    static func magBMM150(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x15
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 2)
        return module
    }
    
    static func iBeacon(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x7
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 0)
        return module
    }
    
    static func genericEntriesModule(peripheral: MockPeripheral,
                                     modId: UInt8,
                                     modImpl: UInt8,
                                     modRev: UInt8,
                                     extra: Data?,
                                     createReg: UInt8,
                                     removeReg: UInt8,
                                     removeAllReg: UInt8) -> MockModule {
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: modImpl, modRev: modRev, extra: extra)
        
        module.handleWrite(regId: createReg) {
            let eventId = module.entries.remove(at: 0)
            module.peripheral.messageSend(modId: $0.modId, regId: $0.regId, notifyEn: true, data: Data([eventId]))
        }
        module.handleWrite(regId: removeReg) {
            let eventId = $0.data[0]
            let index = module.entries.insertionIndexOf(elem: eventId) { $0 < $1 }
            module.entries.insert(eventId, at: index)
        }
        module.handleWrite(regId: removeAllReg) { _ in
            module.entries = Array(0...0xFF)
        }
        return module
    }
    
    static func dataProcessor(peripheral: MockPeripheral) -> MockModule {
        return genericEntriesModule(peripheral: peripheral,
                                    modId: 0x9,
                                    modImpl: 0,
                                    modRev: 2,
                                    extra: Data([0x1c]),
                                    createReg: 2,
                                    removeReg: 6,
                                    removeAllReg: 8)
    }
    
    static func event(peripheral: MockPeripheral) -> MockModule {
        return genericEntriesModule(peripheral: peripheral,
                                    modId: 0xA,
                                    modImpl: 0,
                                    modRev: 0,
                                    extra: Data([0x1c]),
                                    createReg: 2,
                                    removeReg: 4,
                                    removeAllReg: 5)
    }
    
    static func logging(peripheral: MockPeripheral) -> MockModule {
        let module = genericEntriesModule(peripheral: peripheral,
                                          modId: 0xB,
                                          modImpl: 0,
                                          modRev: 2,
                                          extra: Data([0x8, 0x0, 0x0, 0x27, 0x10]),
                                          createReg: 0x2,
                                          removeReg: 0x3,
                                          removeAllReg: 0xA)
        module.handleRead(regId: 4) {
            module.peripheral.messageSend(modId: $0.modId, regId: $0.regId, notifyEn: true, data: Data([0x0, 0x0, 0x0, 0x0, 0x0]))
        }
        return module
    }
    
    static func timer(peripheral: MockPeripheral) -> MockModule {
        return genericEntriesModule(peripheral: peripheral,
                                    modId: 0xC,
                                    modImpl: 0,
                                    modRev: 0,
                                    extra: Data([0x8]),
                                    createReg: 2,
                                    removeReg: 5,
                                    removeAllReg: 8)
    }
    
    static func macro(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0xF
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 2, extra: Data([0x8, 0x7]))
        return module
    }
    
    static func settings(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x11
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 7, extra: Data([0x3]))
        return module
    }
    
    static func gyroBMI160(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x13
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 1)
        return module
    }
    
    static func gyroBMI270(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x13
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 1, modRev: 0)
        return module
    }
    
    static func sensorFusion(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0x19
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 2, extra: Data([0x03,0x00,0x06,0x00,0x02,0x00,0x01,0x00]))
        return module
    }
    
    static func testDebug(peripheral: MockPeripheral) -> MockModule {
        let modId: UInt8 = 0xFE
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 3)
        return module
    }
}

extension Array {
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}
