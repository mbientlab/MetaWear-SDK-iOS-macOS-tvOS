.. highlight:: swift

MetaWear Manager
================

Scanning and discovery of MetaWear devices is done through the `MBLMetaWearManager <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWearManager.html>`_.  The manager also maintains a list of previously saved MetaWear's for simple re-connecting.

Shared Manager
--------------

The `MBLMetaWearManager <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWearManager.html>`_ class should not be instantiated directly.  Instead, always use the shared manager as shown.

::

    let manager = MBLMetaWearManager.shared()

Scanning for MetaWears
----------------------

It's simple to start scanning for advertising MetaWear devices using the `MBLMetaWearManager <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWearManager.html>`_:

::

    MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: false, handler: { array in
        for device in array {
            print("Found MetaWear: \(device)")
        }
    })

Scanning for Nearby MetaWears
-----------------------------

In the previous example we set ``startScan(forMetaWearsAllowDuplicates: false`` which meant that the handler block would be invoked only when a new MetaWear was detected.  However, by allowing duplicates the handler block will be invoked each time an advertisement packet is detected (even from an already detected MetaWear).

This feature is handy because the ``discoveryTimeRSSI`` property on the discovered `MBLMetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html>`_ objects get continually updated, so you can get a real time sense for how far it is from the Apple device.

::

    let MAX_ALLOWED_RSSI = -15; // The RSSI calculation sometimes produces erroneous values, we know anything above this value is invalid
    let MIN_ALLOWED_RSSI = -45; // Depending on your specific application this value will change!

    MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: true, handler: { array in
        for device in array {
            guard device.discoveryTimeRSSI != nil else {
                continue
            }
            // Reject any value above a reasonable range
            if device.discoveryTimeRSSI!.intValue > MAX_ALLOWED_RSSI {
                continue
            }
            // Reject if the signal strength is too low to be close enough (find through experiment)
            if device.discoveryTimeRSSI!.intValue < MIN_ALLOWED_RSSI {
                continue
            }
            MBLMetaWearManager.shared().stopScan()
            // At this point we have a close MetaWear, do what you please with it!
        }
    })

Retrieving MetaWears
--------------------

It's common to want to reconnect to the same MetaWear.  For that, you can call the ``rememberDevice`` method on `MBLMetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html>`_, and then use the manager to retrieve it later on:

The array is ordered so the first device remembered is at index 0, next device at index 1, and so on.

::

    MBLMetaWearManager.shared().retrieveSavedMetaWearsAsync().success { array in
        let savedDevice = array.firstObject
    }

Dispatch Queue
--------------

Choose the queue on which all callbacks from the MetaWear API occur on.  Defaults to the main queue.

Since we use `Bolts-ObjC <https://github.com/BoltsFramework/Bolts-ObjC>`_ throughout the API we provide a ``dispatchExecutor`` which uses the dispatch queue.  Also, we provide easy to use shortcuts ``success:`` and ``failure:`` for the common cases of handling callbacks.

::

    MBLMetaWearManager.shared().dispatchQueue = myCustomQueue
                                

Minimum Firmware Required
-------------------------

As we release new firmware versions, old ones may no longer be suppored, so this property indicates the oldest possible firmware the SDK can successfully connect to.

This property is writeable, so you can enforce an even newer version for your app.

::

    MBLMetaWearManager.shared().minimumRequiredVersion = .version1_2_0
