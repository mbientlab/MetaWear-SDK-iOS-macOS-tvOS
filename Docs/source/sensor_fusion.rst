.. highlight:: swift

Sensor Fusion
=============

The MetaMotion family of boards comes with a builtin Sensor Fusion algorithm.  It's configured via properties on the `MBLSensorFusion <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLSensorFusion.html>`_ class.  When using the sensor fusion algorithm, it is important that you do not simultaenously use the Accelerometer, Gyro, and Magnetometer modules; the algorithm configures those sensors internally based on how you configure the sensor fusion algorithm.

As explained `here <http://www.chrobotics.com/library/attitude-estimation>`_.  When estimating attitude and heading, the best results are obtained by combining data from multiple types of sensors to take advantage of their relative strengths. For example, rate gyros can be integrated to produce angle estimates that are reliable in the short-term, but that tend to drift in the long-term. Accelerometers, on the other hand, are sensitive to vibration and other non-gravity accelerations in the short-term, but can be trusted in the long-term to provide angle estimates that do no degrade as time progresses.  Combining rate gyros and accelerometers can produce the best of both worlds - angle estimates that are resistant to vibration and immune to long-term angular drift.

Mode
----
The sensor fusion algorithm has 4
`fusion modes <https://mbientlab.com/docs/metawear/ios/latest/Constants/MBLSensorFusionMode.html>`_, listed in the below table:

======== ==========================================================================
Mode     Description
======== ==========================================================================
NDoF     Calculates absolute roeintation from accelerometer, gyro, and magnetometer
IMUPlus  Calculates relative orientation in space from accelerometer and gyro data
Compass  Determines geographic direction from th Earth's magnetic field
M4G      Similar to IMUPlus except rotation is detected with the magnetometer
======== ==========================================================================

Attitude and Heading
--------------------

We provide attitude and heading information using both Euler Angles and Quaternions.  Compared to quaternions, Euler Angles are simple and intuitive and they lend themselves well to simple analysis and control.  On the other hand, Euler Angles are limited by a phenomenon called Gimbal Lock.  In applications where the sensor will never operate near pitch angles of +/- 90 degrees, Euler Angles are a good choice.  A quaternion is a four-element vector that can be used to encode any rotation in a 3D coordinate system.  Technically, a quaternion is composed of one real element and three complex elements.  It's best to start with Euler Angles unless you are already familiar with quaternions.

::

    device.sensorFusion?.eulerAngle.startNotificationsAsync(handler: { (obj, error) in
        print(String(describing: obj))
    })
    device.sensorFusion?.quaternion.startNotificationsAsync(handler: { (obj, error) in
        print(String(describing: obj))
    })

Gravity Reading
---------------

This looks at the acceleration due to gravity and removes the acceleration due to motion.  This vector always points to Earth.

::

    device.sensorFusion?.gravity.startNotificationsAsync(handler: { (obj, error) in
        print(String(describing: obj))
    })

Linear Acceleration
-------------------

This looks at the acceleration due to motion and removes the acceleration due to gravity.

::

    device.sensorFusion?.linearAcceleration.startNotificationsAsync(handler: { (obj, error) in
        print(String(describing: obj))
    })

Corrected Sensor Readings
-------------------------

Sensor fusion algorithms are able to use the strengths of various sensors to improve the weaknesses of others.  This allows us to extract more accurate readings of sensor values.  Keep in mind that each sensor fusion mode has different sets of available data and produces it at different rates.

======== ===== ===== ====
Mode     Acc   Gyro  Mag
======== ===== ===== ====
NDoF     100Hz 100Hz 25Hz
IMUPlus  100Hz 100Hz N/A
Compass  25Hz  N/A   25Hz
M4G      50Hz  N/A   50Hz
======== ===== ===== ====

::

    device.sensorFusion?.acceleration.startNotificationsAsync(handler: { (obj, error) in
        print(String(describing: obj))
    })
    device.sensorFusion?.rotation.startNotificationsAsync(handler: { (obj, error) in
        print(String(describing: obj))
    })
    device.sensorFusion?.magneticField.startNotificationsAsync(handler: { (obj, error) in
        print(String(describing: obj))
    })
