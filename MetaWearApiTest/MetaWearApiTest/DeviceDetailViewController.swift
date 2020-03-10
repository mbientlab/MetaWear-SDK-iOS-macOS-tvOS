//
//  DeviceDetailViewController.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 11/3/16.
//  Copyright © 2016 MbientLab. All rights reserved.
//

import UIKit
import StaticDataTableViewController
import MetaWear
import MetaWearCpp
import MessageUI
import BoltsSwift
import MBProgressHUD
import iOSDFULibrary

extension String {
    var drop0xPrefix: String {
        return hasPrefix("0x") ? String(dropFirst(2)) : self
    }
}

class DeviceDetailViewController: StaticDataTableViewController, UITextFieldDelegate {
    var device: MetaWear!
    
    @IBOutlet weak var connectionSwitch: UISwitch!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var setNameButton: UIButton!
    
    @IBOutlet var allCells: [UITableViewCell]!
    
    @IBOutlet var infoAndStateCells: [UITableViewCell]!
    @IBOutlet weak var mfgNameLabel: UILabel!
    @IBOutlet weak var serialNumLabel: UILabel!
    @IBOutlet weak var hwRevLabel: UILabel!
    @IBOutlet weak var fwRevLabel: UILabel!
    @IBOutlet weak var modelNumberLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var rssiLevelLabel: UILabel!
    @IBOutlet weak var txPowerSelector: UISegmentedControl!
    @IBOutlet weak var firmwareUpdateLabel: UILabel!
    
    @IBOutlet weak var mechanicalSwitchCell: UITableViewCell!
    @IBOutlet weak var mechanicalSwitchLabel: UILabel!
    @IBOutlet weak var startSwitch: UIButton!
    @IBOutlet weak var stopSwitch: UIButton!
    
    @IBOutlet weak var ledCell: UITableViewCell!
    
    @IBOutlet weak var tempCell: UITableViewCell!
    @IBOutlet weak var tempChannelSelector: UISegmentedControl!
    @IBOutlet weak var channelTypeLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var readPinLabel: UILabel!
    @IBOutlet weak var readPinTextField: UITextField!
    @IBOutlet weak var enablePinLabel: UILabel!
    @IBOutlet weak var enablePinTextField: UITextField!
    
    @IBOutlet weak var accelerometerBMI160Cell: UITableViewCell!
    @IBOutlet weak var accelerometerBMI160Scale: UISegmentedControl!
    @IBOutlet weak var accelerometerBMI160Frequency: UISegmentedControl!
    @IBOutlet weak var accelerometerBMI160StartStream: UIButton!
    @IBOutlet weak var accelerometerBMI160StopStream: UIButton!
    @IBOutlet weak var accelerometerBMI160StartLog: UIButton!
    @IBOutlet weak var accelerometerBMI160StopLog: UIButton!
    @IBOutlet weak var accelerometerBMI160Graph: APLGraphView!
    @IBOutlet weak var accelerometerBMI160StartOrient: UIButton!
    @IBOutlet weak var accelerometerBMI160StopOrient: UIButton!
    @IBOutlet weak var accelerometerBMI160OrientLabel: UILabel!
    @IBOutlet weak var accelerometerBMI160StartStep: UIButton!
    @IBOutlet weak var accelerometerBMI160StopStep: UIButton!
    @IBOutlet weak var accelerometerBMI160StepLabel: UILabel!
    var accelerometerBMI160StepCount = 0
    var accelerometerBMI160Data: [(Int64, MblMwCartesianFloat)] = []
    
    @IBOutlet weak var gyroBMI160Cell: UITableViewCell!
    @IBOutlet weak var gyroBMI160Scale: UISegmentedControl!
    @IBOutlet weak var gyroBMI160Frequency: UISegmentedControl!
    @IBOutlet weak var gyroBMI160StartStream: UIButton!
    @IBOutlet weak var gyroBMI160StopStream: UIButton!
    @IBOutlet weak var gyroBMI160StartLog: UIButton!
    @IBOutlet weak var gyroBMI160StopLog: UIButton!
    @IBOutlet weak var gyroBMI160Graph: APLGraphView!
    var gyroBMI160Data: [(Int64, MblMwCartesianFloat)] = []
    
    @IBOutlet weak var magnetometerBMM150Cell: UITableViewCell!
    @IBOutlet weak var magnetometerBMM150StartStream: UIButton!
    @IBOutlet weak var magnetometerBMM150StopStream: UIButton!
    @IBOutlet weak var magnetometerBMM150StartLog: UIButton!
    @IBOutlet weak var magnetometerBMM150StopLog: UIButton!
    @IBOutlet weak var magnetometerBMM150Graph: APLGraphView!
    var magnetometerBMM150Data: [(Int64, MblMwCartesianFloat)] = []
    
    @IBOutlet weak var gpioCell: UITableViewCell!
    @IBOutlet weak var gpioPinSelector: UISegmentedControl!
    @IBOutlet weak var gpioPinChangeType: UISegmentedControl!
    @IBOutlet weak var gpioStartPinChange: UIButton!
    @IBOutlet weak var gpioStopPinChange: UIButton!
    @IBOutlet weak var gpioPinChangeLabel: UILabel!
    var gpioPinChangeCount = 0
    @IBOutlet weak var gpioDigitalValue: UILabel!
    @IBOutlet weak var gpioAnalogAbsoluteButton: UIButton!
    @IBOutlet weak var gpioAnalogAbsoluteValue: UILabel!
    @IBOutlet weak var gpioAnalogRatioButton: UIButton!
    @IBOutlet weak var gpioAnalogRatioValue: UILabel!
    
    @IBOutlet weak var hapticCell: UITableViewCell!
    @IBOutlet weak var hapticPulseWidth: UITextField!
    @IBOutlet weak var hapticDutyCycle: UITextField!
    
    @IBOutlet weak var iBeaconCell: UITableViewCell!
    
    @IBOutlet weak var barometerBMP280Cell: UITableViewCell!
    @IBOutlet weak var barometerBMP280Oversampling: UISegmentedControl!
    @IBOutlet weak var barometerBMP280Averaging: UISegmentedControl!
    @IBOutlet weak var barometerBMP280Standby: UISegmentedControl!
    @IBOutlet weak var barometerBMP280StartStream: UIButton!
    @IBOutlet weak var barometerBMP280StopStream: UIButton!
    @IBOutlet weak var barometerBMP280Altitude: UILabel!
    
    @IBOutlet weak var barometerBME280Cell: UITableViewCell!
    @IBOutlet weak var barometerBME280Oversampling: UISegmentedControl!
    @IBOutlet weak var barometerBME280Averaging: UISegmentedControl!
    @IBOutlet weak var barometerBME280Standby: UISegmentedControl!
    @IBOutlet weak var barometerBME280StartStream: UIButton!
    @IBOutlet weak var barometerBME280StopStream: UIButton!
    @IBOutlet weak var barometerBME280Altitude: UILabel!
    
    @IBOutlet weak var ambientLightLTR329Cell: UITableViewCell!
    @IBOutlet weak var ambientLightLTR329Gain: UISegmentedControl!
    @IBOutlet weak var ambientLightLTR329Integration: UISegmentedControl!
    @IBOutlet weak var ambientLightLTR329Measurement: UISegmentedControl!
    @IBOutlet weak var ambientLightLTR329StartStream: UIButton!
    @IBOutlet weak var ambientLightLTR329StopStream: UIButton!
    @IBOutlet weak var ambientLightLTR329Illuminance: UILabel!
    
    @IBOutlet weak var proximityTSL2671Cell: UITableViewCell!
    @IBOutlet weak var proximityTSL2671Drive: UISegmentedControl!
    @IBOutlet weak var proximityTSL2671IntegrationLabel: UILabel!
    @IBOutlet weak var proximityTSL2671IntegrationSlider: UISlider!
    @IBOutlet weak var proximityTSL2671PulseLabel: UILabel!
    @IBOutlet weak var proximityTSL2671PulseStepper: UIStepper!
    @IBOutlet weak var proximityTSL2671StartStream: UIButton!
    @IBOutlet weak var proximityTSL2671StopStream: UIButton!
    @IBOutlet weak var proximityTSL2671Proximity: UILabel!
    
    @IBOutlet weak var photometerTCS3472Cell: UITableViewCell!
    @IBOutlet weak var photometerTCS3472Gain: UISegmentedControl!
    @IBOutlet weak var photometerTCS3472IntegrationLabel: UILabel!
    @IBOutlet weak var photometerTCS3472IntegrationSlider: UISlider!
    @IBOutlet weak var photometerTCS3472LedFlashSwitch: UISwitch!
    @IBOutlet weak var photometerTCS3472StartStream: UIButton!
    @IBOutlet weak var photometerTCS3472StopStream: UIButton!
    @IBOutlet weak var photometerTCS3472RedColor: UILabel!
    @IBOutlet weak var photometerTCS3472GreenColor: UILabel!
    @IBOutlet weak var photometerTCS3472BlueColor: UILabel!
    @IBOutlet weak var photometerTCS3472ClearColor: UILabel!
    var photometerTCS3472Event: OpaquePointer?
    
    @IBOutlet weak var hygrometerBME280Cell: UITableViewCell!
    @IBOutlet weak var hygrometerBME280Oversample: UISegmentedControl!
    @IBOutlet weak var hygrometerBME280StartStream: UIButton!
    @IBOutlet weak var hygrometerBME280StopStream: UIButton!
    @IBOutlet weak var hygrometerBME280Humidity: UILabel!
    var hygrometerBME280Event: OpaquePointer?
    
    @IBOutlet weak var i2cCell: UITableViewCell!
    @IBOutlet weak var i2cSizeSelector: UISegmentedControl!
    @IBOutlet weak var i2cDeviceAddress: UITextField!
    @IBOutlet weak var i2cRegisterAddress: UITextField!
    @IBOutlet weak var i2cReadByteLabel: UILabel!
    @IBOutlet weak var i2cWriteByteField: UITextField!
    
    @IBOutlet weak var sensorFusionCell: UITableViewCell!
    @IBOutlet weak var sensorFusionMode: UISegmentedControl!
    @IBOutlet weak var sensorFusionOutput: UISegmentedControl!
    @IBOutlet weak var sensorFusionStartStream: UIButton!
    @IBOutlet weak var sensorFusionStopStream: UIButton!
    @IBOutlet weak var sensorFusionStartLog: UIButton!
    @IBOutlet weak var sensorFusionStopLog: UIButton!
    @IBOutlet weak var sensorFusionGraph: APLGraphView!
    var sensorFusionData = Data()
    
    var streamingEvents: Set<OpaquePointer> = []
    var streamingCleanup: [OpaquePointer: () -> Void] = [:]
    var loggers: [String: OpaquePointer] = [:]
    
    var disconnectTask: Task<MetaWear>?
    var isObserving = false {
        didSet {
            if self.isObserving {
                if !oldValue {
                    self.device.peripheral.addObserver(self, forKeyPath: "state", options: .new, context: nil)
                }
            } else {
                if oldValue {
                    self.device.peripheral.removeObserver(self, forKeyPath: "state")
                }
            }
        }
    }
    var hud: MBProgressHUD!
    
    var controller: UIDocumentInteractionController!
    var initiator: DFUServiceInitiator?
    var dfuController: DFUServiceController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Use this array to keep track of all streaming events, so turn them off
        // in case the user isn't so responsible
        streamingEvents = []
        cells(self.allCells, setHidden: true)
        reloadData(animated: false)
        // Write in the 2 fields we know at time zero
        connectionStateLabel.text! = nameForState()
        nameTextField.delegate = self
        nameTextField.text = self.device.name
        // Listen for state changes
        isObserving = true
        // Start off the connection flow
        connectDevice(true)
    }
    
    override func showHeader(forSection section: Int, vissibleRows: Int) -> Bool {
        return vissibleRows != 0
    }
    
    override func showFooter(forSection section: Int, vissibleRows: Int) -> Bool {
        return vissibleRows != 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isObserving = false
        streamingCleanup.forEach { $0.value() }
        streamingCleanup.removeAll()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            self.connectionStateLabel.text! = self.nameForState()
            if self.device.peripheral.state == .disconnected {
                self.deviceDisconnected()
            }
        }
    }
    
    func nameForState() -> String {
        switch device.peripheral.state {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        }
    }
    
    func logCleanup(_ handler: @escaping (Error?) -> Void) {
        // In order for the device to actaully erase the flash memory we can't be in a connection
        // so temporally disconnect to allow flash to erase.
        isObserving = false
        device.connectAndSetup().continueOnSuccessWithTask { t -> Task<MetaWear> in
            self.device.cancelConnection()
            return t
        }.continueOnSuccessWithTask { t -> Task<Task<MetaWear>> in
            return self.device.connectAndSetup()
        }.continueWith { t in
            self.isObserving = true
            handler(t.error)
        }
    }
    
    func showAlertTitle(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deviceDisconnected() {
        connectionSwitch.setOn(false, animated: true)
        cells(self.allCells, setHidden: true)
        reloadData(animated: true)
    }
    
    func deviceConnectedReadAnonymousLoggers() {
        let task = device.createAnonymousDatasignals()
        task.continueWith(.mainThread) { t in
            print(self.loggers)
            if let signals = t.result {
                for signal in signals {
                    let cString = mbl_mw_anonymous_datasignal_get_identifier(signal)!
                    let identifier = String(cString: cString)
                    self.loggers[identifier] = signal
                }
            }
             print(self.loggers)
            self.deviceConnected()
        }
    }
    
    func deviceConnected() {
        connectionSwitch.setOn(true, animated: true)
        // Perform all device specific setup
        print("ID: \(self.device.peripheral.identifier.uuidString) MAC: \(self.device.mac ?? "N/A")")

        // We always have the info and state features
        cells(self.infoAndStateCells, setHidden: false)
        mfgNameLabel.text = device.info?.manufacturer ?? "N/A"
        serialNumLabel.text = device.info?.serialNumber ?? "N/A"
        hwRevLabel.text = device.info?.hardwareRevision ?? "N/A"
        fwRevLabel.text = device.info?.firmwareRevision ?? "N/A"
        modelNumberLabel.text = "\(device.info?.modelNumber ?? "N/A") (\(String(cString: mbl_mw_metawearboard_get_model_name(device.board))))"
        // Automaticaly send off some reads
        mbl_mw_settings_get_battery_state_data_signal(device.board).read().continueOnSuccessWith(.mainThread) {
            let battery: MblMwBatteryState = $0.valueAs()
            self.batteryLevelLabel.text = String(battery.charge)
        }
        self.rssiLevelLabel.text = String(device.rssi)
        device.checkForFirmwareUpdate().continueWith(.mainThread) {
            if let result = $0.result {
                self.firmwareUpdateLabel.text = result != nil ? "\(result!.firmwareRev) AVAILABLE!" : "Up To Date"
            } else {
                self.firmwareUpdateLabel.text = "Unknown"
            }
        }
        let board = device.board
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_LED) != MBL_MW_MODULE_TYPE_NA {
            cell(ledCell, setHidden: false)
        }
        // Go through each module and enable the correct cell for the modules on this particular MetaWear
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_SWITCH) != MBL_MW_MODULE_TYPE_NA {
            cell(mechanicalSwitchCell, setHidden: false)
        }
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_TEMPERATURE) != MBL_MW_MODULE_TYPE_NA {
            cell(tempCell, setHidden: false)
            // The number of channels is variable
            tempChannelSelector.removeAllSegments()
            let channedCount = mbl_mw_multi_chnl_temp_get_num_channels(device.board)
            for i in 0..<channedCount {
                tempChannelSelector.insertSegment(withTitle: "\(i)", at: Int(i), animated: false)
            }
            tempChannelSelector.selectedSegmentIndex = 0
            tempChannelSelectorPressed(tempChannelSelector)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_ACCELEROMETER) == MetaWearCpp.MBL_MW_MODULE_ACC_TYPE_BMI160 {
            cell(accelerometerBMI160Cell, setHidden: false)
            if loggers["acceleration"] != nil {
                accelerometerBMI160StartLog.isEnabled = false
                accelerometerBMI160StopLog.isEnabled = true
                accelerometerBMI160StartStream.isEnabled = false
                accelerometerBMI160StopStream.isEnabled = false
            } else {
                accelerometerBMI160StartLog.isEnabled = true
                accelerometerBMI160StopLog.isEnabled = false
                accelerometerBMI160StartStream.isEnabled = true
                accelerometerBMI160StopStream.isEnabled = false
            }
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_GYRO) != MBL_MW_MODULE_TYPE_NA {
            cell(gyroBMI160Cell, setHidden: false)
            if loggers["angular-velocity"] != nil {
                gyroBMI160StartLog.isEnabled = false
                gyroBMI160StopLog.isEnabled = true
                gyroBMI160StartStream.isEnabled = false
                gyroBMI160StopStream.isEnabled = false
            } else {
                gyroBMI160StartLog.isEnabled = true
                gyroBMI160StopLog.isEnabled = false
                gyroBMI160StartStream.isEnabled = true
                gyroBMI160StopStream.isEnabled = false
            }
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_MAGNETOMETER) != MBL_MW_MODULE_TYPE_NA {
            cell(magnetometerBMM150Cell, setHidden: false)
            if loggers["magnetic-field"] != nil {
                magnetometerBMM150StartLog.isEnabled = false
                magnetometerBMM150StopLog.isEnabled = true
                magnetometerBMM150StartStream.isEnabled = false
                magnetometerBMM150StopStream.isEnabled = false
            } else {
                magnetometerBMM150StartLog.isEnabled = true
                magnetometerBMM150StopLog.isEnabled = false
                magnetometerBMM150StartStream.isEnabled = true
                magnetometerBMM150StopStream.isEnabled = false
            }
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_GPIO) != MBL_MW_MODULE_TYPE_NA {
            cell(gpioCell, setHidden: false)
            // The number of pins is variable
            gpioPinSelector.removeAllSegments()
            // TODO: The number of pins is variable
            for i in 0..<8 {
                gpioPinSelector.insertSegment(withTitle: "\(i)", at: i, animated: false)
            }
            gpioPinSelector.selectedSegmentIndex = 0
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_HAPTIC) != MBL_MW_MODULE_TYPE_NA {
            cell(hapticCell, setHidden: false)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_IBEACON) != MBL_MW_MODULE_TYPE_NA {
            cell(iBeaconCell, setHidden: false)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_BAROMETER) == MetaWearCpp.MBL_MW_MODULE_BARO_TYPE_BMP280 {
            cell(barometerBMP280Cell, setHidden: false)
        } else if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_BAROMETER) == MetaWearCpp.MBL_MW_MODULE_BARO_TYPE_BME280 {
            cell(barometerBME280Cell, setHidden: false)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_AMBIENT_LIGHT) != MBL_MW_MODULE_TYPE_NA {
            cell(ambientLightLTR329Cell, setHidden: false)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_PROXIMITY) != MBL_MW_MODULE_TYPE_NA {
            cell(proximityTSL2671Cell, setHidden: false)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_COLOR_DETECTOR) != MBL_MW_MODULE_TYPE_NA {
            cell(photometerTCS3472Cell, setHidden: false)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_HUMIDITY) != MBL_MW_MODULE_TYPE_NA {
            cell(hygrometerBME280Cell, setHidden: false)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_I2C) != MBL_MW_MODULE_TYPE_NA {
            cell(i2cCell, setHidden: false)
        }
        
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_SENSOR_FUSION) != MBL_MW_MODULE_TYPE_NA {
            cell(sensorFusionCell, setHidden: false)
            var isLogging = true
            if loggers["euler-angles"] != nil {
                sensorFusionOutput.selectedSegmentIndex = 0
            } else if loggers["quaternion"] != nil {
                sensorFusionOutput.selectedSegmentIndex = 1
            } else if loggers["gravity"] != nil {
                sensorFusionOutput.selectedSegmentIndex = 2
            } else if loggers["linear-acceleration"] != nil {
                sensorFusionOutput.selectedSegmentIndex = 3
            } else {
                isLogging = false
            }
            
            if isLogging {
                sensorFusionStartLog.isEnabled = false
                sensorFusionStopLog.isEnabled = true
                sensorFusionStartStream.isEnabled = false
                sensorFusionStopStream.isEnabled = false
                sensorFusionMode.isEnabled = false
                sensorFusionOutput.isEnabled = false
            } else {
                sensorFusionStartLog.isEnabled = true
                sensorFusionStopLog.isEnabled = false
                sensorFusionStartStream.isEnabled = true
                sensorFusionStopStream.isEnabled = false
                sensorFusionMode.isEnabled = true
                sensorFusionOutput.isEnabled = true
            }
        }
        
        // Make the magic happen!
        reloadData(animated: true)
    }
    
    func connectDevice(_ on: Bool) {
        if on {
            let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            hud.label.text = "Connecting..."
            device.connectAndSetup().continueWith(.mainThread) { t in
//                t.result?.continueWith(.mainThread) { t in
//                    self.hud.hide(animated: false)
//                    let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
//                    self.deviceDisconnected()
//                    hud.mode = .text
//                    if t.error != nil {
//                        self.showAlertTitle("Error", message: t.error!.localizedDescription)
//                        hud.hide(animated: false)
//                    } else {
//                        hud.label.text = "Disconnected!"
//                        hud.hide(animated: true, afterDelay: 0.5)
//                    }
//                }
                hud.mode = .text
                if t.error != nil {
                    self.showAlertTitle("Error", message: t.error!.localizedDescription)
                    hud.hide(animated: false)
                } else {
                    self.deviceConnectedReadAnonymousLoggers()
                    hud.label.text! = "Connected!"
                    hud.hide(animated: true, afterDelay: 0.5)
                }
            }
        } else {
            device.cancelConnection()
        }
    }
    
    @IBAction func connectionSwitchPressed(_ sender: Any) {
        connectDevice(connectionSwitch.isOn)
    }
    
    @IBAction func setNamePressed(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "ihaveseennamemessage") == nil {
            UserDefaults.standard.set(1, forKey: "ihaveseennamemessage")
            UserDefaults.standard.synchronize()
            showAlertTitle("Notice", message: "Because of how iOS caches names, you have to disconnect and re-connect a few times or force close and re-launch the app before you see the new name!")
        }
        nameTextField.resignFirstResponder()
        let name = nameTextField.text!
        mbl_mw_settings_set_device_name(device.board, name, UInt8(name.count))
        setNameButton.isEnabled = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        self.setNameButton.isEnabled = true
        // Prevent Undo crashing bug
        if range.length + range.location > textField.text!.count {
            return false
        }
        // Make sure it's no longer than 8 characters
        let newLength = textField.text!.count + string.count - range.length
        if newLength > 8 {
            return false
        }
        // Make sure we only use ASCII characters
        return string.data(using: String.Encoding.ascii) != nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func readBatteryPressed(_ sender: Any) {
        mbl_mw_settings_get_battery_state_data_signal(device.board).read().continueWith(.mainThread) {
            if let error = $0.error {
                self.showAlertTitle("Error", message: error.localizedDescription)
            } else {
                let battery: MblMwBatteryState = $0.result!.valueAs()
                self.batteryLevelLabel.text = String(battery.charge)
            }
        }
    }
    
    @IBAction func readRSSIPressed(_ sender: Any) {
        device.readRSSI().continueOnSuccessWith(.mainThread) { rssi in
            self.rssiLevelLabel.text = String(rssi)
        }
    }
    
    @IBAction func txPowerChanged(_ sender: Any) {
        let txpower = Int8(txPowerSelector.titleForSegment(at: txPowerSelector.selectedSegmentIndex)!)!
        mbl_mw_settings_set_tx_power(device.board, txpower)
    }
    
    @IBAction func checkForFirmwareUpdatesPressed(_ sender: Any) {
        device.checkForFirmwareUpdate().continueWith(.mainThread) {
            if let error = $0.error {
                self.showAlertTitle("Error", message: error.localizedDescription)
            } else {
                self.firmwareUpdateLabel.text = $0.result! != nil ? "\($0.result!!.firmwareRev) AVAILABLE!" : "Up To Date"
            }
        }
    }
    
    @IBAction func updateFirmware(_ sender: Any) {
        // Pause the screen while update is going on
        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Updating..."
        device.updateFirmware(delegate: self).continueWith { t in
            if let error = t.error {
                print("Firmware update error \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Update Error", message: "Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: \(error.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                DispatchQueue.main.async {
                    self.hud?.hide(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.hud?.mode = .text
                    self.hud?.label.text = "Success!"
                    self.hud?.hide(animated: true, afterDelay: 2.0)
                }
                print("Success")
            }
        }
    }
    
    @IBAction func resetDevicePressed(_ sender: Any) {
        // Resetting causes a disconnection
        deviceDisconnected()
        // Preform the soft reset
        mbl_mw_debug_reset(device.board)
    }
    
    @IBAction func factoryDefaultsPressed(_ sender: Any) {
        // Resetting causes a disconnection
        deviceDisconnected()
        // TODO: In case any pairing information is on the device mark it for removal too
        device.clearAndReset()
    }
    
    @IBAction func putToSleepPressed(_ sender: Any) {
        // Sleep causes a disconnection
        deviceDisconnected()
        // Set it to sleep after the next reset
        mbl_mw_debug_enable_power_save(device.board)
        // Preform the soft reset
        mbl_mw_debug_reset(device.board)
    }
    
    @IBAction func startSwitchNotifyPressed(_ sender: Any) {
        startSwitch.isEnabled = false
        stopSwitch.isEnabled = true
        let signal = mbl_mw_switch_get_state_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let switchVal: UInt32 = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.mechanicalSwitchLabel.text = (switchVal != 0) ? "Down" : "Up"
            }
        }
        streamingCleanup[signal] = {
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }
    
    @IBAction func stopSwitchNotifyPressed(_ sender: Any) {
        startSwitch.isEnabled = true
        stopSwitch.isEnabled = false
        let signal = mbl_mw_switch_get_state_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
    }
    
    func setLedColor(_ color: MblMwLedColor) {
        var pattern = MblMwLedPattern(high_intensity: 31,
                                      low_intensity: 31,
                                      rise_time_ms: 0,
                                      high_time_ms: 2000,
                                      fall_time_ms: 0,
                                      pulse_duration_ms: 2000,
                                      delay_time_ms: 0,
                                      repeat_count: 0xFF)
        mbl_mw_led_stop_and_clear(device.board)
        mbl_mw_led_write_pattern(device.board, &pattern, color)
        mbl_mw_led_play(device.board)
    }
    
    @IBAction func turn(onGreenLEDPressed sender: Any) {
        setLedColor(MBL_MW_LED_COLOR_GREEN)
    }
    
    @IBAction func flashGreenLEDPressed(_ sender: Any) {
        device.flashLED(color: .green, intensity: 1.0)
    }
    
    @IBAction func turn(onRedLEDPressed sender: Any) {
        setLedColor(MBL_MW_LED_COLOR_RED)
    }
    
    @IBAction func flashRedLEDPressed(_ sender: Any) {
        device.flashLED(color: .red, intensity: 1.0)
    }
    
    @IBAction func turn(onBlueLEDPressed sender: Any) {
        setLedColor(MBL_MW_LED_COLOR_BLUE)
    }
    
    @IBAction func flashBlueLEDPressed(_ sender: Any) {
        device.flashLED(color: .blue, intensity: 1.0)
    }
    
    @IBAction func turnOffLEDPressed(_ sender: Any) {
        mbl_mw_led_stop_and_clear(device.board)
    }
    
    @IBAction func tempChannelSelectorPressed(_ sender: Any) {
        let source = mbl_mw_multi_chnl_temp_get_source(device.board, UInt8(tempChannelSelector.selectedSegmentIndex))
        switch source {
        case MBL_MW_TEMPERATURE_SOURCE_NRF_DIE:
            channelTypeLabel.text = "On-Die"
        case MBL_MW_TEMPERATURE_SOURCE_EXT_THERM:
            channelTypeLabel.text = "External"
        case MBL_MW_TEMPERATURE_SOURCE_BMP280:
            channelTypeLabel.text = "BMP280"
        case MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM:
            channelTypeLabel.text = "On-Board"
        default:
            channelTypeLabel.text = "Custom"
        }
        if source == MBL_MW_TEMPERATURE_SOURCE_EXT_THERM {
            self.readPinLabel.isHidden = false
            self.readPinTextField.isHidden = false
            self.enablePinLabel.isHidden = false
            self.enablePinTextField.isHidden = false
        } else {
            self.readPinLabel.isHidden = true
            self.readPinTextField.isHidden = true
            self.enablePinLabel.isHidden = true
            self.enablePinTextField.isHidden = true
        }
    }
    
    func readTempraturePressed(_ sender: Any) {
        let source = mbl_mw_multi_chnl_temp_get_source(device.board, UInt8(MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM.rawValue))
        let selected = mbl_mw_multi_chnl_temp_get_temperature_data_signal(device.board, UInt8(MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM.rawValue))!
        selected.read().continueOnSuccessWith(.mainThread) { obj in
            print(String(format: "%.1f°C", (obj.valueAs() as Float)))
        }
    }
    
    func send(_ data: Data, title: String) {
        // Get current Time/Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_dd_yyyy-HH_mm_ss"
        let dateString = dateFormatter.string(from: Date())
        let name = "\(title)_\(dateString).csv"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        do {
            try data.write(to: fileURL, options: .atomic)
            // Popup the default share screen
            self.controller = UIDocumentInteractionController(url: fileURL)
            if !self.controller.presentOptionsMenu(from: view.bounds, in: view, animated: true) {
                self.showAlertTitle("Error", message: "No programs installed that could save the file")
            }
        } catch let error {
            self.showAlertTitle("Error", message: error.localizedDescription)
        }
    }
    
    /*func updateAccelerometerSettings() {
        if accelerometerScale.selectedSegmentIndex == 0 {
            accelerometerGraph.fullScale = 2
        } else if accelerometerScale.selectedSegmentIndex == 1 {
            accelerometerGraph.fullScale = 4
        } else {
            accelerometerGraph.fullScale = 8
        }
        
        mbl_mw_acc_mma8452q_set_range(device.board, MblMwAccMma8452qRange(rawValue: UInt32(accelerometerScale.selectedSegmentIndex)))
        mbl_mw_acc_set_odr(device.board, Float(sampleFrequency.titleForSegment(at: sampleFrequency.selectedSegmentIndex)!)!)
        var freq = 0
        switch hpfCutoffFreq.selectedSegmentIndex {
        case 0:
            freq = 8
        case 1:
            freq = 4
        case 2:
            freq = 2
        default:
            freq = 1
        }
        mbl_mw_acc_mma8452q_set_high_pass_cutoff(device.board, highPassFilterSwitch.isOn ? Float(freq) : 0);
        mbl_mw_acc_mma8452q_write_acceleration_config(device.board)
    }
    
    @IBAction func startAccelerationPressed(_ sender: Any) {
        startAccelerometer.isEnabled = false
        stopAccelerometer.isEnabled = true
        startLog.isEnabled = false
        stopLog.isEnabled = false
        updateAccelerometerSettings()
        accelerometerDataArray.removeAll()
        let signal = mbl_mw_acc_mma8452q_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accelerometerGraph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
            }
            _self.accelerometerDataArray.append((obj!.pointee.epoch, acceleration))
        }
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }
    
    @IBAction func stopAccelerationPressed(_ sender: Any) {
        startAccelerometer.isEnabled = true
        stopAccelerometer.isEnabled = false
        startLog.isEnabled = true
        let signal = mbl_mw_acc_mma8452q_get_acceleration_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
    }
    
    @IBAction func startAccelerometerLog(_ sender: Any) {
        startLog.isEnabled = false
        stopLog.isEnabled = true
        startAccelerometer.isEnabled = false
        stopAccelerometer.isEnabled = false
        updateAccelerometerSettings()
        let signal = mbl_mw_acc_mma8452q_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggers[identifier] = logger!
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
    }
    
    @IBAction func stopAccelerometerLog(_ sender: Any) {
        stopLog.isEnabled = false
        startLog.isEnabled = true
        startAccelerometer.isEnabled = true
        guard let logger = loggers["acceleration"] else {
            return
        }
        mbl_mw_acc_stop(device.board)
        mbl_mw_acc_disable_acceleration_sampling(device.board)
        
        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        accelerometerDataArray.removeAll()
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accelerometerGraph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
            }
            _self.accelerometerDataArray.append((obj!.pointee.epoch, acceleration))
        }
        
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            DispatchQueue.main.async {
                _self.hud.progress = Float(progress)
            }
            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.hud.mode = .indeterminate
                    _self.hud.label.text = "Clearing Log..."
                }
                _self.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.hud.hide(animated: true)
                        if error != nil {
                            _self.deviceConnected()
                        }
                    }
                }
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
        

    }

    @IBAction func sendDataPressed(_ sender: Any) {
        var accelerometerData = Data()
        for dataElement in accelerometerDataArray {
            accelerometerData.append("\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n".data(using: String.Encoding.utf8)!)
        }
        send(accelerometerData, title: "AccData")
    }

    @IBAction func startOrientationPressed(_ sender: Any) {
        startOrientation.isEnabled = false
        stopOrientation.isEnabled = true
        updateAccelerometerSettings()
        
        let signal = mbl_mw_acc_mma8452q_get_orientation_detection_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let orientation: MblMwSensorOrientation = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                switch orientation {
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPRIGHT:
                    _self.orientationLabel.text = "Portrait Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPSIDE_DOWN:
                    _self.orientationLabel.text = "Portrait Upside Down Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_LEFT:
                    _self.orientationLabel.text = "Landscape Left Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_RIGHT:
                    _self.orientationLabel.text = "Landscape Right Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPRIGHT:
                    _self.orientationLabel.text = "Portrait Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPSIDE_DOWN:
                    _self.orientationLabel.text = "Portrait Upside Down Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_LEFT:
                    _self.orientationLabel.text = "Landscape Left Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_RIGHT:
                    _self.orientationLabel.text = "Landscape Right Face Down"
                default:
                    _self.orientationLabel.text = "N/A"
                }
            }
        }
        mbl_mw_acc_mma8452q_enable_orientation_detection(device.board)
        mbl_mw_acc_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_mma8452q_disable_orientation_detection(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func stopOrientationPressed(_ sender: Any) {
        startOrientation.isEnabled = true
        stopOrientation.isEnabled = false
        let signal = mbl_mw_acc_mma8452q_get_orientation_detection_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        self.orientationLabel.text = "XXXXXXXXXXXXXX"
    }*/

    func updateAccelerometerBMI160Settings() {
        switch self.accelerometerBMI160Scale.selectedSegmentIndex {
        case 0:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_2G)
            self.accelerometerBMI160Graph.fullScale = 2
        case 1:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_4G)
            self.accelerometerBMI160Graph.fullScale = 4
        case 2:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_8G)
            self.accelerometerBMI160Graph.fullScale = 8
        case 3:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_16G)
            self.accelerometerBMI160Graph.fullScale = 16
        default:
            fatalError("Unexpected accelerometerBMI160Scale value")
        }
        mbl_mw_acc_set_odr(device.board, Float(accelerometerBMI160Frequency.titleForSegment(at: accelerometerBMI160Frequency.selectedSegmentIndex)!)!)
        mbl_mw_acc_bosch_write_acceleration_config(device.board)
    }

    @IBAction func accelerometerBMI160StartStreamPressed(_ sender: Any) {
        accelerometerBMI160StartStream.isEnabled = false
        accelerometerBMI160StopStream.isEnabled = true
        accelerometerBMI160StartLog.isEnabled = false
        accelerometerBMI160StopLog.isEnabled = false
        updateAccelerometerBMI160Settings()
        accelerometerBMI160Data.removeAll()
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accelerometerBMI160Graph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
            }
            // Add data to data array for saving
            _self.accelerometerBMI160Data.append((obj!.pointee.epoch, acceleration))
        }
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func accelerometerBMI160StopStreamPressed(_ sender: Any) {
        accelerometerBMI160StartStream.isEnabled = true
        accelerometerBMI160StopStream.isEnabled = false
        accelerometerBMI160StartLog.isEnabled = true        
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
    }

    @IBAction func accelerometerBMI160StartLogPressed(_ sender: Any) {
        accelerometerBMI160StartLog.isEnabled = false
        accelerometerBMI160StopLog.isEnabled = true
        accelerometerBMI160StartStream.isEnabled = false
        accelerometerBMI160StopStream.isEnabled = false
        updateAccelerometerBMI160Settings()
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggers[identifier] = logger!
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
    }

    @IBAction func accelerometerBMI160StopLogPressed(_ sender: Any) {
        accelerometerBMI160StartLog.isEnabled = true
        accelerometerBMI160StopLog.isEnabled = false
        accelerometerBMI160StartStream.isEnabled = true
        guard let logger = loggers.removeValue(forKey: "acceleration") else {
            return
        }
        mbl_mw_acc_stop(device.board)
        mbl_mw_acc_disable_acceleration_sampling(device.board)

        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        accelerometerBMI160Data.removeAll()
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accelerometerBMI160Graph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
            }
            // Add data to data array for saving
            _self.accelerometerBMI160Data.append((obj!.pointee.epoch, acceleration))
        }
        
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            DispatchQueue.main.async {
                _self.hud.progress = Float(progress)
            }
            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.hud.mode = .indeterminate
                    _self.hud.label.text = "Clearing Log..."
                }
                _self.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.hud.hide(animated: true)
                        if error != nil {
                            _self.deviceConnected()
                        }
                    }
                }
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
    }

    @IBAction func accelerometerBMI160EmailDataPressed(_ sender: Any) {
        var accelerometerData = Data()
        for dataElement in accelerometerBMI160Data {
            accelerometerData.append("\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n".data(using: String.Encoding.utf8)!)
        }
        send(accelerometerData, title: "AccData")
    }
    
    @IBAction func accelerometerBMI160StartOrientPressed(_ sender: Any) {
        accelerometerBMI160StartOrient.isEnabled = false
        accelerometerBMI160StopOrient.isEnabled = true
        updateAccelerometerBMI160Settings()
        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let orientation: MblMwSensorOrientation = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                switch orientation {
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPRIGHT:
                    _self.accelerometerBMI160OrientLabel.text = "Portrait Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPSIDE_DOWN:
                    _self.accelerometerBMI160OrientLabel.text = "Portrait Upside Down Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_LEFT:
                    _self.accelerometerBMI160OrientLabel.text = "Landscape Left Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_RIGHT:
                    _self.accelerometerBMI160OrientLabel.text = "Landscape Right Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPRIGHT:
                    _self.accelerometerBMI160OrientLabel.text = "Portrait Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPSIDE_DOWN:
                    _self.accelerometerBMI160OrientLabel.text = "Portrait Upside Down Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_LEFT:
                    _self.accelerometerBMI160OrientLabel.text = "Landscape Left Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_RIGHT:
                    _self.accelerometerBMI160OrientLabel.text = "Landscape Right Face Down"
                default:
                    _self.accelerometerBMI160OrientLabel.text = "N/A"
                }
            }
        }
        mbl_mw_acc_bosch_enable_orientation_detection(device.board)
        mbl_mw_acc_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_bosch_disable_orientation_detection(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func accelerometerBMI160StopOrientPressed(_ sender: Any) {
        accelerometerBMI160StartOrient.isEnabled = true
        accelerometerBMI160StopOrient.isEnabled = false
        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        accelerometerBMI160OrientLabel.text = "XXXXXXXXXXXXXX"
    }

    @IBAction func accelerometerBMI160StartStepPressed(_ sender: Any) {
        accelerometerBMI160StartStep.isEnabled = false
        accelerometerBMI160StopStep.isEnabled = true
        updateAccelerometerBMI160Settings()
        let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            _self.accelerometerBMI160StepCount += 1
            DispatchQueue.main.async {
                _self.accelerometerBMI160StepLabel.text = "Step Count: \(_self.accelerometerBMI160StepCount)"
            }
        }
        mbl_mw_acc_bmi160_enable_step_detector(device.board)
        mbl_mw_acc_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_bmi160_disable_step_detector(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func accelerometerBMI160StopStepPressed(_ sender: Any) {
        accelerometerBMI160StartStep.isEnabled = true
        accelerometerBMI160StopStep.isEnabled = false
        let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        accelerometerBMI160StepCount = 0
        accelerometerBMI160StepLabel.text = "Step Count: 0"
    }

    /*func updateAccelerometerBMA255Settings() {
        switch self.accelerometerBMA255Scale.selectedSegmentIndex {
        case 0:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_2G)
            self.accelerometerBMA255Graph.fullScale = 2
        case 1:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_4G)
            self.accelerometerBMA255Graph.fullScale = 4
        case 2:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_8G)
            self.accelerometerBMA255Graph.fullScale = 8
        case 3:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_16G)
            self.accelerometerBMA255Graph.fullScale = 16
        default:
            fatalError("Unexpected accelerometerBMA255Scale value")
        }
        mbl_mw_acc_set_odr(device.board, Float(accelerometerBMA255Frequency.titleForSegment(at: accelerometerBMA255Frequency.selectedSegmentIndex)!)!)
        mbl_mw_acc_bosch_write_acceleration_config(device.board)
    }

    @IBAction func accelerometerBMA255StartStreamPressed(_ sender: Any) {
        accelerometerBMA255StartStream.isEnabled = false
        accelerometerBMA255StopStream.isEnabled = true
        accelerometerBMA255StartLog.isEnabled = false
        accelerometerBMA255StopLog.isEnabled = false
        updateAccelerometerBMA255Settings()
        accelerometerBMA255Data.removeAll()
        
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accelerometerBMA255Graph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
            }
            // Add data to data array for saving
            _self.accelerometerBMA255Data.append((obj!.pointee.epoch, acceleration))
        }
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func accelerometerBMA255StopStreamPressed(_ sender: Any) {
        accelerometerBMA255StartStream.isEnabled = true
        accelerometerBMA255StopStream.isEnabled = false
        accelerometerBMA255StartLog.isEnabled = true
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
    }
    
    @IBAction func accelerometerBMA255StartLogPressed(_ sender: Any) {
        accelerometerBMA255StartLog.isEnabled = false
        accelerometerBMA255StopLog.isEnabled = true
        accelerometerBMA255StartStream.isEnabled = false
        accelerometerBMA255StopStream.isEnabled = false
        updateAccelerometerBMA255Settings()
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggers[identifier] = logger!
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
    }

    @IBAction func accelerometerBMA255StopLogPressed(_ sender: Any) {
        accelerometerBMA255StartLog.isEnabled = true
        accelerometerBMA255StopLog.isEnabled = false
        accelerometerBMA255StartStream.isEnabled = true
        guard let logger = loggers.removeValue(forKey: "acceleration") else {
            return
        }
        mbl_mw_acc_stop(device.board)
        mbl_mw_acc_disable_acceleration_sampling(device.board)
        
        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        accelerometerBMA255Data.removeAll()
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accelerometerBMA255Graph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
            }
            // Add data to data array for saving
            _self.accelerometerBMA255Data.append((obj!.pointee.epoch, acceleration))
        }
        
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            DispatchQueue.main.async {
                _self.hud.progress = Float(progress)
            }
            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.hud.mode = .indeterminate
                    _self.hud.label.text = "Clearing Log..."
                }
                _self.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.hud.hide(animated: true)
                        if error != nil {
                            _self.deviceConnected()
                        }
                    }
                }
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
    }

    @IBAction func accelerometerBMA255EmailDataPressed(_ sender: Any) {
        var accelerometerData = Data()
        for dataElement in accelerometerBMA255Data {
            accelerometerData.append("\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n".data(using: String.Encoding.utf8)!)
        }
        send(accelerometerData, title: "AccData")
    }

    @IBAction func accelerometerBMA255StartOrientPressed(_ sender: Any) {
        accelerometerBMA255StartOrient.isEnabled = false
        accelerometerBMA255StopOrient.isEnabled = true
        updateAccelerometerBMA255Settings()
        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let orientation: MblMwSensorOrientation = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                switch orientation {
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPRIGHT:
                    _self.accelerometerBMA255OrientLabel.text = "Portrait Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPSIDE_DOWN:
                    _self.accelerometerBMA255OrientLabel.text = "Portrait Upside Down Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_LEFT:
                    _self.accelerometerBMA255OrientLabel.text = "Landscape Left Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_RIGHT:
                    _self.accelerometerBMA255OrientLabel.text = "Landscape Right Face Up"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPRIGHT:
                    _self.accelerometerBMA255OrientLabel.text = "Portrait Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPSIDE_DOWN:
                    _self.accelerometerBMA255OrientLabel.text = "Portrait Upside Down Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_LEFT:
                    _self.accelerometerBMA255OrientLabel.text = "Landscape Left Face Down"
                case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_RIGHT:
                    _self.accelerometerBMA255OrientLabel.text = "Landscape Right Face Down"
                default:
                    _self.accelerometerBMA255OrientLabel.text = "N/A"
                }
            }
        }
        mbl_mw_acc_bosch_enable_orientation_detection(device.board)
        mbl_mw_acc_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_bosch_disable_orientation_detection(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func accelerometerBMA255StopOrientPressed(_ sender: Any) {
        accelerometerBMA255StartOrient.isEnabled = true
        accelerometerBMA255StopOrient.isEnabled = false
        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        accelerometerBMA255OrientLabel.text = "XXXXXXXXXXXXXX"
    }*/

    func updateGyroBMI160Settings() {
        switch self.gyroBMI160Scale.selectedSegmentIndex {
        case 0:
            mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BMI160_RANGE_125dps)
            self.gyroBMI160Graph.fullScale = 1
        case 1:
            mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BMI160_RANGE_250dps)
            self.gyroBMI160Graph.fullScale = 2
        case 2:
            mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BMI160_RANGE_500dps)
            self.gyroBMI160Graph.fullScale = 4
        case 3:
            mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BMI160_RANGE_1000dps)
            self.gyroBMI160Graph.fullScale = 8
        case 4:
            mbl_mw_gyro_bmi160_set_range(device.board, MBL_MW_GYRO_BMI160_RANGE_2000dps)
            self.gyroBMI160Graph.fullScale = 16
        default:
            fatalError("Unexpected gyroBMI160Scale value")
        }
        switch self.gyroBMI160Frequency.selectedSegmentIndex {
        case 0:
            mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_1600Hz)
        case 1:
            mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_800Hz)
        case 2:
            mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_400Hz)
        case 3:
            mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_200Hz)
        case 4:
            mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_100Hz)
        case 5:
            mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_50Hz)
        case 6:
            mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BMI160_ODR_25Hz)
        default:
            fatalError("Unexpected gyroBMI160Frequency value")
        }
        mbl_mw_gyro_bmi160_write_config(device.board)
    }

    @IBAction func gyroBMI160StartStreamPressed(_ sender: Any) {
        gyroBMI160StartStream.isEnabled = false
        gyroBMI160StopStream.isEnabled = true
        gyroBMI160StartLog.isEnabled = false
        gyroBMI160StopLog.isEnabled = false
        updateGyroBMI160Settings()
        gyroBMI160Data.removeAll()
        
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                // TODO: Come up with a better graph interface, we need to scale value
                // to show up right
                _self.gyroBMI160Graph.addX(Double(acceleration.x * 0.008), y: Double(acceleration.y * 0.008), z: Double(acceleration.z * 0.008))
            }
            // Add data to data array for saving
            _self.gyroBMI160Data.append((obj!.pointee.epoch, acceleration))
        }
        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi160_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_gyro_bmi160_stop(self.device.board)
            mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func gyroBMI160StopStreamPressed(_ sender: Any) {
        gyroBMI160StartStream.isEnabled = true
        gyroBMI160StopStream.isEnabled = false
        gyroBMI160StartLog.isEnabled = true
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
    }

    @IBAction func gyroBMI160StartLogPressed(_ sender: Any) {
        gyroBMI160StartLog.isEnabled = false
        gyroBMI160StopLog.isEnabled = true
        gyroBMI160StartStream.isEnabled = false
        gyroBMI160StopStream.isEnabled = false
        updateGyroBMI160Settings()
        
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggers[identifier] = logger!
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
        mbl_mw_gyro_bmi160_start(device.board)
    }

    @IBAction func gyroBMI160StopLogPressed(_ sender: Any) {
        gyroBMI160StartLog.isEnabled = true
        gyroBMI160StopLog.isEnabled = false
        gyroBMI160StartStream.isEnabled = true
        guard let logger = loggers.removeValue(forKey: "angular-velocity") else {
            return
        }
        mbl_mw_gyro_bmi160_stop(device.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(device.board)
        
        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        gyroBMI160Data.removeAll()
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.gyroBMI160Graph.addX(Double(acceleration.x * 0.008), y: Double(acceleration.y * 0.008), z: Double(acceleration.z * 0.008))
            }
            // Add data to data array for saving
            _self.gyroBMI160Data.append((obj!.pointee.epoch, acceleration))
        }
        
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            DispatchQueue.main.async {
                _self.hud.progress = Float(progress)
            }
            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.hud.mode = .indeterminate
                    _self.hud.label.text = "Clearing Log..."
                }
                _self.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.hud.hide(animated: true)
                        if error != nil {
                            _self.deviceConnected()
                        }
                    }
                }
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
    }

    @IBAction func gyroBMI160EmailDataPressed(_ sender: Any) {
        var gyroData = Data()
        for dataElement in self.gyroBMI160Data {
            gyroData.append("\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n".data(using: String.Encoding.utf8)!)
        }
        self.send(gyroData, title: "GyroData")
    }

    @IBAction func magnetometerBMM150StartStreamPressed(_ sender: Any) {
        magnetometerBMM150StartStream.isEnabled = false
        magnetometerBMM150StopStream.isEnabled = true
        magnetometerBMM150StartLog.isEnabled = false
        magnetometerBMM150StopLog.isEnabled = false
        magnetometerBMM150Data.removeAll()
        magnetometerBMM150Graph.fullScale = 4
        
        let signal = mbl_mw_mag_bmm150_get_b_field_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let mag: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.magnetometerBMM150Graph.addX(_self.magnetometerBMM150Graph.scale(Double(mag.x), min: -100, max: 100),
                                                   y: _self.magnetometerBMM150Graph.scale(Double(mag.y), min: -100, max: 100),
                                                   z: _self.magnetometerBMM150Graph.scale(Double(mag.z), min: -100, max: 100))
            }
            // Add data to data array for saving
            _self.magnetometerBMM150Data.append((obj!.pointee.epoch, mag))
        }
        mbl_mw_mag_bmm150_enable_b_field_sampling(device.board)
        mbl_mw_mag_bmm150_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_mag_bmm150_stop(self.device.board)
            mbl_mw_mag_bmm150_disable_b_field_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func magnetometerBMM150StopStreamPressed(_ sender: Any) {
        magnetometerBMM150StartStream.isEnabled = true
        magnetometerBMM150StopStream.isEnabled = false
        magnetometerBMM150StartLog.isEnabled = true
        let signal = mbl_mw_mag_bmm150_get_b_field_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
    }

    @IBAction func magnetometerBMM150StartLogPressed(_ sender: Any) {
        magnetometerBMM150StartLog.isEnabled = false
        magnetometerBMM150StopLog.isEnabled = true
        magnetometerBMM150StartStream.isEnabled = false
        magnetometerBMM150StopStream.isEnabled = false
        magnetometerBMM150Graph.fullScale = 4
        
        let signal = mbl_mw_mag_bmm150_get_b_field_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggers[identifier] = logger!
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_mag_bmm150_enable_b_field_sampling(device.board)
        mbl_mw_mag_bmm150_start(device.board)
    }

    @IBAction func magnetometerBMM150StopLogPressed(_ sender: Any) {
        magnetometerBMM150StartLog.isEnabled = true
        magnetometerBMM150StopLog.isEnabled = false
        magnetometerBMM150StartStream.isEnabled = true
        guard let logger = loggers.removeValue(forKey: "magnetic-field") else {
            return
        }
        mbl_mw_mag_bmm150_stop(device.board)
        mbl_mw_mag_bmm150_disable_b_field_sampling(device.board)
        
        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        magnetometerBMM150Data.removeAll()
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let mag: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.magnetometerBMM150Graph.addX(Double(mag.x * 20000.0), y: Double(mag.y * 20000.0), z: Double(mag.z * 20000.0))
            }
            // Add data to data array for saving
            _self.magnetometerBMM150Data.append((obj!.pointee.epoch, mag))
        }
        
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            DispatchQueue.main.async {
                _self.hud.progress = Float(progress)
            }
            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.hud.mode = .indeterminate
                    _self.hud.label.text = "Clearing Log..."
                }
                _self.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.hud.hide(animated: true)
                        if error != nil {
                            _self.deviceConnected()
                        }
                    }
                }
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
    }

    @IBAction func magnetometerBMM150SendDataPressed(_ sender: Any) {
        var magnetometerData = Data()
        for dataElement in magnetometerBMM150Data {
            magnetometerData.append("\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n".data(using: String.Encoding.utf8)!)
        }
        send(magnetometerData, title: "MagnetometerData")
    }

    @IBAction func gpioPinSelectorPressed(_ sender: Any) {
        // TODO: Not every pin allows all reading types
        // let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        self.gpioAnalogAbsoluteButton.isHidden = false
        self.gpioAnalogAbsoluteValue.isHidden = false
        
        self.gpioAnalogRatioButton.isHidden = false
        self.gpioAnalogRatioValue.isHidden = false
    }

    @IBAction func setPullUpPressed(_ sender: Any) {
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        mbl_mw_gpio_set_pull_mode(device.board, pin, MBL_MW_GPIO_PULL_MODE_UP)
    }

    @IBAction func setPullDownPressed(_ sender: Any) {
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        mbl_mw_gpio_set_pull_mode(device.board, pin, MBL_MW_GPIO_PULL_MODE_DOWN)
    }

    @IBAction func setNoPullPressed(_ sender: Any) {
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        mbl_mw_gpio_set_pull_mode(device.board, pin, MBL_MW_GPIO_PULL_MODE_NONE)
    }

    @IBAction func setPinPressed(_ sender: Any) {
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        mbl_mw_gpio_set_digital_output(device.board, pin)
    }

    @IBAction func clearPinPressed(_ sender: Any) {
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        mbl_mw_gpio_clear_digital_output(device.board, pin)
    }

    @IBAction func gpioStartPinChangePressed(_ sender: Any) {
        gpioStartPinChange.isEnabled = false
        gpioStopPinChange.isEnabled = true
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        if gpioPinChangeType.selectedSegmentIndex == 0 {
            mbl_mw_gpio_set_pin_change_type(device.board, pin, MBL_MW_GPIO_PIN_CHANGE_TYPE_RISING)
        } else if gpioPinChangeType.selectedSegmentIndex == 1 {
            mbl_mw_gpio_set_pin_change_type(device.board, pin, MBL_MW_GPIO_PIN_CHANGE_TYPE_FALLING)
        } else {
            mbl_mw_gpio_set_pin_change_type(device.board, pin, MBL_MW_GPIO_PIN_CHANGE_TYPE_ANY)
        }
        
        let signal = mbl_mw_gpio_get_pin_monitor_data_signal(device.board, pin)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let value: UInt32 = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.gpioPinChangeCount += 1
                _self.gpioPinChangeLabel.text = "Change Count: \(_self.gpioPinChangeCount)"
            }
        }
        mbl_mw_gpio_start_pin_monitoring(device.board, pin)
        
        streamingCleanup[signal] = {
            mbl_mw_gpio_stop_pin_monitoring(self.device.board, pin)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func gpioStopPinChangePressed(_ sender: Any) {
        gpioStartPinChange.isEnabled = true
        gpioStopPinChange.isEnabled = false
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        let signal = mbl_mw_gpio_get_pin_monitor_data_signal(device.board, pin)!
        streamingCleanup.removeValue(forKey: signal)?()
        gpioPinChangeCount = 0
        gpioPinChangeLabel.text = "Change Count: 0"
    }

    @IBAction func readDigitalPressed(_ sender: Any) {
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        let signal = mbl_mw_gpio_get_digital_input_data_signal(device.board, pin)!
        signal.read().continueOnSuccessWith { data in
            let value: UInt32 = data.valueAs()
            self.gpioDigitalValue.text = value != 0 ? "1" : "0"
        }
    }
    
    @IBAction func readAnalogAbsolutePressed(_ sender: Any) {
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        let signal = mbl_mw_gpio_get_analog_input_data_signal(device.board, pin, MBL_MW_GPIO_ANALOG_READ_MODE_ABS_REF)!
        signal.read().continueOnSuccessWith { data in
            let value: UInt32 = data.valueAs() // Units in mili volts
            self.gpioAnalogAbsoluteValue.text = String(format: "%.3fV", Double(value) / 1000.0)
        }
    }

    @IBAction func readAnalogRatioPressed(_ sender: Any) {
        let pin = UInt8(gpioPinSelector.selectedSegmentIndex)
        let signal = mbl_mw_gpio_get_analog_input_data_signal(device.board, pin, MBL_MW_GPIO_ANALOG_READ_MODE_ADC)!
        signal.read().continueOnSuccessWith { data in
            let value: UInt32 = data.valueAs() // Units in 10-bit ratio
            self.gpioAnalogRatioValue.text = String(format: "%.3f", Double(value) / 0x3ff)
        }
    }

    @IBAction func startHapticDriverPressed(_ sender: UIButton) {
        var dcycle = UInt8(hapticDutyCycle.text!) ?? 248
        dcycle = min(dcycle, 248)
        dcycle = max(dcycle, 0)
        hapticDutyCycle.text = String(dcycle)

        var pwidth = UInt16(hapticPulseWidth.text!) ?? 500
        pwidth = min(pwidth, 10000)
        pwidth = max(pwidth, 0)
        hapticPulseWidth.text = String(pwidth)

        sender.isEnabled = false
        mbl_mw_haptic_start_motor(device.board, (Float(dcycle) / 248.0) * 100.0, pwidth)
        DispatchQueue.main.asyncAfter(deadline: .now() + (Double(pwidth) / 1000.0)) {
            sender.isEnabled = true
        }
    }

    @IBAction func startBuzzerDriverPressed(_ sender: UIButton) {
        var pwidth = UInt16(hapticPulseWidth.text!) ?? 500
        pwidth = min(pwidth, 10000)
        pwidth = max(pwidth, 0)
        hapticPulseWidth.text = String(pwidth)

        sender.isEnabled = false
        mbl_mw_haptic_start_buzzer(device.board, pwidth)
        DispatchQueue.main.asyncAfter(deadline: .now() + (Double(pwidth) / 1000.0)) {
            sender.isEnabled = true
        }
    }

    @IBAction func startiBeaconPressed(_ sender: Any) {
        let uuid = UUID().uuidString
        var i: UInt8 = UInt8.init(uuid)!
        let up: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.init(&i)
        mbl_mw_ibeacon_set_major(device.board, 78)
        mbl_mw_ibeacon_set_minor(device.board, 7453)
        mbl_mw_ibeacon_set_period(device.board, 15027)
        mbl_mw_ibeacon_set_rx_power(device.board, -55)
        mbl_mw_ibeacon_set_tx_power(device.board, -12)
        mbl_mw_ibeacon_set_uuid(device.board, up)
        mbl_mw_ibeacon_enable(device.board)
    }

    @IBAction func stopiBeaconPressed(_ sender: Any) {
        mbl_mw_ibeacon_disable(device.board)
    }

    @IBAction func barometerBMP280StartStreamPressed(_ sender: Any) {
        barometerBMP280StartStream.isEnabled = false
        barometerBMP280StopStream.isEnabled = true
        if barometerBMP280Oversampling.selectedSegmentIndex == 0 {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_ULTRA_LOW_POWER)
        } else if barometerBMP280Oversampling.selectedSegmentIndex == 1 {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_LOW_POWER)
        } else if barometerBMP280Oversampling.selectedSegmentIndex == 2 {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_STANDARD)
        } else if barometerBMP280Oversampling.selectedSegmentIndex == 3 {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_HIGH)
        } else {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_ULTRA_HIGH)
        }

        if barometerBMP280Averaging.selectedSegmentIndex == 0 {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_OFF)
        } else if barometerBMP280Averaging.selectedSegmentIndex == 1 {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_2)
        } else if barometerBMP280Averaging.selectedSegmentIndex == 2 {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_4)
        } else if barometerBMP280Averaging.selectedSegmentIndex == 3 {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_8)
        } else {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_16)
        }

        if barometerBMP280Standby.selectedSegmentIndex == 0 {
            mbl_mw_baro_bmp280_set_standby_time(device.board, MBL_MW_BARO_BMP280_STANDBY_TIME_0_5ms)
        } else if barometerBMP280Standby.selectedSegmentIndex == 1 {
            mbl_mw_baro_bmp280_set_standby_time(device.board, MBL_MW_BARO_BMP280_STANDBY_TIME_62_5ms)
        } else if barometerBMP280Standby.selectedSegmentIndex == 2 {
            mbl_mw_baro_bmp280_set_standby_time(device.board, MBL_MW_BARO_BMP280_STANDBY_TIME_125ms)
        } else if barometerBMP280Standby.selectedSegmentIndex == 3 {
            mbl_mw_baro_bmp280_set_standby_time(device.board, MBL_MW_BARO_BMP280_STANDBY_TIME_250ms)
        } else if barometerBMP280Standby.selectedSegmentIndex == 4 {
            mbl_mw_baro_bmp280_set_standby_time(device.board, MBL_MW_BARO_BMP280_STANDBY_TIME_500ms)
        } else if barometerBMP280Standby.selectedSegmentIndex == 5 {
            mbl_mw_baro_bmp280_set_standby_time(device.board, MBL_MW_BARO_BMP280_STANDBY_TIME_1000ms)
        } else if barometerBMP280Standby.selectedSegmentIndex == 6 {
            mbl_mw_baro_bmp280_set_standby_time(device.board, MBL_MW_BARO_BMP280_STANDBY_TIME_2000ms)
        } else {
            mbl_mw_baro_bmp280_set_standby_time(device.board, MBL_MW_BARO_BMP280_STANDBY_TIME_4000ms)
        }
        mbl_mw_baro_bosch_write_config(device.board)
        
        let signal = mbl_mw_baro_bosch_get_altitude_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let altitude: Float = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.barometerBMP280Altitude.text = String(format: "%.3f", altitude)
            }
        }
        mbl_mw_baro_bosch_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_baro_bosch_stop(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func barometerBMP280StopStreamPressed(_ sender: Any) {
        barometerBMP280StartStream.isEnabled = true
        barometerBMP280StopStream.isEnabled = false
        let signal = mbl_mw_baro_bosch_get_altitude_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        barometerBMP280Altitude.text = "X.XXX"
    }

    @IBAction func barometerBME280StartStreamPressed(_ sender: Any) {
        barometerBME280StartStream.isEnabled = false
        barometerBME280StopStream.isEnabled = true
        if barometerBMP280Oversampling.selectedSegmentIndex == 0 {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_ULTRA_LOW_POWER)
        } else if barometerBME280Oversampling.selectedSegmentIndex == 1 {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_LOW_POWER)
        } else if barometerBME280Oversampling.selectedSegmentIndex == 2 {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_STANDARD)
        } else if barometerBME280Oversampling.selectedSegmentIndex == 3 {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_HIGH)
        } else {
            mbl_mw_baro_bosch_set_oversampling(device.board, MBL_MW_BARO_BOSCH_OVERSAMPLING_ULTRA_HIGH)
        }

        if barometerBME280Averaging.selectedSegmentIndex == 0 {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_OFF)
        } else if barometerBME280Averaging.selectedSegmentIndex == 1 {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_2)
        } else if barometerBME280Averaging.selectedSegmentIndex == 2 {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_4)
        } else if barometerBME280Averaging.selectedSegmentIndex == 3 {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_8)
        } else {
            mbl_mw_baro_bosch_set_iir_filter(device.board, MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_16)
        }

        if barometerBME280Standby.selectedSegmentIndex == 0 {
            mbl_mw_baro_bme280_set_standby_time(device.board, MBL_MW_BARO_BME280_STANDBY_TIME_0_5ms)
        } else if barometerBME280Standby.selectedSegmentIndex == 1 {
            mbl_mw_baro_bme280_set_standby_time(device.board, MBL_MW_BARO_BME280_STANDBY_TIME_10ms)
        } else if barometerBME280Standby.selectedSegmentIndex == 2 {
            mbl_mw_baro_bme280_set_standby_time(device.board, MBL_MW_BARO_BME280_STANDBY_TIME_20ms)
        } else if barometerBME280Standby.selectedSegmentIndex == 3 {
            mbl_mw_baro_bme280_set_standby_time(device.board, MBL_MW_BARO_BME280_STANDBY_TIME_62_5ms)
        } else if barometerBME280Standby.selectedSegmentIndex == 4 {
            mbl_mw_baro_bme280_set_standby_time(device.board, MBL_MW_BARO_BME280_STANDBY_TIME_125ms)
        } else if barometerBME280Standby.selectedSegmentIndex == 5 {
            mbl_mw_baro_bme280_set_standby_time(device.board, MBL_MW_BARO_BME280_STANDBY_TIME_250ms)
        } else if barometerBME280Standby.selectedSegmentIndex == 6 {
            mbl_mw_baro_bme280_set_standby_time(device.board, MBL_MW_BARO_BME280_STANDBY_TIME_500ms)
        } else {
            mbl_mw_baro_bme280_set_standby_time(device.board, MBL_MW_BARO_BME280_STANDBY_TIME_1000ms)
        }
        mbl_mw_baro_bosch_write_config(device.board)
        
        let signal = mbl_mw_baro_bosch_get_altitude_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let altitude: Float = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.barometerBME280Altitude.text = String(format: "%.3f", altitude)
            }
        }
        mbl_mw_baro_bosch_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_baro_bosch_stop(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func barometerBME280StopStreamPressed(_ sender: Any) {
        barometerBME280StartStream.isEnabled = true
        barometerBME280StopStream.isEnabled = false
        let signal = mbl_mw_baro_bosch_get_altitude_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        barometerBME280Altitude.text = "X.XXX"
    }

    @IBAction func ambientLightLTR329StartStreamPressed(_ sender: Any) {
        ambientLightLTR329StartStream.isEnabled = false
        ambientLightLTR329StopStream.isEnabled = true
        switch ambientLightLTR329Gain.selectedSegmentIndex {
        case 0:
            mbl_mw_als_ltr329_set_gain(device.board, MBL_MW_ALS_LTR329_GAIN_1X)
        case 1:
            mbl_mw_als_ltr329_set_gain(device.board, MBL_MW_ALS_LTR329_GAIN_2X)
        case 2:
            mbl_mw_als_ltr329_set_gain(device.board, MBL_MW_ALS_LTR329_GAIN_4X)
        case 3:
            mbl_mw_als_ltr329_set_gain(device.board, MBL_MW_ALS_LTR329_GAIN_8X)
        case 4:
            mbl_mw_als_ltr329_set_gain(device.board, MBL_MW_ALS_LTR329_GAIN_48X)
        default:
            mbl_mw_als_ltr329_set_gain(device.board, MBL_MW_ALS_LTR329_GAIN_96X)
        }

        switch ambientLightLTR329Integration.selectedSegmentIndex {
        case 0:
            mbl_mw_als_ltr329_set_integration_time(device.board, MBL_MW_ALS_LTR329_TIME_50ms)
        case 1:
            mbl_mw_als_ltr329_set_integration_time(device.board, MBL_MW_ALS_LTR329_TIME_100ms)
        case 2:
            mbl_mw_als_ltr329_set_integration_time(device.board, MBL_MW_ALS_LTR329_TIME_150ms)
        case 3:
            mbl_mw_als_ltr329_set_integration_time(device.board, MBL_MW_ALS_LTR329_TIME_200ms)
        case 4:
            mbl_mw_als_ltr329_set_integration_time(device.board, MBL_MW_ALS_LTR329_TIME_250ms)
        case 5:
            mbl_mw_als_ltr329_set_integration_time(device.board, MBL_MW_ALS_LTR329_TIME_300ms)
        case 6:
            mbl_mw_als_ltr329_set_integration_time(device.board, MBL_MW_ALS_LTR329_TIME_350ms)
        default:
            mbl_mw_als_ltr329_set_integration_time(device.board, MBL_MW_ALS_LTR329_TIME_400ms)
        }
        
        switch ambientLightLTR329Measurement.selectedSegmentIndex {
        case 0:
            mbl_mw_als_ltr329_set_measurement_rate(device.board, MBL_MW_ALS_LTR329_RATE_50ms)
        case 1:
            mbl_mw_als_ltr329_set_measurement_rate(device.board, MBL_MW_ALS_LTR329_RATE_100ms)
        case 2:
            mbl_mw_als_ltr329_set_measurement_rate(device.board, MBL_MW_ALS_LTR329_RATE_200ms)
        case 3:
            mbl_mw_als_ltr329_set_measurement_rate(device.board, MBL_MW_ALS_LTR329_RATE_500ms)
        case 4:
            mbl_mw_als_ltr329_set_measurement_rate(device.board, MBL_MW_ALS_LTR329_RATE_1000ms)
        default:
            mbl_mw_als_ltr329_set_measurement_rate(device.board, MBL_MW_ALS_LTR329_RATE_2000ms)
        }
        mbl_mw_als_ltr329_write_config(device.board)
        
        let signal = mbl_mw_als_ltr329_get_illuminance_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let illuminance: UInt32 = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.ambientLightLTR329Illuminance.text = String(format: "%.3f lux", Double(illuminance) / 1000.0)
            }
        }
        mbl_mw_als_ltr329_start(device.board)
        
        streamingCleanup[signal] = {
            mbl_mw_als_ltr329_stop(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }

    @IBAction func ambientLightLTR329StopStreamPressed(_ sender: Any) {
        ambientLightLTR329StartStream.isEnabled = true
        ambientLightLTR329StopStream.isEnabled = false
        let signal = mbl_mw_als_ltr329_get_illuminance_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        ambientLightLTR329Illuminance.text = "X.XXX"
    }

    @IBAction func proximityTSL2671IntegrationSliderChanged(_ sender: Any) {
        proximityTSL2671IntegrationLabel.text = String(format: "%.2f", proximityTSL2671IntegrationSlider.value)
    }

    @IBAction func proximityTSL2671PulseStepperChanged(_ sender: Any) {
        proximityTSL2671PulseLabel.text = "\(Int(round(proximityTSL2671PulseStepper.value)))"
    }

    @IBAction func proximityTSL2671StartStreamPressed(_ sender: Any) {
        proximityTSL2671StartStream.isEnabled = false
        proximityTSL2671StopStream.isEnabled = true
        proximityTSL2671Drive.isEnabled = false
        proximityTSL2671IntegrationSlider.isEnabled = false
        proximityTSL2671PulseStepper.isEnabled = false
        switch proximityTSL2671Drive.selectedSegmentIndex {
        case 0:
            mbl_mw_proximity_tsl2671_set_transmitter_current(device.board, MBL_MW_PROXIMITY_TSL2671_CURRENT_12_5mA)
        default:
            mbl_mw_proximity_tsl2671_set_transmitter_current(device.board, MBL_MW_PROXIMITY_TSL2671_CURRENT_25mA)
        }
        mbl_mw_proximity_tsl2671_set_integration_time(device.board, Float(proximityTSL2671IntegrationSlider.value))
        mbl_mw_proximity_tsl2671_set_n_pulses(device.board, UInt8(round(proximityTSL2671PulseStepper.value)))
        mbl_mw_proximity_tsl2671_write_config(device.board)
        
        let signal = mbl_mw_proximity_tsl2671_get_adc_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let proximity: UInt32 = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.proximityTSL2671Proximity.text = String(format: "%d", proximity)
            }
        }
        // Create a timer to read every 700 ms
        device.timerCreate(period: 700).continueOnSuccessWith { timer in
            self.streamingCleanup[signal] = {
                mbl_mw_timer_remove(timer)
                mbl_mw_datasignal_unsubscribe(signal)
            }
            
            mbl_mw_event_record_commands(timer)
            mbl_mw_datasignal_read(signal)
            timer.eventEndRecord().continueOnSuccessWith {
                mbl_mw_timer_start(timer)
            }
        }
    }

    @IBAction func proximityTSL2671StopStreamPressed(_ sender: Any) {
        proximityTSL2671StartStream.isEnabled = true
        proximityTSL2671StopStream.isEnabled = false
        proximityTSL2671Drive.isEnabled = true
        proximityTSL2671IntegrationSlider.isEnabled = true
        proximityTSL2671PulseStepper.isEnabled = true
        let signal = mbl_mw_proximity_tsl2671_get_adc_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        proximityTSL2671Proximity.text = "XXXX"
    }

    @IBAction func photometerTCS3472IntegrationSliderChanged(_ sender: Any) {
        photometerTCS3472IntegrationLabel.text = String(format: "%.1f", photometerTCS3472IntegrationSlider.value)
    }

    @IBAction func photometerTCS3472StartStreamPressed(_ sender: Any) {
        photometerTCS3472StartStream.isEnabled = false
        photometerTCS3472StopStream.isEnabled = true
        photometerTCS3472Gain.isEnabled = false
        photometerTCS3472IntegrationSlider.isEnabled = false
        photometerTCS3472LedFlashSwitch.isEnabled = false
        switch photometerTCS3472Gain.selectedSegmentIndex {
        case 0:
            mbl_mw_cd_tcs34725_set_gain(device.board, MBL_MW_CD_TCS34725_GAIN_1X)
        case 1:
            mbl_mw_cd_tcs34725_set_gain(device.board, MBL_MW_CD_TCS34725_GAIN_4X)
        case 2:
            mbl_mw_cd_tcs34725_set_gain(device.board, MBL_MW_CD_TCS34725_GAIN_16X)
        default:
            mbl_mw_cd_tcs34725_set_gain(device.board, MBL_MW_CD_TCS34725_GAIN_60X)
        }
        
        mbl_mw_cd_tcs34725_set_integration_time(device.board, Float(photometerTCS3472IntegrationSlider.value))
        if photometerTCS3472LedFlashSwitch.isOn {
            mbl_mw_cd_tcs34725_enable_illuminator_led(device.board)
        } else {
            mbl_mw_cd_tcs34725_disable_illuminator_led(device.board)
        }
        mbl_mw_cd_tcs34725_write_config(device.board)
        
        let signal = mbl_mw_cd_tcs34725_get_adc_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let color: MblMwTcs34725ColorAdc = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.photometerTCS3472RedColor.text = "\(color.red)"
                _self.photometerTCS3472GreenColor.text = "\(color.green)"
                _self.photometerTCS3472BlueColor.text = "\(color.blue)"
                _self.photometerTCS3472ClearColor.text = "\(color.clear)"
            }
        }
        // Create a timer to read every 700 ms
        device.timerCreate(period: 700).continueOnSuccessWith { timer in
            self.streamingCleanup[signal] = {
                mbl_mw_timer_remove(timer)
                mbl_mw_datasignal_unsubscribe(signal)
            }
            mbl_mw_event_record_commands(timer)
            mbl_mw_datasignal_read(signal)
            timer.eventEndRecord().continueOnSuccessWith {
                mbl_mw_timer_start(timer)
            }
        }
    }

    @IBAction func photometerTCS3472StopStreamPressed(_ sender: Any) {
        photometerTCS3472StartStream.isEnabled = true
        photometerTCS3472StopStream.isEnabled = false
        photometerTCS3472Gain.isEnabled = true
        photometerTCS3472IntegrationSlider.isEnabled = true
        photometerTCS3472LedFlashSwitch.isEnabled = true
        let signal = mbl_mw_cd_tcs34725_get_adc_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        photometerTCS3472RedColor.text = "XXXX"
        photometerTCS3472GreenColor.text = "XXXX"
        photometerTCS3472BlueColor.text = "XXXX"
        photometerTCS3472ClearColor.text = "XXXX"
    }

    @IBAction func hygrometerBME280StartStreamPressed(_ sender: Any) {
        hygrometerBME280StartStream.isEnabled = false
        hygrometerBME280StopStream.isEnabled = true
        hygrometerBME280Oversample.isEnabled = false
        switch hygrometerBME280Oversample.selectedSegmentIndex {
        case 0:
            mbl_mw_humidity_bme280_set_oversampling(device.board, MBL_MW_HUMIDITY_BME280_OVERSAMPLING_1X)
        case 1:
            mbl_mw_humidity_bme280_set_oversampling(device.board, MBL_MW_HUMIDITY_BME280_OVERSAMPLING_2X)
        case 2:
            mbl_mw_humidity_bme280_set_oversampling(device.board, MBL_MW_HUMIDITY_BME280_OVERSAMPLING_4X)
        case 3:
            mbl_mw_humidity_bme280_set_oversampling(device.board, MBL_MW_HUMIDITY_BME280_OVERSAMPLING_8X)
        default:
            mbl_mw_humidity_bme280_set_oversampling(device.board, MBL_MW_HUMIDITY_BME280_OVERSAMPLING_16X)
        }
        
        let signal = mbl_mw_humidity_bme280_get_percentage_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let humidity: Float = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.hygrometerBME280Humidity.text = String(format: "%.2f", humidity)
            }
        }
        // Create a timer to read every 700 ms
        device.timerCreate(period: 700).continueOnSuccessWith { timer in
            self.streamingCleanup[signal] = {
                mbl_mw_timer_remove(timer)
                mbl_mw_datasignal_unsubscribe(signal)
            }
            mbl_mw_event_record_commands(timer)
            mbl_mw_datasignal_read(signal)
            timer.eventEndRecord().continueOnSuccessWith {
                mbl_mw_timer_start(timer)
            }
        }
    }

    @IBAction func hygrometerBME280StopStreamPressed(_ sender: Any) {
        hygrometerBME280StartStream.isEnabled = true
        hygrometerBME280StopStream.isEnabled = false
        hygrometerBME280Oversample.isEnabled = true
        let signal = mbl_mw_humidity_bme280_get_percentage_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
        hygrometerBME280Humidity.text = "XX.XX"
    }

    @IBAction func i2cReadBytesPressed(_ sender: Any) {
        if let deviceAddress = UInt8(i2cDeviceAddress.text!.drop0xPrefix, radix: 16) {
            if let registerAddress = UInt8(i2cRegisterAddress.text!.drop0xPrefix, radix: 16) {
                var length: UInt8 = 1
                if i2cSizeSelector.selectedSegmentIndex == 1 {
                    length = 2
                } else if i2cSizeSelector.selectedSegmentIndex == 2 {
                    length = 4
                }
                let signal = mbl_mw_i2c_get_data_signal(device.board, length, 0)!
                mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                    let bytes: [UInt8] = obj!.pointee.valueAs()
                    let _self: DeviceDetailViewController = bridge(ptr: context!)
                    DispatchQueue.main.async {
                        _self.i2cReadByteLabel.text = bytes.description
                    }
                }
                var parameters = MblMwI2cReadParameters(device_addr: deviceAddress, register_addr: registerAddress)
                mbl_mw_datasignal_read_with_parameters(signal, &parameters)
            } else {
                i2cRegisterAddress.text = ""
            }
        } else {
            i2cDeviceAddress.text = ""
        }
    }

    @IBAction func i2cWriteBytesPressed(_ sender: Any) {
        if let deviceAddress = UInt8(i2cDeviceAddress.text!.drop0xPrefix, radix: 16) {
            if let registerAddress = UInt8(i2cRegisterAddress.text!.drop0xPrefix, radix: 16) {
                if var writeData = Int32(i2cWriteByteField.text!.drop0xPrefix, radix: 16) {
                    var length: UInt8 = 1
                    if i2cSizeSelector.selectedSegmentIndex == 1 {
                        length = 2
                    } else if i2cSizeSelector.selectedSegmentIndex == 2 {
                        length = 4
                    }
                    let array = Array(Data(bytes: &writeData, count: Int(length)))
                    mbl_mw_i2c_write(device.board, deviceAddress, registerAddress, array, length)
                }
                i2cWriteByteField.text = ""
            } else {
                i2cRegisterAddress.text = ""
            }
        } else {
            i2cDeviceAddress.text = ""
        }
    }

    func updateSensorFusionSettings() {
        mbl_mw_sensor_fusion_set_acc_range(device.board, MBL_MW_SENSOR_FUSION_ACC_RANGE_16G)
        mbl_mw_sensor_fusion_set_gyro_range(device.board, MBL_MW_SENSOR_FUSION_GYRO_RANGE_2000DPS)
        mbl_mw_sensor_fusion_set_mode(device.board, MblMwSensorFusionMode(UInt32(sensorFusionMode.selectedSegmentIndex + 1)))
        sensorFusionMode.isEnabled = false
        sensorFusionOutput.isEnabled = false
        sensorFusionData = Data()
        sensorFusionGraph.fullScale = 8
    }

    @IBAction func sensorFusionStartStreamPressed(_ sender: Any) {
        sensorFusionStartStream.isEnabled = false
        sensorFusionStopStream.isEnabled = true
        sensorFusionStartLog.isEnabled = false
        sensorFusionStopLog.isEnabled = false
        updateSensorFusionSettings()
        sensorFusionData.removeAll()
        
        switch sensorFusionOutput.selectedSegmentIndex {
        case 0:
            sensorFusionGraph.hasW = true
            let signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)!
            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let euler: MblMwEulerAngles = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    _self.sensorFusionGraph.addX(_self.sensorFusionGraph.scale(Double(euler.pitch), min: -180, max: 180),
                                                 y: _self.sensorFusionGraph.scale(Double(euler.roll), min: -90, max: 90),
                                                 z: _self.sensorFusionGraph.scale(Double(euler.yaw), min: 0, max: 360),
                                                 w: _self.sensorFusionGraph.scale(Double(euler.heading), min: 0, max: 360))
                }
                _self.sensorFusionData.append("\(obj!.pointee.epoch),\(euler.pitch),\(euler.roll),\(euler.yaw),\(euler.heading)\n".data(using: String.Encoding.utf8)!)
            }
            mbl_mw_sensor_fusion_clear_enabled_mask(device.board)
            mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)
            mbl_mw_sensor_fusion_write_config(device.board)
            mbl_mw_sensor_fusion_start(device.board)
            
            streamingCleanup[signal] = {
                mbl_mw_sensor_fusion_stop(self.device.board)
                mbl_mw_sensor_fusion_clear_enabled_mask(self.device.board)
                mbl_mw_datasignal_unsubscribe(signal)
            }
        case 1:
            sensorFusionGraph.hasW = true
            let signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_QUATERNION)!
            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let quaternion: MblMwQuaternion = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    _self.sensorFusionGraph.addX(_self.sensorFusionGraph.scale(Double(quaternion.x), min: -1.0, max: 1.0),
                                                 y: _self.sensorFusionGraph.scale(Double(quaternion.y), min: -1.0, max: 1.0),
                                                 z: _self.sensorFusionGraph.scale(Double(quaternion.z), min: -1.0, max: 1.0),
                                                 w: _self.sensorFusionGraph.scale(Double(quaternion.w), min: -1.0, max: 1.0))
                }
                _self.sensorFusionData.append("\(obj!.pointee.epoch),\(quaternion.w),\(quaternion.x),\(quaternion.y),\(quaternion.z)\n".data(using: String.Encoding.utf8)!)
            }
            mbl_mw_sensor_fusion_clear_enabled_mask(device.board)
            mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_QUATERNION)
            mbl_mw_sensor_fusion_write_config(device.board)
            mbl_mw_sensor_fusion_start(device.board)
            
            streamingCleanup[signal] = {
                mbl_mw_sensor_fusion_stop(self.device.board)
                mbl_mw_sensor_fusion_clear_enabled_mask(self.device.board)
                mbl_mw_datasignal_unsubscribe(signal)
            }
        case 2:
            sensorFusionGraph.hasW = false
            let signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_GRAVITY_VECTOR)!
            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let acc: MblMwCartesianFloat = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    _self.sensorFusionGraph.addX(_self.sensorFusionGraph.scale(Double(acc.x), min: -1.0, max: 1.0),
                                                  y: _self.sensorFusionGraph.scale(Double(acc.y), min: -1.0, max: 1.0),
                                                  z: _self.sensorFusionGraph.scale(Double(acc.z), min: -1.0, max: 1.0))
                }
                _self.sensorFusionData.append("\(obj!.pointee.epoch),\(acc.x),\(acc.y),\(acc.z)\n".data(using: String.Encoding.utf8)!)
            }
            mbl_mw_sensor_fusion_clear_enabled_mask(device.board)
            mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_GRAVITY_VECTOR)
            mbl_mw_sensor_fusion_write_config(device.board)
            mbl_mw_sensor_fusion_start(device.board)
            
            streamingCleanup[signal] = {
                mbl_mw_sensor_fusion_stop(self.device.board)
                mbl_mw_sensor_fusion_clear_enabled_mask(self.device.board)
                mbl_mw_datasignal_unsubscribe(signal)
            }
        case 3:
            sensorFusionGraph.hasW = false
            let signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_LINEAR_ACC)!
            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let acc: MblMwCartesianFloat = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    _self.sensorFusionGraph.addX(Double(acc.x), y: Double(acc.y), z: Double(acc.z))
                }
                _self.sensorFusionData.append("\(obj!.pointee.epoch),\(acc.x),\(acc.y),\(acc.z)\n".data(using: String.Encoding.utf8)!)
            }
            mbl_mw_sensor_fusion_set_acc_range(device.board, MBL_MW_SENSOR_FUSION_ACC_RANGE_8G)
            mbl_mw_sensor_fusion_clear_enabled_mask(device.board)
            mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_LINEAR_ACC)
            mbl_mw_sensor_fusion_write_config(device.board)
            mbl_mw_sensor_fusion_start(device.board)
            
            streamingCleanup[signal] = {
                mbl_mw_sensor_fusion_stop(self.device.board)
                mbl_mw_sensor_fusion_clear_enabled_mask(self.device.board)
                mbl_mw_datasignal_unsubscribe(signal)
            }
        default:
            assert(false, "Added a new sensor fusion output?")
        }
    }

    @IBAction func sensorFusionStopStreamPressed(_ sender: Any) {
        sensorFusionStartStream.isEnabled = true
        sensorFusionStopStream.isEnabled = false
        sensorFusionStartLog.isEnabled = true
        sensorFusionMode.isEnabled = true
        sensorFusionOutput.isEnabled = true

        switch sensorFusionOutput.selectedSegmentIndex {
        case 0:
            let signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)!
            streamingCleanup.removeValue(forKey: signal)?()
        case 1:
            let signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_QUATERNION)!
            streamingCleanup.removeValue(forKey: signal)?()
        case 2:
            let signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_GRAVITY_VECTOR)!
            streamingCleanup.removeValue(forKey: signal)?()
        case 3:
            let signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_LINEAR_ACC)!
            streamingCleanup.removeValue(forKey: signal)?()
        default:
            assert(false, "Added a new sensor fusion output?")
        }
    }

    @IBAction func sensorFusionStartLogPressed(_ sender: Any) {
        sensorFusionStartLog.isEnabled = false
        sensorFusionStopLog.isEnabled = true
        sensorFusionStartStream.isEnabled = false
        sensorFusionStopStream.isEnabled = false
        updateSensorFusionSettings()
        mbl_mw_sensor_fusion_clear_enabled_mask(device.board)

        let signal: OpaquePointer
        switch sensorFusionOutput.selectedSegmentIndex {
        case 0:
            signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)!
            mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE)
        case 1:
            signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_QUATERNION)!
            mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_QUATERNION)
        case 2:
            signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_GRAVITY_VECTOR)!
            mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_GRAVITY_VECTOR)
        case 3:
            mbl_mw_sensor_fusion_set_acc_range(device.board, MBL_MW_SENSOR_FUSION_ACC_RANGE_8G)
            signal = mbl_mw_sensor_fusion_get_data_signal(device.board, MBL_MW_SENSOR_FUSION_DATA_LINEAR_ACC)!
            mbl_mw_sensor_fusion_enable_data(device.board, MBL_MW_SENSOR_FUSION_DATA_LINEAR_ACC)
        default:
            fatalError("Added a new sensor fusion output?")
        }
        
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggers[identifier] = logger!
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_sensor_fusion_write_config(device.board)
        mbl_mw_sensor_fusion_start(device.board)
    }

    @IBAction func sensorFusionStopLogPressed(_ sender: Any) {
        sensorFusionStartLog.isEnabled = true
        sensorFusionStopLog.isEnabled = false
        sensorFusionStartStream.isEnabled = true
        sensorFusionMode.isEnabled = true
        sensorFusionOutput.isEnabled = true
        
        let logger: OpaquePointer?
        let handler: MblMwFnData
        switch sensorFusionOutput.selectedSegmentIndex {
        case 0:
            sensorFusionGraph.hasW = true
            logger = loggers.removeValue(forKey: "euler-angles")
            handler = { (context, obj) in
                let euler: MblMwEulerAngles = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    _self.sensorFusionGraph.addX(_self.sensorFusionGraph.scale(Double(euler.pitch), min: -180, max: 180),
                                                 y: _self.sensorFusionGraph.scale(Double(euler.roll), min: -90, max: 90),
                                                 z: _self.sensorFusionGraph.scale(Double(euler.yaw), min: 0, max: 360),
                                                 w: _self.sensorFusionGraph.scale(Double(euler.heading), min: 0, max: 360))
                }
                _self.sensorFusionData.append("\(obj!.pointee.epoch),\(euler.pitch),\(euler.roll),\(euler.yaw),\(euler.heading)\n".data(using: String.Encoding.utf8)!)
            }
        case 1:
            sensorFusionGraph.hasW = true
            logger = loggers.removeValue(forKey: "quaternion")
            handler = { (context, obj) in
                let quaternion: MblMwQuaternion = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    _self.sensorFusionGraph.addX(_self.sensorFusionGraph.scale(Double(quaternion.x), min: -1.0, max: 1.0),
                                                 y: _self.sensorFusionGraph.scale(Double(quaternion.y), min: -1.0, max: 1.0),
                                                 z: _self.sensorFusionGraph.scale(Double(quaternion.z), min: -1.0, max: 1.0),
                                                 w: _self.sensorFusionGraph.scale(Double(quaternion.w), min: -1.0, max: 1.0))
                }
                _self.sensorFusionData.append("\(obj!.pointee.epoch),\(quaternion.w),\(quaternion.x),\(quaternion.y),\(quaternion.z)\n".data(using: String.Encoding.utf8)!)
            }
        case 2:
            sensorFusionGraph.hasW = false
            logger = loggers.removeValue(forKey: "gravity")
            handler = { (context, obj) in
                let acc: MblMwCartesianFloat = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    _self.sensorFusionGraph.addX(_self.sensorFusionGraph.scale(Double(acc.x), min: -1.0, max: 1.0),
                                                 y: _self.sensorFusionGraph.scale(Double(acc.y), min: -1.0, max: 1.0),
                                                 z: _self.sensorFusionGraph.scale(Double(acc.z), min: -1.0, max: 1.0))
                }
                _self.sensorFusionData.append("\(obj!.pointee.epoch),\(acc.x),\(acc.y),\(acc.z)\n".data(using: String.Encoding.utf8)!)
            }
        case 3:
            sensorFusionGraph.hasW = false
            logger = loggers.removeValue(forKey: "linear-acceleration")
            handler = { (context, obj) in
                let acc: MblMwCartesianFloat = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    _self.sensorFusionGraph.addX(Double(acc.x), y: Double(acc.y), z: Double(acc.z))
                }
                _self.sensorFusionData.append("\(obj!.pointee.epoch),\(acc.x),\(acc.y),\(acc.z)\n".data(using: String.Encoding.utf8)!)
            }
        default:
            fatalError("Added a new sensor fusion output?")
        }
        guard logger != nil else {
            return
        }
        mbl_mw_sensor_fusion_stop(device.board)
        mbl_mw_sensor_fusion_clear_enabled_mask(device.board)
        
        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        
        sensorFusionData.removeAll()
        mbl_mw_logger_subscribe(logger, bridge(obj: self), handler)
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            DispatchQueue.main.async {
                _self.hud.progress = Float(progress)
            }
            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.hud.mode = .indeterminate
                    _self.hud.label.text = "Clearing Log..."
                }
                _self.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.hud.hide(animated: true)
                        if error != nil {
                            _self.deviceConnected()
                        }
                    }
                }
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
    }

    @IBAction func sensorFusionSendDataPressed(_ sender: Any) {
        send(sensorFusionData, title: "SensorFusion")
    }

}

extension DeviceDetailViewController: DFUProgressDelegate {
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        hud?.progress = Float(progress) / 100.0
    }
}
