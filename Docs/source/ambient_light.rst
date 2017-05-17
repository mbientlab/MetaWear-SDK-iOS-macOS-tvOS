.. highlight:: swift

Ambient Light
=============

Some MetaWear boards comes with a builtin ambient light sensor.  It's configured via properties on the `MBLAmbientLight <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAmbientLight.html>`_ class.

To meet specific needs, different MetaWear models have different ambient light sensors, so the ``MBLAmbientLight`` class is actually a generic abstraction of all ambient light sensors.  You can up-cast to one of our derived ambient light sensor objects in order to access advanced features.

Cast to Derived Class
---------------------

There is currently nothing in the generic ``MBLAmbientLight`` class, so you need to use the `MBLAmbientLightLTR329 <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAmbientLightLTR329.html>`_ derived class.

::

    if let ambientLightLTR329 = device.ambientLight as? MBLAmbientLightLTR329 {
    }
