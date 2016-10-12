.. highlight:: Objective-C

Magnetometer
============

Some MetaWear boards comes with a builtin magnetometer.  It's configured via properties on the `MBLMagnetometer <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMagnetometer.html>`_ class.

To meet specific needs, different MetaWear models have different magnetometer sensors, so the ``MBLMagnetometer`` class is actually a generic abstraction of all magnetometers.  You can up-cast to one of our derived magnetometer objects in order to access advanced features.

Raw Data
--------

One thing common to all magnetometers is the ability to access raw x, y, and z axis magnetic field data.

::

    [[device.magnetometer.magneticField readAsync] success:^(MBLMagnetometerData * _Nonnull result) {
        NSLog(@"X = %f, Y = %f, Z = %f", result.x, result.y, result.z);
    }];

Cast to Derived Class
---------------------

To use advanced magnetometer features it's necessary to figure out exactly what magnetometer your MetaWear has.

::

    if ([device.magnetometer isKindOfClass:[MBLMagnetometerBMM150 class]]) {
        MBLMagnetometerBMM150 *magnetometerBMM150 = (MBLMagnetometerBMM150 *)device.magnetometer;
    }

