//
//  DeviceTableViewCell.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 7/26/18.
//  Copyright © 2018 MbientLab. All rights reserved.
//

import UIKit
import MetaWear

class DeviceTableViewCell: UITableViewCell {
    var model: ScannerModelItem! {
        didSet {
            model.stateDidChange = { [weak self] in
                DispatchQueue.main.async {
                    self?.updateView(cur: self!.model.device)
                }
            }
        }
    }
    var device: MetaWear? {
        didSet {
            if let device = device {
                DispatchQueue.main.async {
                    self.updateView(cur: device)
                }
            }
        }
    }
    
    func updateView(cur: MetaWear) {
        let uuid = viewWithTag(1) as! UILabel
        uuid.text = cur.mac ?? "Connect for MAC"
        
        let rssi = viewWithTag(2) as! UILabel
        rssi.text = String(cur.rssi)
        
        let connected = viewWithTag(3) as! UILabel
        if cur.peripheral.state == .connected {
            connected.isHidden = false
        } else {
            connected.isHidden = true
        }
        
        let name = viewWithTag(4) as! UILabel
        name.text = cur.name
        
        let signal = viewWithTag(5) as! UIImageView
        if let averageRSSI = cur.averageRSSI() {
            if averageRSSI < -80.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d1")
            } else if averageRSSI < -70.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d2")
            } else if averageRSSI < -60.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d3")
            } else if averageRSSI < -50.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d4")
            } else if averageRSSI < -40.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d5")
            } else {
                signal.image = #imageLiteral(resourceName: "wifi_d6")
            }
        } else {
            signal.image = #imageLiteral(resourceName: "wifi_not_connected")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
