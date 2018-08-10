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
        return MessagePayload(modId: self[0], regId: self[1], data: suffix(from: 2))
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
        
        var header = Data(bytes: [modImpl, modRev])
        if let extra = extra {
            header.append(extra)
        }
        handleRead(regId: 0) {
            peripheral.messageSend(modId: $0.regId, regId: $0.regId, notifyEn: true, data: header)
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
    
    static func logging(peripheral: MockPeripheral) -> MockModule {
        let extra = Data(bytes: [0x8, 0x0, 0x0, 0x27, 0x10])
        let modId: UInt8 = 0xB
        let module = MockModule(peripheral: peripheral, modId: modId, modImpl: 0, modRev: 2, extra: extra)
        
        module.handleWrite(regId: 2) {
            let lodId = module.entries.remove(at: 0)
            module.peripheral.messageSend(modId: $0.modId, regId: $0.regId, notifyEn: true, data: Data(bytes: [lodId]))
        }
        module.handleRead(regId: 4) {
            module.peripheral.messageSend(modId: $0.modId, regId: $0.regId, notifyEn: true, data: Data(bytes: [0x0, 0x0, 0x0, 0x0, 0x0]))
        }
        return module
    }
}

