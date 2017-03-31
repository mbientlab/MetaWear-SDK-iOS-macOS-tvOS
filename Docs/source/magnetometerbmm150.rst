.. highlight:: swift

MagnetometerBMM150
==================

This specific magnetometer is configured via properties on the `MagnetometerBMM150 <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MagnetometerBMM150.html>`_ class.  This section shows how to use its advanced features.

Periodic Readings
-----------------

This magnetometer sensor has a built in timer, so you can program it directly to return periodic data.

::

    magnetometerBMM150.periodicMagneticField.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Magnetic Field: \(obj)")
        }
    })
