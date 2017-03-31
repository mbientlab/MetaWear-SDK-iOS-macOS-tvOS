.. highlight:: swift

Haptic
======

The MetaWear can be outfitted with either a haptic motor or a buzzer, encapsulated with the `MBLHapticBuzzer <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLHapticBuzzer.html>`_ object

Start Haptic
------------

The haptic motor has 2 parameters.  First, duty cycle [0, 255], which corresponds to strength of vibration.  Second, pulse width, or how long to buzz (units in ms).

::

    device.hapticBuzzer?.startHapticAsync(dutyCycle: 255, pulseWidth: 500, completion: nil)

Start Buzzer
------------

The buzzer has just a pulse width parameter, or how long to buzz (units in ms).

::

    device.hapticBuzzer?.startBuzzerAsync(pulseWidth: 500, completion: nil)
