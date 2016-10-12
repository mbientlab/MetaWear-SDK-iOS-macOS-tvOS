.. highlight:: Objective-C

LED
===

The MetaWear board comes with a builtin RGB LED, encapsulated with the `MBLLED <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLLED.html>`_ object.

Set Color
---------

This snippet will set the LED to a solid red color.

::

    [device.led setLEDColorAsync:[UIColor redColor] withIntensity:1.0];

Flash Color
-----------

This snippet will flash the LED a solid red color indefinitely. ::

    [device.led flashLEDColorAsync:[UIColor redColor] withIntensity:1.0];

Or you might find it beneficial to flash only a few times.

::

    [device.led flashLEDColorAsync:[UIColor greenColor] withIntensity:1.0 numberOfFlashes:3];

Turning Off
-----------

This snippet will completely shut down the LED.

::

    [device.led setLEDOnAsync:NO withOptions:1];

