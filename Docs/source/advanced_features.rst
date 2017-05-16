.. highlight:: swift

Advanced Features 
=================

High Frequency Streaming
------------------------

Some developers may want to stream data from multiple motion sensors simultaneously or individually at frequencies higher than 100Hz. To accommodate this use case, accelerometer and gyro have a packed output mode that combines 3 data samples into 1 ble packet increasing the data throughput by 3x.  Simply enable notifications on the ``packedDataReadEvent`` to use this feature.

Persistent Configuration
------------------------

``MBLRestorable`` object containing custom settings and events that are programmed to the MetaWear and preserved between disconnects and app termination.

Use ``setConfigurationAsync`` to assign a new configuration object to this MetaWear.  This only needs to be called once, likely after you confirm the device from a scanning screen or such.  Upon calling it will erase all non-volatile memory the device (which requires disconnect), then perform reset, once its comes back online we will connect and invoke the runOnDeviceBoot method.   All calls in that method are persisted device side so after any future reset these settings will be applied automatically.

The properties of the configuration objected are automatically persisted to disk after interactions with the board.  If, however, you make changes to various module setting without acutally interacting, then it may be useful to call ``synchronizeAsync`` to force a save to disk.

::

    device.setConfigurationAsync(DeviceConfiguration()).success { _ in
        print("Settings successfully applied")
    }.failure { error in
        print("Something went wrong, we should try again: \(error)")
    }

Updating Firmware
-----------------

The firmware running on the MetaWear is periodically updated by MbientLab with additional features and bug-fixes.  To update, you first call a MetaWear API which puts the device in a special bootloader mode, then use the Nordic Semiconductor `IOS-DFU-Librarly <https://github.com/NordicSemiconductor/IOS-DFU-Library>`_ to upload the new firmware.  We recommend looking at our `Sample App <https://github.com/mbientlab/Metawear-SampleiOSApp>`_ for an example on how to integrate.

This is one API you can call WITHOUT being connected, there are some cases where you can't connect because the firmware is too old, but you still need to be able to update it!

::

    device.prepareForFirmwareUpdateAsync().success { result in
        var selectedFirmware: DFUFirmware?
        if result.firmwareUrl.pathExtension.caseInsensitiveCompare("zip") == .orderedSame {
            selectedFirmware = DFUFirmware(urlToZipFile: result.firmwareUrl)
        } else {
            selectedFirmware = DFUFirmware(urlToBinOrHexFile: result.firmwareUrl, urlToDatFile: nil, type: .application)
        }
        self.initiator = DFUServiceInitiator(centralManager: result.centralManager, target: result.target)
        let _ = self.initiator?.with(firmware: selectedFirmware!)
        self.initiator?.forceDfu = true // We also have the DIS which confuses the DFU library
        self.initiator?.logger = self // - to get log info
        self.initiator?.delegate = self // - to be informed about current state and errors
        self.initiator?.peripheralSelector = self
        self.initiator?.progressDelegate = self // - to show progress bar

        self.dfuController = self.initiator?.start()
    }.failure { error in
        print("Something went wrong, we should try again in 60 seconds: \(error)")
    }
