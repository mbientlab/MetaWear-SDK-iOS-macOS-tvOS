//
//  AccelerometerTests.swift
//  MetaWear
//
//  Created by Laura Kassovic on 2/12/21.
//  Copyright © 2021 Stephen Schiffli. All rights reserved.
//

import Foundation
import XCTest
import BoltsSwift
@testable import MetaWear
@testable import MetaWearCpp

class AccelerometerTests: XCTestCase {
    var device: MetaWear!
    var data: [MetaWearData] = []
    var waitForDisconnection: Task<MetaWear>?
    var expectation: XCTestExpectation?
    var counter: Int = 0
    var handlers = MblMwLogDownloadHandler()
    var logger: OpaquePointer?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let connectExpectation = XCTestExpectation(description: "connecting")
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
            guard let rssi = device.averageRSSI(), rssi > -50 else {
                return
            }
            
            if (device.averageRSSI() ?? -100) > -50 {
                MetaWearScanner.shared.stopScan()
                self.device = device
                device.logDelegate = ConsoleLogger.shared
                device.connectAndSetup().continueWith { t -> () in
                    if let error = t.error {
                        self.continueAfterFailure = false
                        XCTFail(error.localizedDescription)
                    }
                    self.waitForDisconnection = t.result
                    connectExpectation.fulfill()
                }
            }
        }
        wait(for: [connectExpectation], timeout: 60)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        guard let task = self.waitForDisconnection else {
            return
        }
        
        let disconnectExpectation = XCTestExpectation(description: "disconnecting")
        task.continueWith { _ -> () in
            disconnectExpectation.fulfill()
            return ()
        }
        mbl_mw_debug_disconnect(device.board)
        wait(for: [disconnectExpectation], timeout: 60)
    }
    
    func testConnection() {
        if (!device.isMetaBoot) {
            print(device.mac!)
        }
        print(device.info!.firmwareRevision)
        print(device.info!.hardwareRevision)
        print(device.info!.manufacturer)
        print(device.info!.modelNumber)
        print(device.info!.serialNumber)
        device.clearAndReset()
    }
    
    func testReadAccelDataConfig() {
        let expectation = XCTestExpectation(description: "get accel data config")
        mbl_mw_acc_read_config(device.board, bridge(obj: self)) { (context, board, value) in
            let i16 = context!.load(as: UInt16.self)
            print(i16)
            let i16bufptr = UnsafeBufferPointer(start: context!.assumingMemoryBound(to: UInt16.self), count: 1)
            let i16array = Array(i16bufptr)
            print(i16array)
            let i8bufptr = UnsafeBufferPointer(start: context!.assumingMemoryBound(to: UInt8.self), count: 2)
            let i8array = Array(i8bufptr)
            print(i8array)
            switch MblMwAccBmi160Odr(rawValue: UInt32((i8array[0] & 0x0F))) {
            case MBL_MW_ACC_BMI160_ODR_0_78125Hz:
                print("ODR = .78125Hz")
            case MBL_MW_ACC_BMI160_ODR_1_5625Hz:
                print("ODR = 1.5625Hz")
            case MBL_MW_ACC_BMI160_ODR_3_125Hz:
                print("ODR = 3.125Hz")
            case MBL_MW_ACC_BMI160_ODR_6_25Hz:
                print("ODR = 6.25Hz")
            case MBL_MW_ACC_BMI160_ODR_12_5Hz:
                print("ODR = 12.5Hz")
            case MBL_MW_ACC_BMI160_ODR_25Hz:
                print("ODR = 25Hz")
            case MBL_MW_ACC_BMI160_ODR_50Hz:
                print("ODR = 50Hz")
            case MBL_MW_ACC_BMI160_ODR_100Hz:
                print("ODR = 100Hz")
            case MBL_MW_ACC_BMI160_ODR_200Hz:
                print("ODR = 200Hz")
            case MBL_MW_ACC_BMI160_ODR_400Hz:
                print("ODR = 400Hz")
            case MBL_MW_ACC_BMI160_ODR_800Hz:
                print("ODR = 800Hz")
            case MBL_MW_ACC_BMI160_ODR_1600Hz:
                print("ODR = 1600Hz")
            default:
                print("Unknown ODR")
            }
            switch MblMwAccBoschRange(rawValue: UInt32((i8array[1] & 0x0F))) {
            case MBL_MW_ACC_BOSCH_RANGE_2G:
                print("Range = 2G")
            case MBL_MW_ACC_BOSCH_RANGE_4G:
                print("Range = 4G")
            case MBL_MW_ACC_BOSCH_RANGE_8G:
                print("Range = 8G")
            case MBL_MW_ACC_BOSCH_RANGE_16G:
                print("Range = 16G")
            default:
                print("Unknown Range")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testAccelData() {
        let expectation = XCTestExpectation(description: "get accel data")
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 6.25)
        mbl_mw_acc_write_acceleration_config(device.board)
        // Get acc signal
        let accSignal = mbl_mw_acc_get_acceleration_data_signal(device.board) //mbl_mw_acc_bosch_get_acceleration_data_signal
        mbl_mw_datasignal_subscribe(accSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            print(dataPtr!.pointee.valueAs() as MblMwCartesianFloat)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start sampling and start acc
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(accSignal)
            for entry in self.data {
                let pt: MblMwCartesianFloat = entry.valueAs()
                print("\(pt.x) \(pt.y) \(pt.z)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    // NOT CURRENTLY WORKING
    func testAccelPackedData() {
        let expectation = XCTestExpectation(description: "get accel data")
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 6.25)
        mbl_mw_acc_write_acceleration_config(device.board)
        // Get acc signal
        let accSignal = mbl_mw_acc_bosch_get_packed_acceleration_data_signal(device.board) // same as mbl_mw_acc_get_packed_acceleration_data_signal
        mbl_mw_datasignal_subscribe(accSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            print(dataPtr!.pointee.valueAs() as [MblMwCartesianFloat])
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start sampling and start acc
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(accSignal)
            for entry in self.data {
                let pt: [MblMwCartesianFloat] = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testAccelLogging() {
        expectation = XCTestExpectation(description: "get accel logger")
        var handlers = MblMwLogDownloadHandler()
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let this: AccelerometerTests = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            print(identifier)
            this.logger = logger!
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_logger_subscribe(self.logger, bridge(obj: self), { (context, obj) in
                let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
                print(obj!.pointee.epoch, acceleration)//Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z)
            })
            self.handlers.context = bridge(obj: self)
            self.handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
                let this: AccelerometerTests = bridge(ptr: context!)
                if remainingEntries == 0 {
                    print("done")
                    this.expectation?.fulfill()
                }
            }
            handlers.received_unknown_entry = { (context, id, epoch, data, length) in
                print("received_unknown_entry")
            }
            handlers.received_unhandled_entry = { (context, data) in
                print("received_unhandled_entry")
            }
            mbl_mw_logging_download(self.device.board, 0, &self.handlers)
        }
        wait(for: [expectation!], timeout: 35)
    }
    
    func testAccelAnyMotionData() {
        let expectation = XCTestExpectation(description: "get accel any motion data")
        // Start the accelerometer
        mbl_mw_acc_start(device.board)
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0) // Will pick closest acceptable value //mbl_mw_acc_bosch_set_range
        mbl_mw_acc_set_odr(device.board, 100) //Must be at least 25Hz to work features //mbl_mw_acc_bmi160_set_odr //mbl_mw_acc_bmi270_set_odr //mbl_mw_acc_bma255_set_odr
        mbl_mw_acc_write_acceleration_config(device.board) //mbl_mw_acc_bosch_write_acceleration_config
        // Set any motion config - acc must be on for this
        mbl_mw_acc_bosch_set_any_motion_count(device.board, UInt8(5))
        mbl_mw_acc_bosch_set_any_motion_threshold(device.board, 170.0)
        mbl_mw_acc_bosch_write_motion_config(device.board, MBL_MW_ACC_BOSCH_MOTION_ANYMOTION)
        // Get any motion signal
        let accAnyMotionSignal = mbl_mw_acc_bosch_get_motion_data_signal(device.board)
        mbl_mw_datasignal_subscribe(accAnyMotionSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as UInt32)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start detecting motion and turn on acc
        mbl_mw_acc_bosch_enable_motion_detection(device.board, MBL_MW_ACC_BOSCH_MOTION_ANYMOTION)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_acc_bosch_disable_motion_detection(self.device.board, MBL_MW_ACC_BOSCH_MOTION_ANYMOTION)
            // Stop the accelerometer
            mbl_mw_acc_stop(self.device.board)
            // Unsubscribe to any motion
            mbl_mw_datasignal_unsubscribe(accAnyMotionSignal)
            for entry in self.data {
                let pt: UInt32 = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testAccelNoMotionData() {
        let expectation = XCTestExpectation(description: "get accel no motion data")
        // Start the accelerometer
        mbl_mw_acc_start(device.board)
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 100) //Must be at least 25Hz to work features
        mbl_mw_acc_write_acceleration_config(device.board)
        // Set any motion config - acc must be on for this
        mbl_mw_acc_bosch_set_no_motion_count(device.board, UInt8(5))
        mbl_mw_acc_bosch_set_no_motion_threshold(device.board, 144.0)
        mbl_mw_acc_bosch_write_motion_config(device.board, MBL_MW_ACC_BOSCH_MOTION_NOMOTION)
        // Get any motion signal
        let accNoMotionSignal = mbl_mw_acc_bosch_get_motion_data_signal(device.board)
        mbl_mw_datasignal_subscribe(accNoMotionSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as UInt32)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start detecting motion and turn on acc
        mbl_mw_acc_bosch_enable_motion_detection(device.board, MBL_MW_ACC_BOSCH_MOTION_NOMOTION)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_acc_bosch_disable_motion_detection(self.device.board, MBL_MW_ACC_BOSCH_MOTION_NOMOTION)
            // Stop the accelerometer
            mbl_mw_acc_stop(self.device.board)
            // Unsubscribe to any motion
            mbl_mw_datasignal_unsubscribe(accNoMotionSignal)
            for entry in self.data {
                let pt: UInt32 = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testAccelSigMotionData() {
        let expectation = XCTestExpectation(description: "get accel sig motion data")
        // Start the accelerometer
        mbl_mw_acc_start(device.board)
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 100) //Must be at least 25Hz to work features
        mbl_mw_acc_write_acceleration_config(device.board)
        // Set any motion config - acc must be on for this
        mbl_mw_acc_bosch_set_sig_motion_blocksize(device.board, UInt16(250))
        mbl_mw_acc_bosch_write_motion_config(device.board, MBL_MW_ACC_BOSCH_MOTION_SIGMOTION)
        // Get any motion signal
        let accSigMotionSignal = mbl_mw_acc_bosch_get_motion_data_signal(device.board)
        mbl_mw_datasignal_subscribe(accSigMotionSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as UInt32)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start detecting motion and turn on acc
        mbl_mw_acc_bosch_enable_motion_detection(device.board, MBL_MW_ACC_BOSCH_MOTION_SIGMOTION)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_acc_bosch_disable_motion_detection(self.device.board, MBL_MW_ACC_BOSCH_MOTION_SIGMOTION)
            // Stop the accelerometer
            mbl_mw_acc_stop(self.device.board)
            // Unsubscribe to any motion
            mbl_mw_datasignal_unsubscribe(accSigMotionSignal)
            for entry in self.data {
                let pt: UInt32 = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testAccelStepDetectorData() {
        let expectation = XCTestExpectation(description: "get accel step detector data")
        // Start the accelerometer
        mbl_mw_acc_start(device.board)
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 100) //Must be at least 25Hz to work features
        mbl_mw_acc_write_acceleration_config(device.board)
        // Get any motion signal
        let accStepSignal = mbl_mw_acc_bmi270_get_step_detector_data_signal(device.board) //mbl_mw_acc_bmi160_get_step_detector_data_signal
        mbl_mw_datasignal_subscribe(accStepSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, "Step detected")
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start detecting motion and turn on acc
        mbl_mw_acc_bmi270_enable_step_detector(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_acc_bmi270_disable_step_detector(self.device.board)
            // Stop the accelerometer
            mbl_mw_acc_stop(self.device.board)
            // Unsubscribe to any motion
            mbl_mw_datasignal_unsubscribe(accStepSignal)
            for entry in self.data {
                let pt: UInt32 = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testReadAccelStepCounterData() {
        let expectation = XCTestExpectation(description: "read accel step counter data")
        // Read
        mbl_mw_acc_bmi270_read_step_counter(device.board, bridge(obj: self)) { (context, board, value) in
            print("GOT THIS:", value)
        }
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testAccelStepCounterData() {
        let expectation = XCTestExpectation(description: "get accel step counter data")
        // Start the accelerometer
        mbl_mw_acc_start(device.board)
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 100) //Must be at least 25Hz to work features
        mbl_mw_acc_write_acceleration_config(device.board)
        // Write the trigger for the step counter
        mbl_mw_acc_bmi270_set_step_counter_trigger(device.board, 1) //every 20 steps
        mbl_mw_acc_bmi270_write_step_counter_config(device.board)
        // Reset the counter
        mbl_mw_acc_bmi270_reset_step_counter(self.device.board)
        // Get any motion signal
        let accStepSignal = mbl_mw_acc_bmi270_get_step_counter_data_signal(device.board) //mbl_mw_acc_bmi160_get_step_counter_data_signal
        mbl_mw_datasignal_subscribe(accStepSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as UInt32)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start detecting motion and turn on acc
        mbl_mw_acc_bmi270_enable_step_counter(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            // Reset the counter
            mbl_mw_acc_bmi270_reset_step_counter(self.device.board)
            // Stop the stream
            mbl_mw_acc_bmi270_disable_step_counter(self.device.board)
            // Stop the accelerometer
            mbl_mw_acc_stop(self.device.board)
            // Unsubscribe to any motion
            mbl_mw_datasignal_unsubscribe(accStepSignal)
            for entry in self.data {
                let pt: UInt32 = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }

    func testAccelWristGestureData() {
        let expectation = XCTestExpectation(description: "get accel wrist gesture data")
        // Start the accelerometer
        mbl_mw_acc_start(device.board)
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 100) //Must be at least 25Hz to work features
        mbl_mw_acc_write_acceleration_config(device.board)
        // Write the info
        mbl_mw_acc_bmi270_wrist_gesture_armside(device.board, 0) // left arm
        //mbl_mw_acc_bmi270_wrist_gesture_peak(device.board, 0) // TO DO
        //mbl_mw_acc_bmi270_wrist_gesture_samples(device.board, 0) // TO DO
        //mbl_mw_acc_bmi270_wrist_gesture_duration(device.board, 0) // TO DO
        mbl_mw_acc_bmi270_write_wrist_gesture_config(device.board)
        // Get gesture signal
        let accSignal = mbl_mw_acc_bmi270_get_wrist_detector_data_signal(device.board)
        mbl_mw_datasignal_subscribe(accSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as MblMwBoschGestureType)
            let val = dataPtr!.pointee.valueAs() as MblMwBoschGestureType
            switch MblMwAccBoschTypewrist(UInt32(val.type)) {
                case MBL_MW_ACC_BOSCH_TYPEWRIST_GESTURE:
                    switch MblMwAccBoschGesture(UInt32(val.gesture_code)) {
                        case MBL_MW_ACC_BOSCH_GESTURE_UNKNOWN:
                                print("unknown")
                        case MBL_MW_ACC_BOSCH_GESTURE_PUSH_ARM_DOWN:
                                print("push arm down")
                        case MBL_MW_ACC_BOSCH_GESTURE_PIVOT_UP:
                                print("pivot up")
                        case MBL_MW_ACC_BOSCH_GESTURE_SHAKE:
                                print("shake")
                        case MBL_MW_ACC_BOSCH_GESTURE_ARM_FLICK_IN:
                                print("arm flick in")
                        case MBL_MW_ACC_BOSCH_GESTURE_ARM_FLICK_OUT:
                                print("arm flick out")
                        default:
                                print("none")
                    }
                case MBL_MW_ACC_BOSCH_TYPEWRIST_WEARK_WAKEUP:
                    print("wrist wakeup")
                default:
                    print("none")
            }
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start detecting motion and turn on acc
        mbl_mw_acc_bmi270_enable_wrist_gesture(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            // Stop the stream
            mbl_mw_acc_bmi270_disable_wrist_gesture(self.device.board)
            // Stop the accelerometer
            mbl_mw_acc_stop(self.device.board)
            // Unsubscribe to any motion
            mbl_mw_datasignal_unsubscribe(accSignal)
            for entry in self.data {
                let pt: MblMwBoschGestureType = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testAccelWristWakeupData() {
        let expectation = XCTestExpectation(description: "get accel wrist gesture data")
        // Start the accelerometer
        mbl_mw_acc_start(device.board)
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 100) //Must be at least 25Hz to work features
        mbl_mw_acc_write_acceleration_config(device.board)
        // Write the info
        //mbl_mw_acc_bmi270_wrist_wakeup_angle_focus // TO DO
        //mbl_mw_acc_bmi270_wrist_wakeup_angle_nonfocus // TO DO
        //mbl_mw_acc_bmi270_wrist_wakeup_tilt_lr // TO DO
        //mbl_mw_acc_bmi270_wrist_wakeup_tilt_ll // TO DO
        //mbl_mw_acc_bmi270_wrist_wakeup_tilt_pd // TO DO
        //mbl_mw_acc_bmi270_wrist_wakeup_tilt_pu // TO DO
        mbl_mw_acc_bmi270_write_wrist_wakeup_config(device.board)
        // Get gesture signal
        let accSignal = mbl_mw_acc_bmi270_get_wrist_detector_data_signal(device.board)
        mbl_mw_datasignal_subscribe(accSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as MblMwBoschGestureType)
            let val = dataPtr!.pointee.valueAs() as MblMwBoschGestureType
            switch MblMwAccBoschTypewrist(UInt32(val.type)) {
                case MBL_MW_ACC_BOSCH_TYPEWRIST_GESTURE:
                    switch MblMwAccBoschGesture(UInt32(val.gesture_code)) {
                        case MBL_MW_ACC_BOSCH_GESTURE_UNKNOWN:
                                print("unknown")
                        case MBL_MW_ACC_BOSCH_GESTURE_PUSH_ARM_DOWN:
                                print("push arm down")
                        case MBL_MW_ACC_BOSCH_GESTURE_PIVOT_UP:
                                print("pivot up")
                        case MBL_MW_ACC_BOSCH_GESTURE_SHAKE:
                                print("shake")
                        case MBL_MW_ACC_BOSCH_GESTURE_ARM_FLICK_IN:
                                print("arm flick in")
                        case MBL_MW_ACC_BOSCH_GESTURE_ARM_FLICK_OUT:
                                print("arm flick out")
                        default:
                                print("none")
                    }
                case MBL_MW_ACC_BOSCH_TYPEWRIST_WEARK_WAKEUP:
                    print("wrist wakeup")
                default:
                    print("none")
            }
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start detecting motion and turn on acc
        mbl_mw_acc_bmi270_enable_wrist_wakeup(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            // Stop the stream
            mbl_mw_acc_bmi270_disable_wrist_wakeup(self.device.board)
            // Stop the accelerometer
            mbl_mw_acc_stop(self.device.board)
            // Unsubscribe to any motion
            mbl_mw_datasignal_unsubscribe(accSignal)
            for entry in self.data {
                let pt: MblMwBoschGestureType = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testAccelActivityData() {
        let expectation = XCTestExpectation(description: "get accel activity data")
        // Start the accelerometer
        mbl_mw_acc_start(device.board)
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_set_odr(device.board, 100) //Must be at least 25Hz to work features
        mbl_mw_acc_write_acceleration_config(device.board)
        // Get gesture signal
        let accSignal = mbl_mw_acc_bmi270_get_activity_detector_data_signal(device.board)
        mbl_mw_datasignal_subscribe(accSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as UInt32)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start detecting motion and turn on acc
        mbl_mw_acc_bmi270_enable_activity_detection(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
            // Stop the stream
            mbl_mw_acc_bmi270_disable_activity_detection(self.device.board)
            // Stop the accelerometer
            mbl_mw_acc_stop(self.device.board)
            // Unsubscribe to any motion
            mbl_mw_datasignal_unsubscribe(accSignal)
            for entry in self.data {
                let pt: UInt32 = entry.valueAs()
                print("\(pt)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
}
