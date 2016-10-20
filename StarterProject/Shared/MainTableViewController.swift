//
//  MainTableViewController.swift
//  SwiftStarter
//
//  Created by Stephen Schiffli on 10/16/15.
//  Copyright © 2015 MbientLab Inc. All rights reserved.
//

import UIKit
import MetaWear

class MainTableViewController: UITableViewController, ScanTableViewControllerDelegate {
    var devices: [MBLMetaWear]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        MBLMetaWearManager.shared().retrieveSavedMetaWearsAsync().success { (array) in
            if let deviceArray = array as? [MBLMetaWear] {
                if deviceArray.count > 0 {
                    self.devices = deviceArray
                } else {
                    self.devices = nil
                }
            } else {
                self.devices = nil
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Scan table view delegate
    
    func scanTableViewController(_ controller: ScanTableViewController, didSelectDevice device: MBLMetaWear) {
        device.rememberDevice()
        // TODO: You should assign a device configuration object here
        //device.setConfiguration(..., handler: ...)
        _ = navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (devices?.count ?? 0) + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        if devices != nil && indexPath.row < devices!.count {
            cell = tableView.dequeueReusableCell(withIdentifier: "MetaWearCell", for: indexPath)
            if let cur = devices?[indexPath.row] {
                let name = cell.viewWithTag(1) as! UILabel
                name.text = cur.name
                
                let uuid = cell.viewWithTag(2) as! UILabel
                uuid.text = cur.identifier.uuidString
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "NoDeviceCell", for: indexPath)
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if devices != nil && indexPath.row < devices!.count {
            if let cur = devices?[(indexPath as NSIndexPath).row] {
                performSegue(withIdentifier: "ViewDevice", sender: cur)
            }
        } else {
            performSegue(withIdentifier: "AddNewDevice", sender: nil)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return devices != nil && indexPath.row < devices!.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let cur = devices?[(indexPath as NSIndexPath).row] {
                cur.forgetDevice()
                // TODO: You should connect and set a nil configuration at this point
                devices?.remove(at: (indexPath as NSIndexPath).row)
                
                if devices?.count != 0 {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    devices = nil
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if let scanController = segue.destination as? ScanTableViewController {
            scanController.delegate = self
        } else if let deviceController = segue.destination as? DeviceViewController {
            deviceController.device = sender as! MBLMetaWear
        }
    }
}
