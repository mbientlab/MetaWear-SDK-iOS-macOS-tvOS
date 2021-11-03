//
//  Tests.swift
//  MetaWear
//
//  Created by Laura Kassovic on 3/18/21.
//  Copyright © 2021 Stephen Schiffli. All rights reserved.
//

import XCTest
import BoltsSwift
@testable import MetaWear
@testable import MetaWearCpp

class Tests: XCTestCase {
    var device: MetaWear!
    var data: [MetaWearData] = []
    var waitForDisconnection: Task<MetaWear>?
    var expectation: XCTestExpectation?
    var counter: Int = 0
    var handlers = MblMwLogDownloadHandler()
    var fuser: OpaquePointer!
    
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
    
    func testONLED() {
        expectation = XCTestExpectation(description: "led device")
        // Hooray! We connected to a MetaWear board, so flash its LED!
        var pattern = MblMwLedPattern()
        mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_BLINK)
        mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_GREEN)
        mbl_mw_led_play(device.board)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            mbl_mw_debug_disconnect(self.device.board)
            self.expectation!.fulfill()
        }
    }
    
    func testOFFLED() {
        expectation = XCTestExpectation(description: "led device")
        mbl_mw_led_stop_and_clear(device.board)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            mbl_mw_debug_disconnect(self.device.board)
            self.expectation!.fulfill()
        }
    }
    
    func testSetDeviceName() {
        expectation = XCTestExpectation(description: "rename device")
        let name = "TEMPY"
        mbl_mw_settings_set_device_name(device.board, name, UInt8(name.count))
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            mbl_mw_debug_disconnect(self.device.board)
            self.expectation!.fulfill()
        }
    }
    
    func testSetDeviceNamePermanently() {
        expectation = XCTestExpectation(description: "rename device")
        let name = "TEMPY"
        mbl_mw_macro_record(device.board, 1)
        mbl_mw_settings_set_device_name(device.board, name, UInt8(name.count))
        mbl_mw_macro_end_record(device.board, bridgeRetained(obj: self)) { (context, board, value) in
            print("macro done")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            mbl_mw_debug_disconnect(self.device.board)
            self.expectation!.fulfill()
        }
    }
    
    func testLinkSaturation() {
        expectation = XCTestExpectation(description: "wait to get all")
        // Set the max range of the accelerometer
        let signal = mbl_mw_debug_get_key_register_data_signal(device.board)
        mbl_mw_datasignal_subscribe(signal,  bridgeRetained(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            let val: UInt32 = dataPtr!.pointee.valueAs()
            XCTAssertEqual(this.counter, Int(val))
            if (this.counter == 1000) {
                this.expectation?.fulfill()
            }
            this.counter += 1
        }
        device.apiAccessQueue.async {
            self.counter = 1
            for i in 1...1000 {
                mbl_mw_debug_set_key_register(self.device.board, UInt32(i))
                mbl_mw_datasignal_read(signal)
            }
        }
        wait(for: [expectation!], timeout: 30)
    }
    
    func testRSSI() {
        expectation = XCTestExpectation(description: "expectation")
        device.readRSSI().continueWith { t in
            XCTAssertFalse(t.faulted)
            print(t.result ?? 0)
            self.expectation?.fulfill()
        }
        wait(for: [expectation!], timeout: 30)
    }
    
    func testBMI160Fuser() {
        expectation = XCTestExpectation(description: "get accel logger")
        mbl_mw_acc_set_odr(device.board, 25)
        mbl_mw_acc_write_acceleration_config(device.board)
        let accSignal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BOSCH_ODR_25Hz)
        mbl_mw_gyro_bmi160_write_config(device.board)
        let gyroSignal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
        accSignal.fuserCreate(with: gyroSignal).continueOnSuccessWith { fuser in
            mbl_mw_datasignal_log(fuser, bridge(obj: self)) { (context, logger) in
                let this: Tests = bridge(ptr: context!)
                this.fuser = logger!
                print("Started logger: ", this.fuser)
            }
        }
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi160_start(device.board)
        mbl_mw_logging_start(device.board, 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_gyro_bmi160_stop(self.device.board)
            mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
            mbl_mw_logging_stop(self.device.board)
            mbl_mw_logging_flush_page(self.device.board)
            let fuserLogger = self.fuser
            mbl_mw_logger_subscribe(fuserLogger, bridge(obj: self), { (context, obj) in
                print(obj!.pointee.epoch, obj!.pointee)
            })
            self.handlers.context = bridge(obj: self)
            self.handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
                let this: Tests = bridge(ptr: context!)
                if remainingEntries == 0 {
                    this.expectation?.fulfill()
                }
            }
            self.handlers.received_unknown_entry = { (context, id, epoch, data, length) in
                print("received_unknown_entry")
            }
            self.handlers.received_unhandled_entry = { (context, data) in
                print("received_unhandled_entry")
            }
            mbl_mw_logging_download(self.device.board, 0, &self.handlers)
        }
        wait(for: [expectation!], timeout: 60)
    }
    
    func testBMI270Fuser() {
        expectation = XCTestExpectation(description: "get accel logger")
        mbl_mw_acc_set_odr(device.board, 25)
        mbl_mw_acc_write_acceleration_config(device.board)
        let accSignal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_gyro_bmi270_set_odr(device.board, MBL_MW_GYRO_BOSCH_ODR_25Hz)
        mbl_mw_gyro_bmi270_write_config(device.board)
        let gyroSignal = mbl_mw_gyro_bmi270_get_rotation_data_signal(device.board)!
        accSignal.fuserCreate(with: gyroSignal).continueOnSuccessWith { fuser in
            mbl_mw_datasignal_log(fuser, bridge(obj: self)) { (context, logger) in
                let this: Tests = bridge(ptr: context!)
                this.fuser = logger!
                print("Started logger: ", this.fuser)
            }
        }
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        mbl_mw_gyro_bmi270_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi270_start(device.board)
        mbl_mw_logging_start(device.board, 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_gyro_bmi270_stop(self.device.board)
            mbl_mw_gyro_bmi270_disable_rotation_sampling(self.device.board)
            mbl_mw_logging_stop(self.device.board)
            mbl_mw_logging_flush_page(self.device.board)
            let fuserLogger = self.fuser
            mbl_mw_logger_subscribe(fuserLogger, bridge(obj: self), { (context, obj) in
                print(obj!.pointee.epoch, obj!.pointee)
            })
            self.handlers.context = bridge(obj: self)
            self.handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
                let this: Tests = bridge(ptr: context!)
                if remainingEntries == 0 {
                    this.expectation?.fulfill()
                }
            }
            self.handlers.received_unknown_entry = { (context, id, epoch, data, length) in
                print("received_unknown_entry")
            }
            self.handlers.received_unhandled_entry = { (context, data) in
                print("received_unhandled_entry")
            }
            mbl_mw_logging_download(self.device.board, 0, &self.handlers)
        }
        wait(for: [expectation!], timeout: 60)
    }
 
    func testLogSensorFusion() {
        expectation = XCTestExpectation(description: "expectation")
        let accelRange = MBL_MW_SENSOR_FUSION_ACC_RANGE_16G
        let gyroRange = MBL_MW_SENSOR_FUSION_GYRO_RANGE_2000DPS
        let sensorFusionMode = MBL_MW_SENSOR_FUSION_MODE_IMU_PLUS
        mbl_mw_sensor_fusion_set_acc_range(device.board, accelRange)
        mbl_mw_sensor_fusion_set_gyro_range(device.board, gyroRange)
        mbl_mw_sensor_fusion_set_mode(device.board, sensorFusionMode)
        let eulerSignal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)!
        mbl_mw_datasignal_log(eulerSignal, bridge(obj: self)) { (context, logger) in
            let this: Tests = bridge(ptr: context!)
            this.fuser = logger!
            print("Started logger: ", this.fuser)
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_sensor_fusion_clear_enabled_mask(device.board)
        mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)
        mbl_mw_sensor_fusion_write_config(device.board)
        mbl_mw_sensor_fusion_start(device.board)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            mbl_mw_sensor_fusion_stop(self.device.board)
            mbl_mw_sensor_fusion_clear_enabled_mask(self.device.board)
            let fusionLogger = self.fuser
            mbl_mw_logger_subscribe(fusionLogger, bridge(obj: self), { (context, dataPtr) in
                let timestamp = dataPtr!.pointee.timestamp
                let euler: MblMwEulerAngles = dataPtr!.pointee.valueAs()
                print("euler : \(timestamp) \(euler)")
            })
            self.handlers.context = bridge(obj: self)
            self.handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
                if remainingEntries == 0 {
                    print("done \(Date())")
                    let this: Tests = bridge(ptr: context!)
                    this.expectation?.fulfill()
                }
            }
            self.handlers.received_unknown_entry = { (context, id, epoch, data, length) in
                print("received_unknown_entry")
            }
            self.handlers.received_unhandled_entry = { (context, data) in
                print("received_unhandled_entry")
            }
            mbl_mw_logging_download(self.device.board, 0, &self.handlers)
            print("stopping \(Date())")
        }
        wait(for: [expectation!], timeout: 300)
    }
    
    func testEuler() {
        expectation = XCTestExpectation(description: "expectation")
        let accelRange = MBL_MW_SENSOR_FUSION_ACC_RANGE_16G
        let gyroRange = MBL_MW_SENSOR_FUSION_GYRO_RANGE_2000DPS
        let sensorFusionMode = MBL_MW_SENSOR_FUSION_MODE_IMU_PLUS
        mbl_mw_sensor_fusion_set_acc_range(device.board, accelRange)
        mbl_mw_sensor_fusion_set_gyro_range(device.board, gyroRange)
        mbl_mw_sensor_fusion_set_mode(device.board, sensorFusionMode)
        let eulerSignal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)!
        mbl_mw_datasignal_subscribe(eulerSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            print(dataPtr!.pointee.valueAs() as MblMwEulerAngles)
            this.data.append(dataPtr!.pointee.copy())
        }
        mbl_mw_sensor_fusion_clear_enabled_mask(device.board)
        mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)
        mbl_mw_sensor_fusion_write_config(device.board)
        mbl_mw_sensor_fusion_start(device.board)
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            mbl_mw_sensor_fusion_stop(self.device.board)
            mbl_mw_sensor_fusion_clear_enabled_mask(self.device.board)
            for entry in self.data {
                let pt: MblMwEulerAngles = entry.valueAs()
                print("\(pt)")
            }
            self.expectation?.fulfill()
        }
        wait(for: [expectation!], timeout: 300)
    }
    
    func testReadMacro() {
        expectation = XCTestExpectation(description: "expectation")
        let board = device.board
        for i: UInt8 in 0..<8 {
            let cmd: [UInt8] = [0x0F, 0x82, i]
            mbl_mw_debug_send_command(board, cmd, UInt8(cmd.count))
        }
        expectation?.fulfill() //FIX ME, FULFILL AFTER ALL RESPONSES RECEIVED
        wait(for: [expectation!], timeout: 30)
    }
    
}

