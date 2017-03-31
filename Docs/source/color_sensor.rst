.. highlight:: swift

Color Sensor
============

Similiar to :doc:`ambient light sensors <ambientlightltr329>`, color sensors are responsive to light, however they are typically manufactured to only capture red, green, and blue light though some models are responsive to all visible light.  MetaEnvironment boards come equipped with a builtin photometer (color sensor).  It's configured via properties on the `MBLPhotometer <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLPhotometer.html>`_ class.

To meet specific needs, different MetaWear models may have different photometers, so the ``MBLPhotometer`` class is actually a generic abstraction of all photometers.  You can up-cast to one of our derived photometers objects in order to access advanced features.


Cast to Derived Class
---------------------

There is currently nothing in the generic ``MBLPhotometer`` class, so you need to use the `MBLPhotometerTCS3472 <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLPhotometerTCS3472.html>`_ derived class.
::

    if let photometerTCS3472 = device.photometer as? MBLPhotometerTCS3472 {
    }
