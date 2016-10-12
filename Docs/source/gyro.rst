.. highlight:: Objective-C

Gyro
====

Some MetaWear boards comes with a builtin gyroscope.  It's configured via properties on the `MBLGyro <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGyro.html>`_ class.

To meet specific needs, different MetaWear models have different gyroscope sensors, so the ``MBLGyro`` class is actually a generic abstraction of all gyroscopes.  You can up-cast to one of our derived gyroscope objects in order to access advanced features.

Raw Data
--------

One thing common to all gyroscopes is the ability to access raw x, y, and z axis rotational data

::

    device.gyro.sampleFrequency = 100; // Default: 100 Hz
    [device.gyro.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLGyroData *obj, NSError *error) {
        NSLog(@"X = %f, Y = %f, Z = %f", obj.x, obj.y, obj.z);
    }];

Single Axis Data
----------------

You can also access a single axis of gyroscope data.

::

    [device.gyro.xAxisReadyEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"x-axis: %@", obj);
    }];

Cast to Derived Class
---------------------

To use advanced gyroscope features it's necessary to figure out exactly what gyroscope your MetaWear has.

::

    if ([device.gyro isKindOfClass:[MBLGyroBMI160 class]]) {
    	MBLGyroBMI160 *gyroBMI160 = (MBLGyroBMI160 *)device.gyro;
    }

