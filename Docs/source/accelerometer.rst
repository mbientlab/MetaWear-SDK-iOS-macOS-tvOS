.. highlight:: Objective-C

Accelerometer
=============

The MetaWear board comes with a builtin accelerometer.  It's configured via properties on the `MBLAccelerometer <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAccelerometer.html>`_ class.

To meet specific needs, different MetaWear models have different accelerometer sensors, so the ``MBLAccelerometer`` class is actually a generic abstraction of all accelerometers.  You can up-cast to one of our derived accelerometer objects in order to access advanced features.

Raw Data
--------

One thing common to all accelerometers is the ability to access raw x, y, and z axis data

::

    device.accelerometer.sampleFrequency = 100; // Default: 100 Hz
    [device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        NSLog(@"X = %f, Y = %f, Z = %f", obj.x, obj.y, obj.z);
    }];

Raw RMS Data
------------

You can also access the root mean square (RMS) of the accelerometer data

::

    [device.accelerometer.rmsDataReadyEvent startNotificationsWithHandlerAsync:^(MBLRMSAccelerometerData *obj, NSError *error) {
        NSLog(@"RMS: %@", obj);
    }];

Single Axis Data
----------------

You can also access a single axis of accelerometer data.

::

    [device.accelerometer.xAxisReadyEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"x-axis: %@", obj);
    }];

Cast to Derived Class
---------------------

To use advanced accelerometer features it's necessary to figure out exactly what accelerometer your MetaWear has.

::

    if ([device.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
        MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)device.accelerometer;
    } else if ([device.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]) {
        MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)device.accelerometer;
    }

