/**
 * Tests.swift
 * MetaWear-Tests
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
    }
    
    func testAccelData() {
        let expectation = XCTestExpectation(description: "get accel data")
        // Set the max range of the accelerometer
        mbl_mw_acc_set_range(device.board, 8.0)
        mbl_mw_acc_write_acceleration_config(device.board)
        let accSignal = mbl_mw_acc_get_acceleration_data_signal(device.board)
        mbl_mw_datasignal_subscribe(accSignal, bridge(obj: self)) { (context, dataPtr) in
            let this: Tests = bridge(ptr: context!)
            print(dataPtr!.pointee.valueAs() as MblMwCartesianFloat)
            this.data.append(dataPtr!.pointee.copy())
        }
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
    
    
    func testLinkSaturation() {
        expectation = XCTestExpectation(description: "wait to get all")
        // Set the max range of the accelerometer
        device.logDelegate = ConsoleLogger.shared
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
    
    func testFuser() {
        expectation = XCTestExpectation(description: "expectation")
        let board = device.board
        let accSignal = mbl_mw_acc_get_acceleration_data_signal(board)!
        let gyroSignal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        accSignal.fuserCreate(with: gyroSignal).continueWith { t in
            guard let fused = t.result else {
                XCTFail(t.error!.localizedDescription)
                self.expectation?.fulfill()
                return
            }
            mbl_mw_datasignal_subscribe(fused,  bridgeRetained(obj: self)) { (context, dataPtr) in
                let this: Tests = bridge(ptr: context!)
                
                let timestamp = dataPtr!.pointee.timestamp
                let fused: [MblMwData] = dataPtr!.pointee.valueAs()
                let acc: MblMwCartesianFloat = fused[0].valueAs()
                let gyro: MblMwCartesianFloat = fused[1].valueAs()
                print("\(timestamp) \(acc)")
                print("\(timestamp) \(gyro)")
                
                if (this.counter == 1000) {
                    mbl_mw_debug_reset(this.device.board)
                    this.expectation?.fulfill()
                }
                this.counter += 1
            }
            
            mbl_mw_acc_set_odr(board, 50)
            mbl_mw_acc_write_acceleration_config(board)
            mbl_mw_acc_enable_acceleration_sampling(board)
            mbl_mw_acc_start(board)
            
            mbl_mw_gyro_bmi160_set_odr(board, MBL_MW_GYRO_BMI160_ODR_50Hz)
            mbl_mw_gyro_bmi160_write_config(board)
            mbl_mw_gyro_bmi160_enable_rotation_sampling(board)
            mbl_mw_gyro_bmi160_start(board)
            
        }
        wait(for: [expectation!], timeout: 30)
    }
}
