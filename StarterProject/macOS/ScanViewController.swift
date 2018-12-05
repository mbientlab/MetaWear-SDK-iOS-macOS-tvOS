//
//  ScanViewController.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 10/18/16.
//  Copyright © 2016 MbientLab. All rights reserved.
//

import Cocoa
import MetaWear
import MetaWearCpp

class ScanViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!
    
    var scannerModel: ScannerModel!

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.target = self
        tableView.doubleAction = #selector(ScanViewController.tableViewDoubleClick(sender:))
        scannerModel = ScannerModel(delegate: self)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        scannerModel.isScanning = true
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        scannerModel.isScanning = false
    }
    
    
    // MARK: NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return scannerModel.items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MetaWearCell"), owner: nil) as? NSTableCellView else {
            return nil
        }
        let device = scannerModel.items[row].device
        let uuid = cell.viewWithTag(1) as! NSTextField
        uuid.stringValue = device.peripheral.identifier.uuidString
        
        if let rssiNumber = device.averageRSSI() {
            let rssi = cell.viewWithTag(2) as! NSTextField
            rssi.stringValue = String(Int(rssiNumber.rounded()))
        }
        
        let connected = cell.viewWithTag(3) as! NSTextField
        if device.isConnectedAndSetup {
            connected.stringValue = "Connected!"
            connected.isHidden = false
        } else if scannerModel.items[row].isConnecting {
            connected.stringValue = "Connecting..."
            connected.isHidden = false
        } else {
            connected.isHidden = true
        }
                
        let name = cell.viewWithTag(4) as! NSTextField
        name.stringValue = device.name
        
        let signal = cell.viewWithTag(5) as! NSImageView
        if let movingAverage = device.averageRSSI() {
            if movingAverage < -80.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d1")
            } else if movingAverage < -70.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d2")
            } else if movingAverage < -60.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d3")
            } else if movingAverage < -50.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d4")
            } else if movingAverage < -40.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d5")
            } else {
                signal.image = #imageLiteral(resourceName: "wifi_d6")
            }
        } else {
            signal.image = #imageLiteral(resourceName: "wifi_not_connected")
        }
        
        return cell
    }
    
    @objc func tableViewDoubleClick(sender: AnyObject) {
        let device = scannerModel.items[tableView.clickedRow].device
        guard !device.isConnectedAndSetup else {
            device.flashLED(color: .red, intensity: 1.0, _repeat: 3)
            mbl_mw_debug_disconnect(device.board)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.tableView.reloadData()
            }
            return
        }
        scannerModel.items[tableView.clickedRow].toggleConnect()
        tableView.reloadData()
    }
}

extension ScanViewController: ScannerModelDelegate {
    func scannerModel(_ scannerModel: ScannerModel, didAddItemAt idx: Int) {
        tableView.reloadData()
    }
    
    func scannerModel(_ scannerModel: ScannerModel, confirmBlinkingItem item: ScannerModelItem, callback: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            callback(true)
            self.tableView.reloadData()
        }
    }
    
    func scannerModel(_ scannerModel: ScannerModel, errorDidOccur error: Error) {
    }
}
