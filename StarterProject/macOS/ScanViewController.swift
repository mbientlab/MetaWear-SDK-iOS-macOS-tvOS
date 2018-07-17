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
    
    var scannerModel: ScannerModel?

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.target = self
        tableView.doubleAction = #selector(ScanViewController.tableViewDoubleClick(sender:))
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        scannerModel = ScannerModel(delegate: self)
        scannerModel?.isScanning = true
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        scannerModel?.isScanning = false
    }
    
    
    // MARK: NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return scannerModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MetaWearCell"), owner: nil) as? NSTableCellView else {
            return nil
        }
        guard let device = scannerModel?.items[row].device else {
            return nil
        }
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
        } else if scannerModel!.items[row].isConnecting {
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
        guard let device = scannerModel?.items[tableView.clickedRow].device else {
            return
        }
        if device.isConnectedAndSetup {
            device.flashLED(color: .red, intensity: 1.0, _repeat: 3)
            mbl_mw_debug_disconnect(device.board)
        } else {
            device.logDelegate = ConsoleLogger.shared
            device.connectAndSetup().continueOnSuccessWith {
                $0.continueWith(.mainThread) { _ in
                    self.tableView.reloadData()
                }
                device.flashLED(color: .green, intensity: 1.0, _repeat: 3)
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        }
    }
}

extension ScanViewController: ScannerModelDelegate {
    func scannerModel(_ scannerModel: ScannerModel, didAddItemAt idx: Int) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func scannerModel(_ scannerModel: ScannerModel, confirmBlinkingItem item: ScannerModelItem, callback: @escaping (Bool) -> Void) {
    }
    
    func scannerModel(_ scannerModel: ScannerModel, errorDidOccur error: Error) {
    }
}


