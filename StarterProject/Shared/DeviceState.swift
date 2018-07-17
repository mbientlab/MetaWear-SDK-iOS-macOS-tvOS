//
//  DeviceState.swift
//  StarterProject
//
//  Created by Stephen Schiffli on 5/3/18.
//  Copyright © 2018 MBIENTLAB, INC. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import BoltsSwift

protocol LogHandlers: class {
    func temperatureEntry(_ device: MetaWear, timestamp: Date, entry: Float)
}

class DeviceState: Codable {
    // Supplied variables
    let temperaturePeriodMsec: UInt32
    
    // MetaWear ID's - saved from board response
    var temperatureTimerId: UInt8 = 0xFF
    var temperatureLogId: UInt8 = 0xFF
    
    // Entire c++ metawear board state
    var serializedState: [UInt8] = []

    init(temperaturePeriodMsec: UInt32) {
        self.temperaturePeriodMsec = temperaturePeriodMsec
    }
    
    func setup(_ device: MetaWear) -> Task<()> {
        var thermistorSignal: OpaquePointer!
        // Get a the onboard thermistor if it exists
        return device.getThermistorSignal().continueOnSuccessWithTask { signal -> Task<OpaquePointer> in
            thermistorSignal = signal
            // Create a timer that will be used to periodically read the temperature signal
            return device.timerCreate(period: self.temperaturePeriodMsec)
        }.continueOnSuccessWithTask { timer -> Task<Void> in
            self.temperatureTimerId = mbl_mw_timer_get_id(timer)
            // Start the timer, this even will fire every temperaturePeriodMsec
            mbl_mw_timer_start(timer)
            // Now put the SDK in recording mode, all SDK calls between
            // mbl_mw_event_record_commands and eventEndRecord will be
            // programmed to the MetaWear and invoked each time 'timer' fires
            mbl_mw_event_record_commands(timer)
            // All we want the timer to do is read the temperature
            mbl_mw_datasignal_read(thermistorSignal)
            // Finish up the event
            return timer.eventEndRecord()
        }.continueOnSuccessWithTask { _ -> Task<OpaquePointer> in
            // Now we setup the MetaWear to log all reads of thermistorSignal
            return thermistorSignal.datasignalLog()
        }.continueOnSuccessWith { logger in
            self.temperatureLogId = mbl_mw_logger_get_id(logger)
            // Enable the logging module
            mbl_mw_logging_start(device.board, 0)
            // Save the state of the MetaWear object on the Apple device so we can restore and download later
            self.serializedState = device.serialize()
            self.saveToUrl(device.uniqueUrl)
        }
    }
    
    class func loadForDevice(_ device: MetaWear) -> DeviceState? {
        guard let data = try? Data(contentsOf: device.uniqueUrl) else {
            return nil
        }
        return try? JSONDecoder().decode(DeviceState.self, from: data)
    }
    
    func saveToUrl(_ url: URL) {
        let data = try! JSONEncoder().encode(self)
        try! data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }
}

// Helper functions that task-ify the C interface
extension MetaWear {
    func getThermistorSignal() -> Task<OpaquePointer> {
        guard mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_TEMPERATURE) != MBL_MW_MODULE_TYPE_NA else {
            return Task<OpaquePointer>(error: MetaWearError.operationFailed(message: "No temperature module"))
        }
        for channel in 0..<mbl_mw_multi_chnl_temp_get_num_channels(board) {
            if mbl_mw_multi_chnl_temp_get_source(board, channel) == MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM {
                let tempSignal = mbl_mw_multi_chnl_temp_get_temperature_data_signal(board, channel)!
                return Task<OpaquePointer>(tempSignal)
            }
        }
        return Task<OpaquePointer>(error: MetaWearError.operationFailed(message: "could not create conter"))
    }
}
