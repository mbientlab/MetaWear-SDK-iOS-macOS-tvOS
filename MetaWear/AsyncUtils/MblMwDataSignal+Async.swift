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

 /// Task wrappers around various CPP functions with callbacks
extension OpaquePointer {
    /// Tasky interface to reading a MetaWear data signal mbl_mw_datasignal_subscribe
    /// Read signal
    public func read() -> Task<MetaWearData> {
        assert(mbl_mw_datasignal_is_readable(self) != 0)
        let source = TaskCompletionSource<MetaWearData>()
        mbl_mw_datasignal_subscribe(self, bridgeRetained(obj: source)) { (context, dataPtr) in
            let source: TaskCompletionSource<MetaWearData> = bridgeTransfer(ptr: context!)
            if let dataPtr = dataPtr {
                source.trySet(result: dataPtr.pointee.copy())
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not subscribe"))
            }
        }
        mbl_mw_datasignal_read(self)
        return source.task.continueWithTask {
            mbl_mw_datasignal_unsubscribe(self)
            return $0
        }
    }
    
    /// Tasky interface to mbl_mw_datasignal_log
    /// Log signal
    public func datasignalLog() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        mbl_mw_datasignal_log(self, bridgeRetained(obj: source)) { (context, logger) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let logger = logger {
                source.trySet(result: logger)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create log entry"))
            }
        }
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_accounter_create_count
    /// Add timer to packet
    public func accounterCreate() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_accounter_create(self, bridgeRetained(obj: source)) { (context, counter) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let counter = counter {
                source.trySet(result: counter)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create accounter timer"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_accounter_create_count
    /// Add counter to packet
    public func accounterCreateCount() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_accounter_create_count(self, bridgeRetained(obj: source)) { (context, accounter) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let accounter = accounter {
                source.trySet(result: accounter)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create accounter counter"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_accounter_create
    /// Continuous sum
    public func accumulatorCreate() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_accumulator_create(self, bridgeRetained(obj: source)) { (context, accumulator) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let accumulator = accumulator {
                source.trySet(result: accumulator)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create accumulator"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_accumulator_create_size
    /// Continuous sum
    public func accumulatorCreateWithSize(size: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_accumulator_create_size(self, size, bridgeRetained(obj: source)) { (context, accumulator) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let accumulator = accumulator {
                source.trySet(result: accumulator)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create accumulator"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }

    /// Tasky interface to mbl_mw_dataprocessor_counter_create
    /// Counter
    public func counterCreate() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_counter_create(self, bridgeRetained(obj: source)) { (context, counter) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let counter = counter {
                source.trySet(result: counter)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create counter"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_counter_create_size
    /// Counter with size
    public func counterCreateWithSize(size: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_accumulator_create_size(self, size, bridgeRetained(obj: source)) { (context, counter) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let counter = counter {
                source.trySet(result: counter)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create counter"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_average_create
    /// Create an averager
    public func averagerCreate(size: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_average_create(self, size, bridgeRetained(obj: source)) { (context, averager) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let averager = averager {
                source.trySet(result: averager)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create averager"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_highpass_create
    /// Create a high pass filter
    public func highpassFilterCreate(size: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_average_create(self, size, bridgeRetained(obj: source)) { (context, highpass) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let highpass = highpass {
                source.trySet(result: highpass)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create high pass"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_lowpass_create
    /// Create a low pass filter
    public func lowpassFilterCreate(size: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_lowpass_create(self, size, bridgeRetained(obj: source)) { (context, lowpass) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let lowpass = lowpass {
                source.trySet(result: lowpass)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create low pass"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_buffer_create
    /// Buffer
    public func bufferCreate() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_buffer_create(self, bridgeRetained(obj: source)) { (context, buffer) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let buffer = buffer {
                source.trySet(result: buffer)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create buffer"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }

    /// Tasky interface to mbl_mw_dataprocessor_rms_create
    /// RMS
    public func rmsCreate() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_rms_create(self, bridgeRetained(obj: source)) { (context, rms) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let rms = rms {
                source.trySet(result: rms)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create rms"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_rss_create
    /// RSS
    public func rssCreate() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_rss_create(self, bridgeRetained(obj: source)) { (context, rms) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let rms = rms {
                source.trySet(result: rms)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create rss"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }

    /// Tasky interface to mbl_mw_dataprocessor_multi_comparator_create
    /// Compare
    public func simpleComparatorCreate(op: MblMwComparatorOperation, reference: Float) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_comparator_create(self, op, reference, bridgeRetained(obj: source)) { (context, comparator) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let comparator = comparator {
                source.trySet(result: comparator)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create comparator"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_multi_comparator_create
    /// Compare
    public func comparatorCreate(op: MblMwComparatorOperation, mode: MblMwComparatorMode, references: [Float]) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        var references = references
        mbl_mw_dataprocessor_multi_comparator_create(self, op, mode, &references, UInt8(references.count), bridgeRetained(obj: source)) { (context, comparator) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let comparator = comparator {
                source.trySet(result: comparator)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create comparator"))
            }
        }
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_delta_create
    /// Change
    public func deltaCreate(mode: MblMwDeltaMode, magnitude: Float) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_delta_create(self, mode, magnitude, bridgeRetained(obj: source)) { (context, delta) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let delta = delta {
                source.trySet(result: delta)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create delta"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_math_create
    /// Simple math ops
    public func mathCreate(op: MblMwMathOperation, rhs: Float, signed: Bool? = nil) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        
        let handler: MblMwFnDataProcessor = { (context, math) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let math = math {
                source.trySet(result: math)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create math"))
            }
        }
        let code: Int32
        switch signed {
        case .none:
            code = mbl_mw_dataprocessor_math_create(self, op, rhs, bridgeRetained(obj: source), handler)
        case .some(true):
            code = mbl_mw_dataprocessor_math_create_signed(self, op, rhs, bridgeRetained(obj: source), handler)
        case .some(false):
            code = mbl_mw_dataprocessor_math_create_unsigned(self, op, rhs, bridgeRetained(obj: source), handler)
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_packer_create
    /// Pack
    public func packerCreate(count: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_packer_create(self, count, bridgeRetained(obj: source)) { (context, packer) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let packer = packer {
                source.trySet(result: packer)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create packer"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_passthrough_create
    /// Passthrough
    public func passthroughCreate(mode: MblMwPassthroughMode, count: UInt16) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_passthrough_create(self, mode, count, bridgeRetained(obj: source)) { (context, passthrough) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let passthrough = passthrough {
                source.trySet(result: passthrough)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create passthrough"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_pulse_create
    /// Pulse detector
    public func pulseCreate(operation: MblMwPulseOutput, threshold: Float, width: UInt16) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_pulse_create(self, operation, threshold, width, bridgeRetained(obj: source)) { (context, success) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let success = success {
                source.trySet(result: success)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create pulse"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_sample_create
    /// Sample
    public func sampleCreate(binSize: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_sample_create(self, binSize, bridgeRetained(obj: source)) { (context, sample) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let sample = sample {
                source.trySet(result: sample)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create sample"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_threshold_create
    public func thresholdCreate(mode: MblMwThresholdMode, boundary: Float, hysteresis: Float) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_threshold_create(self, mode, boundary, hysteresis, bridgeRetained(obj: source)) { (context, threshold) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let threshold = threshold {
                source.trySet(result: threshold)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create threshold"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }
    
    /// Tasky interface to mbl_mw_dataprocessor_fuser_create
    public func fuserCreate(with: OpaquePointer) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        var array: [OpaquePointer?] = [with]
        let code = mbl_mw_dataprocessor_fuser_create(self, UnsafeMutablePointer(&array), 1,  bridgeRetained(obj: source)) { (context, delta) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let delta = delta {
                source.trySet(result: delta)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create fuser"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }

}

private func errorForCode(_ code: Int) -> String? {
    switch code {
    case MBL_MW_STATUS_WARNING_UNEXPECTED_SENSOR_DATA:
        return "Data unexpectedly received from a sensor"
    case MBL_MW_STATUS_WARNING_INVALID_PROCESSOR_TYPE:
        return "Invalid processor passed into a dataprocessor function"
    case MBL_MW_STATUS_ERROR_UNSUPPORTED_PROCESSOR:
        return "Processor not supported for the data signal"
    case MBL_MW_STATUS_WARNING_INVALID_RESPONSE:
        return "Invalid response receieved from the MetaWear notify characteristic"
    case MBL_MW_STATUS_ERROR_TIMEOUT:
        return "Timeout occured during an asynchronous operation"
    case MBL_MW_STATUS_ERROR_SERIALIZATION_FORMAT:
        return "Cannot restore API state given the input serialization format"
    case MBL_MW_STATUS_ERROR_ENABLE_NOTIFY:
        return "Failed to enable notifications"
    default:
       return nil
    }
}

private func errorCheck<T>(code: Int, source: TaskCompletionSource<T>) {
    if let error = errorForCode(code) {
        source.trySet(error: MetaWearError.operationFailed(message: error))
    }
}
