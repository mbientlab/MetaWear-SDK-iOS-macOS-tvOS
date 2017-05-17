.. highlight:: swift

Proximity TSL2671
=================

This specific proximity sensor is configured via properties on the `MBLProximityTSL2671 <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLProximityTSL2671.html>`_ class.  This section shows how to use its advanced features.


Configuration
-------------
The TSL2671 device has 4 configurable parameters that control the sensitivity and distance at which the detector can measure proximity.  These parameters are set with properties on the interface.

===================  ===================================================================
Parameter            Description
===================  ===================================================================
Integration Time     How long the internal ADC converts analog input into digital counts
Pulse Count          Number of IR pulses emitted for distance measuring
Transmitter Current  Amount of current driving the IR transmitter
===================  ===================================================================

::

    // set integration time to 5.44ms
    // use default pulse count of 1,
    // set drive current to 25mA
    proximityTSL2671.integrationTime = 5.44
    proximityTSL2671.proximityPulses = 1
    proximityTSL2671.drive = .drive25mA

Proximity Data
--------------
Proximity data is an ADC value represented as an UInt16; the higher the adc value, the closer the distance to the object.

::

    proximityTSL2671.proximity?.readAsync().success { result in
        print("Proximity ADC = \(result.value.uint16Value)")
    }
