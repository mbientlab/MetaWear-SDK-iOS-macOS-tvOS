//
//  DeviceViewController.swift
//  SwiftStarter
//
//  Created by Stephen Schiffli on 10/20/15.
//  Copyright © 2015 MbientLab Inc. All rights reserved.
//

import UIKit
import MetaWear

class DeviceViewController: UIViewController {
    @IBOutlet weak var deviceStatus: UILabel!
    
    var device: MBLMetaWear!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        deviceStatus.text = "Connecting"
        device.connectAsync().success { _ in
            self.deviceStatus.text = "Connected"
            print("We are connected")
            self.device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0, numberOfFlashes: 3)
            if let configuration = self.device.configuration as? DeviceConfiguration {
                self.deviceStatus.text = "Downloading"
                configuration.temperatureFilter?.downloadLogAndStopLoggingAsync(false).success { array in
                    self.deviceStatus.text = "Connected"
                    array.forEach { print ($0) }
                }.failure { error in
                    self.deviceStatus.text = error.localizedDescription
                }
            }
        }.failure { error in
            self.deviceStatus.text = error.localizedDescription
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        device.led?.flashColorAsync(UIColor.red, withIntensity: 1.0, numberOfFlashes: 3)
        device.disconnectAsync()
    }
}
