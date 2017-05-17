.. highlight:: swift

Humidity BME280
===============

This specific color sensor is configured via properties on the `MBLHygrometerBME280 <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLHygrometerBME280.html>`_ class.  This section shows how to use its advanced features.


Configuration
-------------
For humidity measurements, oversampling can be used to reduce the noise.  Oversampling modes are set with `humidityOversampling <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLHygrometerBME280.html#//api/name/humidityOversampling>`_ property.

::

    // set oversampling to 16x
    hygrometerBME280.humidityOversampling = .oversample16X

Humidity Data
-------------
Relative humidity data is a float value from 0 to 100 percent.

::

    hygrometerBME280.periodicHumidity.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Humidity: \(obj.value.doubleValue)")
        }
    })
