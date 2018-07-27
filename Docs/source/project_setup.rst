Project Setup
=============
Before you begin coding your app, you will need to add the MetaWear API to your project.  If you are new to Xcode and not familiar with CocoaPods we have povided an `app template <https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/tree/master/StarterProject>`_ that has taken care of all the steps outlined on this page.

Compile Dependency
------------------

.. highlight:: ruby

To add the MetaWear SDK as a dependency to your project you should setup `CocoaPods <https://guides.cocoapods.org/using/getting-started.html>`_, and add the following line to your Podfile:  ::

    # The subspecs are all optional, but might be useful
    pod "MetaWear", :subspecs => ['UI', 'AsyncUtils', 'Mocks', 'DFU']

.. highlight:: console

Then run:  ::

    pod install

Finding Your Device
-------------------

.. highlight:: swift

Now retrieve a MetaWear object corresponding to your board by scanning for it.

::

    import MetaWear
    import MetaWearCpp

    MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
        // We found a MetaWear board, see if it is close
        if device.rssi.intValue > -50 {
            // Hooray! We found a MetaWear board, so stop scanning for more
            MetaWearScanner.shared.stopScan()
            // Connect to the board we found
            device.connectAndSetup().continueWith { t in
                if let error = t.error {
                    // Sorry we couldn't connect
                    print(error)
                } else {
                    // Hooray! We connected to a MetaWear board, so flash its LED!
                    var pattern = MblMwLedPattern()
                    mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_PULSE)
                    mbl_mw_led_stop_and_clear(device.board)
                    mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_GREEN)
                    mbl_mw_led_play(device.board)
                }
            }
        }
    }
