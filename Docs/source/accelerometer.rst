.. highlight:: swift

Accelerometer
=============

The MetaWear board comes with a builtin accelerometer.  It's configured via properties on the `MBLAccelerometer <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAccelerometer.html>`_ class.

To meet specific needs, different MetaWear models have different accelerometer sensors, so the ``MBLAccelerometer`` class is actually a generic abstraction of all accelerometers.  You can up-cast to one of our derived accelerometer objects in order to access advanced features.

Raw Data
--------

One thing common to all accelerometers is the ability to access raw x, y, and z axis data

::

    device.accelerometer?.sampleFrequency = 100
    device.accelerometer?.dataReadyEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("X = \(obj.x), Y = \(obj.y), Z = \(obj.z)")
        }
    })

Raw RMS Data
------------

You can also access the root mean square (RMS) of the accelerometer data

::

    device.accelerometer?.rmsDataReadyEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("RMS = \(obj.rms)")
        }
    })

Single Axis Data
----------------

You can also access a single axis of accelerometer data.

::

    device.accelerometer?.xAxisReadyEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("x-axis = \(obj.value)")
        }
    })

Cast to Derived Class
---------------------

To use advanced accelerometer features it's necessary to figure out exactly what accelerometer your MetaWear has.

::

    if let accelerometerMMA8452Q = device.accelerometer as? MBLAccelerometerMMA8452Q {

    } else if let accelerometerBMI160 = device.accelerometer as? MBLAccelerometerBMI160 {

    }
