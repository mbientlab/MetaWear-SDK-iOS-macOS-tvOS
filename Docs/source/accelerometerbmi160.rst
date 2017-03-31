.. highlight:: swift

AccelerometerBMI160
===================

This specific accelerometer is configured via properties on the `MBLAccelerometerBMI160 <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAccelerometerBMI160.html>`_ class.  This section shows how to use its advanced features.

Notify on Tap
-------------

Events can be generated for a single or double tap along any of the axis'.

::

    accelerometerBMI160.tapEvent.type = .single
    accelerometerBMI160.tapEvent.startNotificationsAsync(handler: { (obj, error) in
        print("Tapped Me!")
    })

Notify on Orientation Change
----------------------------

Events can be generated when an orientation change of the MetaWear occurs.

::

    accelerometerBMI160.orientationEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Flipped Me: \(obj)")
        }
    })

Notify when Placed Flat
-----------------------

Events can be generated when the MetaWear is set down on a flat surface, or removed.

::

    accelerometerBMI160.flatEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print(obj.isFlat ? "Flat" : "Not Flat")
        }
    })

Notify on Step
--------------

Events can be generated when a step pattern is detected.

::

    accelerometerBMI160.stepEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Nice Step!")
        }
    })

Notify on Freefall
------------------

Events can be generated when free-fall is detected.

::

    accelerometerBMI160.lowOrHighGEvent.highGEnabledAxis = .X
    accelerometerBMI160.lowOrHighGEvent.lowGEnabled = true;
    accelerometerBMI160.lowOrHighGEvent.startNotificationsAsync(handler: { (obj, error) in
        print("Dropped Me!")
    })

Notify on Shock
---------------

Events can be generated when high acceleration (shock) is detected.

::

    accelerometerBMI160.fullScaleRange = .range16G;

    accelerometerBMI160.lowOrHighGEvent.lowGEnabled = false;
    accelerometerBMI160.lowOrHighGEvent.highGThreshold = 8.0;
    accelerometerBMI160.lowOrHighGEvent.highGEnabledAxis = .X;
    accelerometerBMI160.lowOrHighGEvent.startNotificationsAsync(handler: { (obj, error) in
        print("8G Shock in X-Axis!")
    })
