.. highlight:: Objective-C

GPIO
====

Using the general purpose input/output (GPIO) pins on the MeatWear, you can extend it in near endless ways.  You can programmatically set or clear a pin's state, or reads its digital or analog value.

The `MBLGPIO <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIO.html>`_ module exposes a "pins" property which contains an array of `MBLGPIOPin <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIOPin.html>`_ objects.  The index into the array represents the logical pin number as found in the `MetaWear Product Spec <https://www.mbientlab.com/docs/MetaWearPPSv0.7.pdf>`_.

Read Digital
------------

To check the digital (0 or 1) value of a pin, just get a pointer to the corresponding `MBLGPIOPin <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIOPin.html>`_ object and read its ``digitalValue`` property.

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    [[pin0.digitalValue readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"Pin State: %d", result.value.boolValue);
    }];

Read Analog
-----------

To check the absolute analog value (in volts) of a pin (expect around 0 to 3.0 volts), just get a pointer to the corresponding `MBLGPIOPin <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIOPin.html>`_ object and read its ``analogAbsolute`` property:

To check the analog value relative to the supply voltage of a pin [0, 1.0], just get a pointer to the corresponding `MBLGPIOPin <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIOPin.html>`_ object and read its ``analogRatio`` property:

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    [[pin0.analogAbsolute readAsync] success:^(MBLNumericData * _Nonnull result) {
         NSLog(@"Pin Voltage: %f V", result.value.floatValue);
    }];

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    [[pin0.analogRatio readAsync] success:^(MBLNumericData * _Nonnull result) {
         NSLog(@"Pin Ratio: %f", result.value.floatValue);
    }];

Set/Clear Pin
-------------

To set the digital value of a pin:

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    [pin0 setToDigitalValueAsync:YES];

Notify on Pin Change
--------------------

Events can be generated when the digital state of a pin changes:

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    pin0.changeType = MBLPinChangeTypeRising;
    pin0.configuration = MBLPinConfigurationNopull;
    [pin0.changeEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
         NSLog(@"Cool, the pin changed: %@", obj.value);
    }];

Enable Pin
----------

To save power, sensors connected to a GPIO pin may optionally have an "enable" switch connected to another pin.  Pulling up or down this enable pin can programmatically turn off the sensor to save power.  By setting this value we will automatically enable the sensor just long enought to get a sample.

::

    MBLGPIOPin *pin0 = self.device.gpio.pins[0];
    MBLData *analogRatio = [pin0 analogRatioWithPullUp:nil pullDown:@2 readDelay:200];
    // When calling readAsync we will automatically pull down pin 2 200 uSec before
    // reading pin 0 and then pull up pin 2 once the reading is complete
    [[analogRatio readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"With Enable: %@", result.value);
    }];

