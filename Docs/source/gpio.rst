.. highlight:: swift

GPIO
====

Using the general purpose input/output (GPIO) pins on the MeatWear, you can extend it in near endless ways.  You can programmatically set or clear a pin's state, or reads its digital or analog value.

The `MBLGPIO <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIO.html>`_ module exposes a "pins" property which contains an array of `MBLGPIOPin <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIOPin.html>`_ objects.  The index into the array represents the logical pin number as found in the `MetaWear Product Spec <https://www.mbientlab.com/docs/MetaWearPPSv0.7.pdf>`_.

Read Digital
------------

To check the digital (0 or 1) value of a pin, just get a pointer to the corresponding `MBLGPIOPin <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIOPin.html>`_ object and read its ``digitalValue`` property.

::

    if let pin0 = device.gpio?.pins.first {
        pin0.digitalValue?.readAsync().success { result in
            print("Pin State: \(result)")
        }
    }

Read Analog
-----------

To check the absolute analog value (in volts) of a pin (expect around 0 to 3.0 volts), just get a pointer to the corresponding `MBLGPIOPin <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIOPin.html>`_ object and read its ``analogAbsolute`` property:

To check the analog value relative to the supply voltage of a pin [0, 1.0], just get a pointer to the corresponding `MBLGPIOPin <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLGPIOPin.html>`_ object and read its ``analogRatio`` property:

::

    if let pin0 = device.gpio?.pins.first {
        pin0.analogAbsolute?.readAsync().success { result in
            print("Pin Voltage: \(result.value.doubleValue)")
        }
    }

::

    if let pin0 = device.gpio?.pins.first {
        pin0.analogRatio?.readAsync().success { result in
            print("Pin Ratio: \(result.value.doubleValue)")
        }
    }

Set/Clear Pin
-------------

To set the digital value of a pin:

::

    if let pin0 = device.gpio?.pins.first {
        pin0.setToDigitalValueAsync(true)
    }

Notify on Pin Change
--------------------

Events can be generated when the digital state of a pin changes:

::

    if let pin0 = device.gpio?.pins.first {
        pin0.changeType = .rising
        pin0.setConfiguration(.nopull)
        pin0.changeEvent?.startNotificationsAsync(handler: { (obj, error) in
            print("Cool, the pin changed: " + String(describing: obj))
        })
    }

Enable Pin
----------

To save power, sensors connected to a GPIO pin may optionally have an "enable" switch connected to another pin.  Pulling up or down this enable pin can programmatically turn off the sensor to save power.  By setting this value we will automatically enable the sensor just long enought to get a sample.

::

    if let pin0 = device.gpio?.pins.first {
        let analogRatio = pin0.analogRatio(withPullUp: nil, pullDown: 2, readDelay: 200)
        analogRatio.readAsync().success { result in
            print("With Enable: \(result.value)")
        }
    }
