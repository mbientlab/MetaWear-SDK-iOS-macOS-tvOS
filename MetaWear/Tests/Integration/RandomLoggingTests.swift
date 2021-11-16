//
//  RandomLoggingTests.swift
//  MetaWear
//
//  Created by Laura Kassovic on 11/16/21.
//  Copyright © 2021 Stephen Schiffli. All rights reserved.
//

import Foundation
import XCTest
import BoltsSwift
@testable import MetaWear
@testable import MetaWearCpp

class RandomLoggingTests: XCTestCase {
    var device: MetaWear!
    var data: [MetaWearData] = []
    var waitForDisconnection: Task<MetaWear>?
    var expectation: XCTestExpectation?
    var counter: Int = 0
    var handlers = MblMwLogDownloadHandler()
    var rawHandlers = MblMwRawLogDownloadHandler()
    var logger: OpaquePointer?
    var loggers: [String: OpaquePointer] = [:]
    var loggerID: UInt8 = 0
    var identifier: String?
    var signal: OpaquePointer?
    
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
    
    // WHEN LOGGING HAS BEEN SET BY A DIFFERENT DEVICE
    func testDeviceConnectedReadAnonymousLoggers() {
        expectation = XCTestExpectation(description: "find anonym logger")
        let task = device.createAnonymousDatasignals()
        task.continueWith(.mainThread) { t in
            if let signals = t.result {
                for signal in signals {
                    let cString = mbl_mw_anonymous_datasignal_get_identifier(signal)!
                    let identifier = String(cString: cString)
                    self.loggers[identifier] = signal
                    print("CURRENTLY LOGGING ", identifier, " as signal ", signal)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.expectation!.fulfill()
        }
        wait(for: [expectation!], timeout: 60)
    }
    
    // WHEN LOGGING HAS BEEN SET BY A DIFFERENT DEVICE
    func testDeviceConnectedRemoveAnonymousLoggers() {
        expectation = XCTestExpectation(description: "remove anonym logger")
        let task = device.createAnonymousDatasignals()
        task.continueWith(.mainThread) { t in
            if let signals = t.result {
                for signal in signals {
                    let cString = mbl_mw_anonymous_datasignal_get_identifier(signal)!
                    let identifier = String(cString: cString)
                    self.loggers[identifier] = signal
                    print("STOP LOGGING ", identifier, " as signal ", signal)
                    mbl_mw_logger_remove(signal)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.expectation!.fulfill()
        }
        wait(for: [expectation!], timeout: 60)
    }
    
    // WHEN LOGGING HAS BEEN SET BY A DIFFERENT DEVICE
    func testDeviceConnectedDownloadAnonymousLoggers() {
        expectation = XCTestExpectation(description: "get anonym logger")
        let task = device.createAnonymousDatasignals()
        task.continueWith(.mainThread) { t in
            if let signals = t.result {
                for signal in signals {
                    let cString = mbl_mw_anonymous_datasignal_get_identifier(signal)!
                    let identifier = String(cString: cString)
                    self.loggers[identifier] = signal
                    print("DOWNLOADING and STOPPING ", identifier, " as signal ", signal)
                    mbl_mw_anonymous_datasignal_subscribe(signal, bridge(obj: self), { (context, obj) in
                        let signal: MblMwCartesianFloat = obj!.pointee.valueAs()
                        print(obj!.pointee.epoch, signal)
                    })
                    self.handlers.context = bridge(obj: self)
                    self.handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
                        let this: RandomLoggingTests = bridge(ptr: context!)
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
            }
        }
        wait(for: [expectation!], timeout: 6000000)
    }
    
    func testloggerDisconnectDuringLogging() {
        expectation = XCTestExpectation(description: "random disconnect")
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let this: RandomLoggingTests = bridge(ptr: context!)
            this.logger = logger!
            print("Started logger: ", this.logger as Any)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            this.identifier = String(cString: cString)
            print("Generated Identifier for logger: ", this.identifier as Any)
            let cId = mbl_mw_logger_get_id(logger)
            this.loggerID = cId
            print("Generated ID for logger: ", this.loggerID)
            let cSignal = mbl_mw_logger_get_signal(logger)
            this.signal = cSignal
            print("Signal being logged is: ", this.signal as Any)
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            print("FAKE DISCONNECT")
            mbl_mw_debug_disconnect(self.device.board)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            self.device.connectAndSetup().continueWith { t -> () in
                if let error = t.error {
                    // Fake disconnect
                    print(error)
                    print("ERROR CONN")
                } else {
                    print("DOWNLOAD")
                    mbl_mw_acc_stop(self.device.board)
                    mbl_mw_acc_disable_acceleration_sampling(self.device.board)
                    mbl_mw_logging_stop(self.device.board)
                    mbl_mw_logging_flush_page(self.device.board)
                    let myLogger = mbl_mw_logger_lookup_id(self.device.board,self.loggerID)
                    mbl_mw_logger_subscribe(myLogger, bridge(obj: self), { (context, obj) in
                        let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
                        print(obj!.pointee.epoch, acceleration)
                    })
                    self.handlers.context = bridge(obj: self)
                    self.handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
                        let this: RandomLoggingTests = bridge(ptr: context!)
                        if remainingEntries == 0 {
                            print("done with logger: ", this.logger as Any)
                            mbl_mw_logger_remove(this.logger)
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
            }
        }
        wait(for: [expectation!], timeout: 1000)
    }
    
    func testloggerDisconnectDuringDownloading() {
        expectation = XCTestExpectation(description: "logger disconnect")
        mbl_mw_acc_set_range(device.board, 2.0)
        mbl_mw_acc_set_odr(device.board, 800)
        mbl_mw_acc_write_acceleration_config(device.board)
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let this: RandomLoggingTests = bridge(ptr: context!)
            this.logger = logger!
            print("Started logger: ", this.logger as Any)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            this.identifier = String(cString: cString)
            print("Generated Identifier for logger: ", this.identifier as Any)
            let cId = mbl_mw_logger_get_id(logger)
            this.loggerID = cId
            print("Generated ID for logger: ", this.loggerID)
            let cSignal = mbl_mw_logger_get_signal(logger)
            this.signal = cSignal
            print("Signal being logged is: ", this.signal as Any)
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        DispatchQueue.main.asyncAfter(deadline: .now() + 100) {
            self.device.connectAndSetup().continueWith { t -> () in
                if let error = t.error {
                    print(error)
                    print("ERROR CONN")
                } else {
                    print("START DOWNLOAD")
                    mbl_mw_acc_stop(self.device.board)
                    mbl_mw_acc_disable_acceleration_sampling(self.device.board)
                    mbl_mw_logging_stop(self.device.board)
                    mbl_mw_logging_flush_page(self.device.board)
                    let myLogger = mbl_mw_logger_lookup_id(self.device.board,self.loggerID)
                    mbl_mw_logger_subscribe(myLogger, bridge(obj: self), { (context, obj) in
                        let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
                        print(obj!.pointee.epoch, acceleration)
                    })
                    self.handlers.context = bridge(obj: self)
                    self.handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
                        let this: RandomLoggingTests = bridge(ptr: context!)
                        if remainingEntries == 0 {
                            print("done with logger too early!: ", this.logger as Any)
                            mbl_mw_logger_remove(this.logger)
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
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 105) {
            print("FAKE DISCONNECT")
            mbl_mw_debug_disconnect(self.device.board)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
            self.device.connectAndSetup().continueWith { t -> () in
                if let error = t.error {
                    print(error)
                    print("ERROR CONN")
                } else {
                    print("RESTART DOWNLOAD")
                    mbl_mw_acc_stop(self.device.board)
                    mbl_mw_acc_disable_acceleration_sampling(self.device.board)
                    mbl_mw_logging_stop(self.device.board)
                    mbl_mw_logging_flush_page(self.device.board)
                    let myLogger = mbl_mw_logger_lookup_id(self.device.board,self.loggerID)
                    mbl_mw_logger_subscribe(myLogger, bridge(obj: self), { (context, obj) in
                        let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
                        print(obj!.pointee.epoch, acceleration)
                    })
                    self.handlers.context = bridge(obj: self)
                    self.handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
                        let this: RandomLoggingTests = bridge(ptr: context!)
                        if remainingEntries == 0 {
                            print("done with logger correctly: ", this.logger as Any)
                            mbl_mw_logger_remove(this.logger)
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
            }
        }
        wait(for: [expectation!], timeout: 1000)
    }
}
