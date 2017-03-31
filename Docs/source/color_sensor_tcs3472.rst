.. highlight:: swift

Color Sensor TCS3472
====================

This specific color sensor is configured via properties on the `MBLPhotometerTCS3472 <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLPhotometerTCS3472.html>`_ class.  This section shows how to use its advanced features.


Configuration
-------------
The color sensor has 2 configurable parameters that affect the data range, resultion, and sensitivity.

================  ============================================
Parameter         Description
================  ============================================
Gain              Analog signal scale
Integration Time  Amount of time spent to aggregate adc values
================  ============================================

There is also a white illuminator LED next to the sensor that can be used to provide additional light if the surrounding area is too dark.

::

    // set gain to 4x, integration time to 4.8ms,
    // keep illuminator led off
    photometerTCS3472.gain = .gain4X
    photometerTCS3472.integrationTime = 4.8

ADC Values
----------
The red, green, blue, and clear ADC values measured by the TCS3472 device are represented by the `MBLRGBData <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLRGBData.html>`_ class.

::

    photometerTCS3472.color?.readAsync().success { result in
        print("color adc = \(result)")
    }
