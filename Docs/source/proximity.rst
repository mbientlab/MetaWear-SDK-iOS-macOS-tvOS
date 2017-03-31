.. highlight:: swift

Proximity
=========

Proximity sensors detect the presence of objects without physically touching them.  They are often used as a touch-less switch, automatically turning on faucets and opening doors to name a few examples.

MetaDetector boards are outfitted with the `TSL2671 <http://ams.com/eng/content/download/250323/976177/142397>`_ proximity detector, a photoelectric style detector that refelcts an infrared signal off the target object to measure distance.  This sensor is accessed with the `MBLProximityTSL2671 <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLProximityTSL2671.html>`_ interface.

To meet specific needs, different MetaWear models have different magnetometer sensors, so the ``MBLProximity`` class is actually a generic abstraction of all magnetometers.  You can up-cast to one of our derived magnetometer objects in order to access advanced features.


Cast to Derived Class
---------------------

There is currently nothing in the generic ``MBLProximity`` class, so you need to use the `MBLProximityTSL2671 <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLProximityTSL2671.html>`_ derived class.
::

    if let proximityTSL2671 = device.proximity as? MBLProximityTSL2671 {
    }
