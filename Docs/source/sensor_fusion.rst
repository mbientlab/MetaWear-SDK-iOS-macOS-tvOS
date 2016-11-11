.. highlight:: Objective-C

Sensor Fusion
=============

The MetaMotion family of boards comes with a builtin Sensor Fusion algorithm.  It's configured via properties on the `MBLSensorFusion <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLSensorFusion.html>`_ class.

As explained `here <http://www.chrobotics.com/library/attitude-estimation>`_.  When estimating attitude and heading, the best results are obtained by combining data from multiple types of sensors to take advantage of their relative strengths. For example, rate gyros can be integrated to produce angle estimates that are reliable in the short-term, but that tend to drift in the long-term. Accelerometers, on the other hand, are sensitive to vibration and other non-gravity accelerations in the short-term, but can be trusted in the long-term to provide angle estimates that do no degrade as time progresses.  Combining rate gyros and accelerometers can produce the best of both worlds - angle estimates that are resistant to vibration and immune to long-term angular drift.

Attitude and Heading
--------------------

We provide attitude and heading information using both Euler Angles and Quaternions.  Compared to quaternions, Euler Angles are simple and intuitive and they lend themselves well to simple analysis and control.  On the other hand, Euler Angles are limited by a phenomenon called Gimbal Lock.  In applications where the sensor will never operate near pitch angles of +/- 90 degrees, Euler Angles are a good choice.  A quaternion is a four-element vector that can be used to encode any rotation in a 3D coordinate system.  Technically, a quaternion is composed of one real element and three complex elements.  It's best to start with Euler Angles unless you are already familiar with quaternions.

::

    [self.device.sensorFusion.eulerAngle startNotificationsWithHandlerAsync:^(MBLEulerAngleData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    [self.device.sensorFusion.quaternion startNotificationsWithHandlerAsync:^(MBLQuaternionData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];

Gravity Reading
---------------

This looks at the acceleration due to gravity and removes the acceleration due to motion.  This vector always points to Earth.

::

    [self.device.sensorFusion.gravity startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];

Linear Acceleration
-------------------

This looks at the acceleration due to motion and removes the acceleration due to gravity.

::

    [self.device.sensorFusion.gravity startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];

Corrected Sensor Readings
-------------------------

Sensor fusion algorithms are able to use the strengths of various sensors to improve the weaknesses of others.  This allows us to extract more accurate readings of sensor values.

::

    [device.sensorFusion.acceleration startNotificationsWithHandlerAsync:^(MBLCorrectedAccelerometerData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    [device.sensorFusion.rotation startNotificationsWithHandlerAsync:^(MBLCorrectedGyroData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    [device.sensorFusion.magneticField startNotificationsWithHandlerAsync:^(MBLCorrectedMagnetometeData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
