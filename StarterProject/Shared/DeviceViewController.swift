//
//  DeviceViewController.swift
//  SwiftStarter
//
//  Created by Stephen Schiffli on 10/20/15.
//  Copyright © 2015 MbientLab Inc. All rights reserved.
//

import UIKit
import MetaWear
import MetaWearCpp

class DeviceViewController: UIViewController {
    @IBOutlet weak var deviceStatus: UILabel!
    
    var device: MetaWear!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.updateLabel("Restoring")
        if let state = DeviceState.loadForDevice(device) {
            // Initialize the device
            device.deserialize(state.serializedState)
            self.updateLabel("Connecting")
            device.connectAndSetup().continueWith { t in
                if let error = t.error {
                    // Sorry we couldn't connect
                    self.deviceStatus.text = error.localizedDescription
                } else {
                    // The result of a connectAndSetup call is a task which completes upon disconnection.
                    t.result!.continueWith {
                        state.serializedState = self.device.serialize()
                        state.saveToUrl(self.device.uniqueUrl)
                        self.updateLabel($0.error?.localizedDescription ?? "Disconnected")
                    }
                    
                    self.updateLabel("Connected")
                    self.device.flashLED(color: .green, intensity: 1.0, _repeat: 3)
                    
                    self.doDownload(state: state)
                }
            }
        }
    }
    
    func doDownload(state :DeviceState) {
        updateLabel("Downloading")
        // Attach log download handlers for the data
        let temperatureSignal = mbl_mw_logger_lookup_id(device.board, state.temperatureLogId)
        mbl_mw_logger_subscribe(temperatureSignal, bridge(obj: self)) { (context, data) in
            let _self: DeviceViewController = bridge(ptr: context!)
            _self.didGetTemperature(timestamp: data!.pointee.timestamp, entry: data!.pointee.valueAs())
        }
        
        // Setup the handlers for events during the download
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridge(obj: self)
        handlers.received_progress_update = { (context, entriesLeft, totalEntries) in
            let _self: DeviceViewController = bridge(ptr: context!)
            _self.progress(entriesLeft: entriesLeft, totalEntries: totalEntries)
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            let _self: DeviceViewController = bridge(ptr: context!)
            _self.unknownEntry(id: id, epoch: epoch, data: data, length: length)
        }
        handlers.received_unhandled_entry = { (context, data) in
            let _self: DeviceViewController = bridge(ptr: context!)
            _self.unhandledEntry(data: data)
        }
        
        // Start the log download
        mbl_mw_logging_download(device.board!, 100, &handlers)
    }
    
    func updateLabel(_ msg: String) {
        DispatchQueue.main.async {
            self.deviceStatus.text = msg
        }
    }
    
    func didGetTemperature(timestamp: Date, entry: Float) {
        print("temp: \(timestamp) \(entry)")
    }
    
    func progress(entriesLeft: UInt32, totalEntries: UInt32) {
        // Clear the in progress flag
        if entriesLeft == 0 {
            self.updateLabel("Finished download \(totalEntries) entries")
        }
    }
    
    func unknownEntry(id: UInt8, epoch: Int64, data: UnsafePointer<UInt8>?, length: UInt8) {
        print("unknownEntry: \(epoch) \(String(describing: data)) \(length)")
    }
    
    func unhandledEntry(data: UnsafePointer<MblMwData>?) {
        print("unhandledEntry: \(String(describing: data))")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        device.flashLED(color: .red, intensity: 1.0, _repeat: 3)
        mbl_mw_debug_disconnect(device.board)
    }
}
