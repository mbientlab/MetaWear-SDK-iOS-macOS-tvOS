//
//  ScanViewController.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 10/18/16.
//  Copyright © 2016 MbientLab. All rights reserved.
//

import Cocoa
import MetaWear

class ScanViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!
    
    var devices: [MBLMetaWear]?
    

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.target = self
        tableView.doubleAction = #selector(ScanViewController.tableViewDoubleClick(sender:))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        MBLMetaWearManager.shared().logLevel = .info
        MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: true) { array in
            self.devices = array
            self.tableView.reloadData()
        }
    }
    
    // MARK: NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let device = devices?[row] else {
            return nil
        }
        guard let cell = tableView.make(withIdentifier: "MetaWearCell", owner: nil) as? NSTableCellView else {
            return nil
        }
        
        let uuid = cell.viewWithTag(1) as! NSTextField
        uuid.stringValue = device.identifier.uuidString
        
        if let rssiNumber = device.discoveryTimeRSSI {
            let rssi = cell.viewWithTag(2) as! NSTextField
            rssi.stringValue = rssiNumber.stringValue
        }
        
        let connected = cell.viewWithTag(3) as! NSTextField
        if device.state == .connected {
            connected.stringValue = "Connected!"
            connected.isHidden = false
        } else if device.state == .connecting || device.state == .discovery {
            connected.stringValue = "Connecting..."
            connected.isHidden = false
        } else {
            connected.isHidden = true
        }
                
        let name = cell.viewWithTag(4) as! NSTextField
        name.stringValue = device.name
        
        let signal = cell.viewWithTag(5) as! NSImageView
        if let movingAverage = device.averageRSSI?.doubleValue {
            if movingAverage < -80.0 {
                signal.image = NSImage(named: "wifi_d1")
            } else if movingAverage < -70.0 {
                signal.image = NSImage(named: "wifi_d2")
            } else if movingAverage < -60.0 {
                signal.image = NSImage(named: "wifi_d3")
            } else if movingAverage < -50.0 {
                signal.image = NSImage(named: "wifi_d4")
            } else if movingAverage < -40.0 {
                signal.image = NSImage(named: "wifi_d5")
            } else {
                signal.image = NSImage(named: "wifi_d6")
            }
        } else {
            signal.image = NSImage(named: "wifi_not_connected")
        }
        
        return cell
    }
    
    func tableViewDoubleClick(sender: AnyObject) {
        print("\(tableView.clickedRow) \(tableView.clickedColumn)")
        guard let device = devices?[tableView.clickedRow] else {
            return
        }
        if device.state == .connected {
            device.led?.flashColorAsync(NSColor.red, withIntensity: 1.0, numberOfFlashes: 3)
            device.disconnectAsync().success { _ in
                self.tableView.reloadData()
            }
        } else {
            device.connectAsync().success { _ in
                device.led?.flashColorAsync(NSColor.green, withIntensity: 1.0, numberOfFlashes: 3)
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        }
    }
}
