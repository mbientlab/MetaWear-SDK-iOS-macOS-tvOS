//
//  DeviceConfiguration.swift
//  iOS
//
//  Created by Stephen Schiffli on 10/23/17.
//  Copyright © 2017 MBIENTLAB, INC. All rights reserved.
//

import MetaWear

class DeviceConfiguration: NSObject, MBLRestorable {
    // You must save any custom events/filters to @objc properties
    // for the auto save/restore feature to work properly
    @objc var temperatureFilter: MBLFilter<AnyObject>?

    public func run(onDeviceBoot device: MBLMetaWear) {
        // Create all custom filters in this function and assign to properties
        temperatureFilter = device.temperature?.onDieThermistor.periodicRead(withPeriod: 1000).changeOfEvent(byDelta: 1.0, output: .absolute)
        temperatureFilter?.startLoggingAsync()
    }
}
