.. highlight:: Objective-C

AccelerometerMMA8452Q
=====================

This specific accelerometer is configured via properties on the `MBLAccelerometerMMA8452Q <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAccelerometerMMA8452Q.html>`_ class.  This section shows how to use its advanced features.

Notify on Tap
-------------

Events can be generated for a single or double tap along any of the axis'.

::

    accelerometerMMA8452Q.tapDetectionAxis = MBLAccelerometerAxisX; // Default: X-axis tap
    accelerometerMMA8452Q.tapType = MBLAccelerometerTapTypeSingle; // Default: Single tap
    [accelerometerMMA8452Q.tapEvent startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"Tapped Me!");
    }];

Notify on Orientation Change
----------------------------

Events can be generated when an orientation change of the MetaWear occurs.

::

    [accelerometerMMA8452Q.orientationEvent startNotificationsWithHandlerAsync:^(MBLOrientationData *obj, NSError *error) {
        NSLog(@"Flipped Me: %@", obj);
    }];

Notify on Free Fall
-------------------

Events can be generated when the MetaWear goes into free fall.

::

    [accelerometerMMA8452Q.freeFallEvent startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"Dropped Me!");
    }];

Notify on Shake
---------------

Events can be generated when you shake the MetaWear.

::

    [accelerometerMMA8452Q.shakeEvent startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"Yeah YOU! Shook me all night long");
    }];

