.. highlight:: Objective-C

Ambient Light
=============

Some MetaWear boards comes with a builtin ambient light sensor.  It's configured via properties on the `MBLAmbientLight <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAmbientLight.html>`_ class.

To meet specific needs, different MetaWear models have different ambient light sensors, so the ``MBLAmbientLight`` class is actually a generic abstraction of all ambient light sensors.  You can up-cast to one of our derived ambient light sensor objects in order to access advanced features.

Illuminance
-----------

One thing common to all ambient light sensors is the ability to measure the SI unit of illuminance called lux.

::

    [[device.ambientLight.illuminance readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"ambient light: %f lux", result.value.floatValue);
    }];

Cast to Derived Class
---------------------

To use advanced ambient light features it's necessary to figure out exactly what ambient light sensor your MetaWear has.

::

    if ([device.ambientLight isKindOfClass:[MBLAmbientLightLTR329 class]]) {
        MBLAmbientLightLTR329 *ambientLightLTR329 = (MBLAmbientLightLTR329 *)device.ambientLight;
    }

