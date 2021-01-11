.. highlight:: swift

MetaWear Scanner
================

Scanning and discovery of MetaWear devices is done through the `MetaWearScanner <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWearScanner.html>`_.  The manager also maintains a list of previously saved MetaWear's for simple re-connecting.

Shared Manager
--------------

The `MetaWearScanner <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWearScanner.html>`_ class has a global ``shared`` instance, or you can create your own.

::

    MetaWearScanner.shared

Scanning for MetaWears
----------------------

It's simple to start scanning for advertising MetaWear devices using the `MetaWearScanner <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWearScanner.html>`_:

::

    MetaWearScanner.shared.startScan(allowDuplicates: false) { (device) in
        print("Found MetaWear: \(device)")
    })

Scanning for Nearby MetaWears
-----------------------------

In the previous example we set ``startScan(allowDuplicates: false)`` which meant that the handler block would be invoked only when a new MetaWear was detected.  However, by allowing duplicates the handler block will be invoked each time an advertisement packet is detected (even from an already detected MetaWear).

This feature is handy because the ``rssi`` property on the discovered `MetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWear.html>`_ objects get continually updated, so you can get a real time sense for how far it is from the Apple device.

::

    let MIN_ALLOWED_RSSI = -45; // Depending on your specific application this value will change!

    MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
        // Reject if the signal strength is too low to be close enough (find through experiment)
        guard let rssi = device.averageRSSI(), rssi > MIN_ALLOWED_RSSI else {
            return
        }
        // At this point we have a close MetaWear, do what you please with it!
    }

Retrieving MetaWears
--------------------

It's common to want to reconnect to the same MetaWear.  For that, you can call the ``remember`` method on `MetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWear.html>`_, and then use the scanner to retrieve it later on:

The array is ordered so the first device remembered is at index 0, next device at index 1, and so on.

::

    MetaWearScanner.shared.retrieveSavedMetaWearsAsync().continueOnSuccessWith { array in
        let savedDevice = array.first
    }
