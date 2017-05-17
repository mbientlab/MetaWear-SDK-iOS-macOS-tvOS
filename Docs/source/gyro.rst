.. highlight:: swift

Gyro
====

Some MetaWear boards comes with a builtin gyroscope.  It's configured via properties on the `MBLGyro <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGyro.html>`_ class.

To meet specific needs, different MetaWear models have different gyroscope sensors, so the ``MBLGyro`` class is actually a generic abstraction of all gyroscopes.  You can up-cast to one of our derived gyroscope objects in order to access advanced features.

Raw Data
--------

One thing common to all gyroscopes is the ability to access raw x, y, and z axis rotational data

::

    device.gyro?.sampleFrequency = 100.0
    device.gyro?.dataReadyEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("X = \(obj.x), Y = \(obj.y), Z = \(obj.z)")
        }
    })

Single Axis Data
----------------

You can also access a single axis of gyroscope data.

::

    device.gyro?.xAxisReadyEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("x-axis: \(obj.value.doubleValue)")
        }
    })

Cast to Derived Class
---------------------

To use advanced gyroscope features it's necessary to figure out exactly what gyroscope your MetaWear has.

::

    if let gyroBMI160 = device.gyro as? MBLGyroBMI160 {
    }
