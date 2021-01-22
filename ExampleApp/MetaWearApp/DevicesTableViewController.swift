//
//  DevicesTableViewController.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 11/2/16.
//  Copyright © 2016 MbientLab. All rights reserved.
//

import UIKit
import MetaWear
import MetaWearCpp
import MBProgressHUD
import iOSDFULibrary

fileprivate let scanner = MetaWearScanner()

class DevicesTableViewController: UITableViewController {
    var hud: MBProgressHUD?
    var scannerModel: ScannerModel!
    var connectedDevices: [MetaWear] = []

    @IBOutlet weak var scanningSwitch: UISwitch!
    @IBOutlet weak var metaBootSwitch: UISwitch!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        setScanning(scanningSwitch.isOn)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setScanning(false)
    }
    
    func setScanning(_ on: Bool) {
        if on {
            activity.startAnimating()
            if metaBootSwitch.isOn {
                scannerModel = ScannerModel(delegate: self, scanner: scanner, adTimeout: 5) { device -> Bool in
                    return device.isMetaBoot
                }
            } else {
                scannerModel = ScannerModel(delegate: self, scanner: scanner, adTimeout: 5) { device -> Bool in
                    return !device.isMetaBoot
                }
            }
        } else {
            activity.stopAnimating()
        }
        scannerModel.isScanning = on
        connectedDevices = scanner.deviceMap.filter{ $0.key.state == .connected }.map{ $0.value }
        tableView.reloadData()
    }

    @IBAction func scanningSwitchPressed(_ sender: UISwitch) {
        setScanning(sender.isOn)
    }
    
    @IBAction func metaBootSwitchPressed(_ sender: Any) {
        setScanning(scanningSwitch.isOn)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? connectedDevices.count : scannerModel.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DeviceTableViewCell
        if indexPath.section == 0 {
            cell.device = connectedDevices[indexPath.row]
        } else {
            cell.model = scannerModel.items[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Connected Devices" : "Devices"
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let device = indexPath.section == 0 ? connectedDevices[indexPath.row] : scannerModel.items[indexPath.row].device
        performSegue(withIdentifier: "DeviceDetails", sender: device)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DeviceDetailViewController
        destination.device = (sender as! MetaWear)
    }
}

extension DevicesTableViewController: ScannerModelDelegate {
    func scannerModel(_ scannerModel: ScannerModel, didAddItemAt idx: Int) {
        let indexPath = IndexPath(row: idx, section: 1)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func scannerModel(_ scannerModel: ScannerModel, confirmBlinkingItem item: ScannerModelItem, callback: @escaping (Bool) -> Void) {
        
    }
    
    func scannerModel(_ scannerModel: ScannerModel, errorDidOccur error: Error) {
        
    }
}
