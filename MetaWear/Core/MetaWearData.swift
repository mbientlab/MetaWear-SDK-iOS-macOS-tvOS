/**
 * MetaWearData.swift
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

import MetaWearCpp


/// Native swift struct for holding data from the MetaWear
/// This was created because the C++ library destroys MblMwData objects
/// after the callbacks, but sometimes we need them to live longer
public struct MetaWearData {
    public let timestamp: Date
    let data: [UInt8]
    let typeId: MblMwDataTypeId
    
    public func valueAs<T>() -> T {
        return doTheParse(length: UInt8(data.count), type_id: typeId, value: UnsafeRawPointer(data))
    }
}

extension MblMwData {
    public func copy() -> MetaWearData {
        let arrayPtr = value.bindMemory(to: UInt8.self, capacity: Int(length))
        return MetaWearData(timestamp: timestamp,
                            data: Array(UnsafeBufferPointer(start: arrayPtr, count: Int(length))),
                            typeId: type_id)
    }
    public var timestamp: Date {
        let date = Date(timeIntervalSince1970: Double(epoch) / 1000.0)
        let milliseconds = epoch%1000
        return Calendar.current.date(byAdding: .nanosecond, value: Int(milliseconds), to: date)!
    }
    public func valueAs<T>() -> T {
        return doTheParse(length: length, type_id: type_id, value: value)
    }
    public func extraAs<T>() -> T {
        return extra.bindMemory(to: T.self, capacity: 1).pointee
    }
}

fileprivate func doTheParse<T>(length: UInt8, type_id: MblMwDataTypeId, value: UnsafeRawPointer) -> T {
    guard type_id != MBL_MW_DT_ID_STRING else {
        assert(T.self == String.self || T.self == String?.self)
        return String(cString: value.assumingMemoryBound(to: CChar.self)) as! T
    }
    guard type_id != MBL_MW_DT_ID_BYTE_ARRAY else {
        assert(T.self == [UInt8].self)
        let buffer = UnsafeRawBufferPointer(start: value, count: Int(length))
        return Array(buffer) as! T
    }
    guard type_id != MBL_MW_DT_ID_DATA_ARRAY else {
        assert(T.self == [MblMwData].self)
        let count = Int(length) / MemoryLayout<UnsafePointer<MblMwData>>.size
        let pointer = value.bindMemory(to: UnsafePointer<MblMwData>.self, capacity: count)
        let buffer = UnsafeBufferPointer(start: pointer, count: count)
        return buffer.map { $0.pointee } as! T
    }
    // Generalized flow
    assert(MemoryLayout<T>.size == length)
    switch type_id {
    case MBL_MW_DT_ID_UINT32:
        assert(T.self == UInt32.self)
    case MBL_MW_DT_ID_FLOAT:
        assert(T.self == Float.self)
    case MBL_MW_DT_ID_CARTESIAN_FLOAT:
        assert(T.self == MblMwCartesianFloat.self)
    case MBL_MW_DT_ID_INT32:
        assert(T.self == Int32.self)
    case MBL_MW_DT_ID_BATTERY_STATE:
        assert(T.self == MblMwBatteryState.self)
    case MBL_MW_DT_ID_TCS34725_ADC:
        assert(T.self == MblMwTcs34725ColorAdc.self)
    case MBL_MW_DT_ID_EULER_ANGLE:
        assert(T.self == MblMwEulerAngles.self)
    case MBL_MW_DT_ID_QUATERNION:
        assert(T.self == MblMwQuaternion.self)
    case MBL_MW_DT_ID_CORRECTED_CARTESIAN_FLOAT:
        assert(T.self == MblMwCorrectedCartesianFloat.self)
    case MBL_MW_DT_ID_OVERFLOW_STATE:
        assert(T.self == MblMwOverflowState.self)
    case MBL_MW_DT_ID_SENSOR_ORIENTATION:
        assert(T.self == MblMwSensorOrientation.self)
    case MBL_MW_DT_ID_LOGGING_TIME:
        assert(T.self == MblMwLoggingTime.self)
    case MBL_MW_DT_ID_BTLE_ADDRESS:
        assert(T.self == MblMwBtleAddress.self)
    case MBL_MW_DT_ID_BOSCH_ANY_MOTION:
        assert(T.self == MblMwBoschAnyMotion.self)
    case MBL_MW_DT_ID_BOSCH_GESTURE:
        assert(T.self == MblMwBoschGestureType.self)
    case MBL_MW_DT_ID_CALIBRATION_STATE:
        assert(T.self == MblMwCalibrationState.self)
    case MBL_MW_DT_ID_BOSCH_TAP:
        assert(T.self == MblMwBoschTap.self)
    default:
        fatalError("unknown data type")
    }
    return value.bindMemory(to: T.self, capacity: 1).pointee
}
