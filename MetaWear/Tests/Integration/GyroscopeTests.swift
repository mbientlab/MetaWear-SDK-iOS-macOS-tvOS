//
//  GyroscopeTests.swift
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

class GyroscopeTests: XCTestCase {
    var device: MetaWear!
    var data: [MetaWearData] = []
    var waitForDisconnection: Task<MetaWear>?
    var expectation: XCTestExpectation?
    var counter: Int = 0
    var handlers = MblMwLogDownloadHandler()
    
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
    
    func testGyroBMI160Data() {
        let expectation = XCTestExpectation(description: "get gyro data")
        // Set the max range of the accelerometer
        mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BOSCH_RANGE_2000dps)
        mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BOSCH_ODR_50Hz)
        mbl_mw_gyro_bmi160_write_config(device.board)
        // Get acc signal
        let gyroSignal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)
        mbl_mw_datasignal_subscribe(gyroSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: GyroscopeTests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as MblMwCartesianFloat)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start sampling and start acc
        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi160_start(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_gyro_bmi160_stop(self.device.board)
            mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(gyroSignal)
            for entry in self.data {
                let pt: MblMwCartesianFloat = entry.valueAs()
                print("\(pt.x) \(pt.y) \(pt.z)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testGyroBMI270Data() {
        let expectation = XCTestExpectation(description: "get gyro data")
        // Set the max range of the accelerometer
        mbl_mw_gyro_bmi270_set_range(device.board, MBL_MW_GYRO_BOSCH_RANGE_2000dps)
        mbl_mw_gyro_bmi270_set_odr(device.board, MBL_MW_GYRO_BOSCH_ODR_50Hz)
        mbl_mw_gyro_bmi270_write_config(device.board)
        // Get acc signal
        let gyroSignal = mbl_mw_gyro_bmi270_get_rotation_data_signal(device.board)
        mbl_mw_datasignal_subscribe(gyroSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: GyroscopeTests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as MblMwCartesianFloat)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start sampling and start acc
        mbl_mw_gyro_bmi270_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi270_start(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_gyro_bmi270_stop(self.device.board)
            mbl_mw_gyro_bmi270_disable_rotation_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(gyroSignal)
            for entry in self.data {
                let pt: MblMwCartesianFloat = entry.valueAs()
                print("\(pt.x) \(pt.y) \(pt.z)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testGyroBMI160PackedData() {
        let expectation = XCTestExpectation(description: "get gyro packed data")
        // Set the max range of the accelerometer
        mbl_mw_gyro_bmi160_set_range(device.board, MetaWearCpp.MBL_MW_GYRO_BOSCH_RANGE_2000dps)
        mbl_mw_gyro_bmi160_set_odr(device.board, MetaWearCpp.MBL_MW_GYRO_BOSCH_ODR_100Hz)
        mbl_mw_gyro_bmi160_write_config(device.board)
        // Get acc signal
        let gyroSignal = mbl_mw_gyro_bmi160_get_packed_rotation_data_signal(device.board)
        mbl_mw_datasignal_subscribe(gyroSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: GyroscopeTests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as MblMwCartesianFloat)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start sampling and start acc
        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi160_start(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_gyro_bmi160_stop(self.device.board)
            mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(gyroSignal)
            for entry in self.data {
                let pt: MblMwCartesianFloat = entry.valueAs()
                print("\(pt.x) \(pt.y) \(pt.z)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testGyroBMI270PackedData() {
        let expectation = XCTestExpectation(description: "get gyro packed data")
        // Set the max range of the accelerometer
        mbl_mw_gyro_bmi270_set_range(device.board, MetaWearCpp.MBL_MW_GYRO_BOSCH_RANGE_2000dps)
        mbl_mw_gyro_bmi270_set_odr(device.board, MetaWearCpp.MBL_MW_GYRO_BOSCH_ODR_100Hz)
        mbl_mw_gyro_bmi270_write_config(device.board)
        // Get acc signal
        let gyroSignal = mbl_mw_gyro_bmi270_get_packed_rotation_data_signal(device.board)
        mbl_mw_datasignal_subscribe(gyroSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: GyroscopeTests = bridge(ptr: context!)
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:m:ss.SSSS"
            let date = df.string(from: dataPtr!.pointee.timestamp) // -> "2016-11-17 17:51:15.1720"
            print(dataPtr!.pointee.epoch, date, dataPtr!.pointee.valueAs() as MblMwCartesianFloat)
            this.data.append(dataPtr!.pointee.copy())
        }
        // Start sampling and start acc
        mbl_mw_gyro_bmi270_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi270_start(device.board)
        // Stop after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Stop the stream
            mbl_mw_gyro_bmi270_stop(self.device.board)
            mbl_mw_gyro_bmi270_disable_rotation_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(gyroSignal)
            for entry in self.data {
                let pt: MblMwCartesianFloat = entry.valueAs()
                print("\(pt.x) \(pt.y) \(pt.z)")
            }
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
    }
    
}
