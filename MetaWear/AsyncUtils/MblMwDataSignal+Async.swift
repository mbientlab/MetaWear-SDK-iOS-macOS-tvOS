/**
 * MblMwDataSignal+Async.swift
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

import BoltsSwift
import MetaWearCpp

extension OpaquePointer {
    // Tasky interface to reading a MetaWear data signal
    public func read() -> Task<MetaWearData> {
        assert(mbl_mw_datasignal_is_readable(self) != 0)
        let source = TaskCompletionSource<MetaWearData>()
        mbl_mw_datasignal_subscribe(self, bridgeRetained(obj: source)) { (context, dataPtr) in
            let source: TaskCompletionSource<MetaWearData> = bridgeTransfer(ptr: context!)
            if let dataPtr = dataPtr {
                source.set(result: dataPtr.pointee.copy())
            } else {
                source.set(error: MetaWearError.operationFailed(message: "could not subscribe"))
            }
        }
        mbl_mw_datasignal_read(self)
        return source.task.continueWithTask {
            mbl_mw_datasignal_unsubscribe(self)
            return $0
        }
    }
    
    public func datasignalLog() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        mbl_mw_datasignal_log(self, bridgeRetained(obj: source)) { (context, logger) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let logger = logger {
                source.set(result: logger)
            } else {
                source.set(error: MetaWearError.operationFailed(message: "could not create log entry"))
            }
        }
        return source.task
    }
    public func passthroughCreate(mode: MblMwPassthroughMode, count: UInt16) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        mbl_mw_dataprocessor_passthrough_create(self, mode, count, bridgeRetained(obj: source)) { (context, passthrough) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let passthrough = passthrough {
                source.set(result: passthrough)
            } else {
                source.set(error: MetaWearError.operationFailed(message: "could not create conter"))
            }
        }
        return source.task
    }
}
