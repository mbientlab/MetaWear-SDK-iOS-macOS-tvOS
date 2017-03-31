.. highlight:: swift

Magnetometer
============

Some MetaWear boards comes with a builtin magnetometer.  It's configured via properties on the `MBLMagnetometer <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMagnetometer.html>`_ class.

To meet specific needs, different MetaWear models have different magnetometer sensors, so the ``MBLMagnetometer`` class is actually a generic abstraction of all magnetometers.  You can up-cast to one of our derived magnetometer objects in order to access advanced features.


Cast to Derived Class
---------------------

There is currently nothing in the generic ``MBLMagnetometer`` class, so you need to use the `MagnetometerBMM150 <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MagnetometerBMM150.html>`_ derived class.
::

    if let magnetometerBMM150 = device.magnetometer as? MBLMagnetometerBMM150 {
    }

