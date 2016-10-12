.. highlight:: Objective-C

AccelerometerBMI160
===================

This specific accelerometer is configured via properties on the `MBLAccelerometerBMI160 <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAccelerometerBMI160.html>`_ class.  This section shows how to use its advanced features.

Notify on Tap
-------------

Events can be generated for a single or double tap along any of the axis'.

::

    accelerometerBMI160.tapType = MBLAccelerometerTapTypeSingle; // Default: Single tap
    [accelerometerBMI160.tapEvent startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"Tapped Me!");
    }];

Notify on Orientation Change
----------------------------

Events can be generated when an orientation change of the MetaWear occurs.

::

    [accelerometerBMI160.orientationEvent startNotificationsWithHandlerAsync:^(MBLOrientationData *obj, NSError *error) {
        NSLog(@"Flipped Me: %@", obj);
    }];

Notify when Placed Flat
-----------------------

Events can be generated when the MetaWear is set down on a flat surface, or removed.

::

    [accelerometerBMI160.flatEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"%@" obj.value.boolValue ? @"Flat" : "Not Flat");
    }];

Notify on Step
--------------

Events can be generated when a step pattern is detected.

::

    [accelerometerBMI160.stepEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Nice Step!");
    }];

Notify on Freefall
------------------

Events can be generated when free-fall is detected.

::

    accelerometerBMI160.lowOrHighGEvent.highGEnabledAxis = 0;
    accelerometerBMI160.lowOrHighGEvent.lowGEnabled = YES;
    [accelerometerBMI160.lowOrHighGEvent startNotificationsWithHandlerAsync:^(MBLDataSample *result, NSError *error) {
        NSLog(@"Dropped Me!");
    }];

Notify on Shock
---------------

Events can be generated when high acceleration (shock) is detected.

::

    accelerometerBMI160.fullScaleRange = MBLAccelerometerBMI160Range16G;
        
    accelerometerBMI160.lowOrHighGEvent.lowGEnabled = NO;
    accelerometerBMI160.lowOrHighGEvent.highGThreshold = 8.0;
    accelerometerBMI160.lowOrHighGEvent.highGEnabledAxis = MBLAccelerometerAxisX;
        
    [accelerometerBMI160.lowOrHighGEvent startNotificationsWithHandlerAsync:^(MBLDataSample *result, NSError *error) {
        NSLog(@"8G Shock in X-Axis!");
    }];

