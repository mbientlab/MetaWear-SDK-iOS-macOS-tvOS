.. highlight:: swift

BarometerBMP280
===============

This specific barometer is configured via properties on the `MBLBarometerBMP280 <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLBarometerBMP280.html>`_ class.  This section shows how to use its advanced features.

Periodic Readings
-----------------

This barometer has a built in timer, so you can program it to directly perform periodic reads.

::

    // Use the oversampling mode to balance power vs performance
    barometerBMP280.pressureOversampling = .ultraHighResolution;
    // Use the builtin average filter to eliminate short term noise
    barometerBMP280.hardwareAverageFilter = .average16;
    // This determines how long the device will sleep between samples,
    // so it's not directly the period, since the sample itself can
    // take several ms to complete.
    barometerBMP280.standbyTime = .standby0_5;

    // Or you can use periodicPressure below
    barometerBMP280.periodicAltitude.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("altitude: \(obj.value.doubleValue) meters")
        }
    })
