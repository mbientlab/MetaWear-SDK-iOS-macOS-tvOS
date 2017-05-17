.. highlight:: swift

AccelerometerMMA8452Q
=====================

This specific accelerometer is configured via properties on the `MBLAccelerometerMMA8452Q <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAccelerometerMMA8452Q.html>`_ class.  This section shows how to use its advanced features.

Notify on Tap
-------------

Events can be generated for a single or double tap along any of the axis'.

::

    accelerometerMMA8452Q.tapDetectionAxis = .X
    accelerometerMMA8452Q.tapType = .single
    accelerometerMMA8452Q.tapEvent.startNotificationsAsync(handler: { (obj, error) in
        print("Tapped Me!")
    })

Notify on Orientation Change
----------------------------

Events can be generated when an orientation change of the MetaWear occurs.

::

    accelerometerMMA8452Q.orientationEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Flipped Me: \(obj)")
        }
    })

Notify on Free Fall
-------------------

Events can be generated when the MetaWear goes into free fall.

::

    accelerometerMMA8452Q.freeFallEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Dropped Me!")
        }
    })

Notify on Shake
---------------

Events can be generated when you shake the MetaWear.

::

    accelerometerMMA8452Q.shakeEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Yeah YOU! Shook me all night long")
        }
    })

