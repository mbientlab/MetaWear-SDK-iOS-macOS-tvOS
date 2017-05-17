.. highlight:: swift

Temperature
===========

The MetaWear board always has an on-die temperature sensor along with support for attaching an external thermistor, and some models even contain on on-board thermistor for super accurate results.  All logic is encapsulated with the `MBLTemperature <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLTemperature.html>`_ object.

Source Selection
----------------

The sources are available as different ``MBLData`` properties.

::

    let onDieThermistor = device.temperature?.onDieThermistor
    let externalThermistor = device.temperature?.externalThermistor
    let onboardThermistor = device.temperature?.onboardThermistor

Single Read
-----------

Here is how you get a single temperature reading.  Note that to use an external thermistor you must specify what GPIO pins it is connected to as well.

::

    device.temperature?.onDieThermistor.readAsync().success { result in
        print("on-die temp: \(result.value.doubleValue)")
    }
    device.temperature?.onboardThermistor?.readAsync().success { result in
        print("on-board temp: \(result.value.doubleValue)")
    }

    let externalThermistor = device.temperature?.externalThermistor
    externalThermistor?.readPin = 0
    externalThermistor?.enablePin = 1
    externalThermistor?.readAsync().success { result in
        print("external thermistor temp: \(result.value.doubleValue)")
    }

Periodic Read
-------------

Since all temperature sources are MBLData objects, you can easily perform periodic reads.

::

    let temperatureEvent = device.temperature?.onDieThermistor.periodicRead(withPeriod: 500)
    temperatureEvent?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("on-die temp: \(obj.value.doubleValue)")
        }
    })

Change Event
------------

The following code shows how to setup filters to notify when the temperature has changed by at least 2 degrees C.

::

    let temperatureEvent = device.temperature?.onDieThermistor.periodicRead(withPeriod: 500)
    // Get notifications when it changes by 2 degrees C
    let deltaTemperatureEvent = temperatureEvent?.changeOfEvent(byDelta: 2.0, output: .absolute)
    deltaTemperatureEvent?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Temp Changed!: \(obj.value.doubleValue)")
        }
    })


Threshold Event
---------------

Similarly, we can use the filters to setup a notification when the temperature of the device crosses a threshold.

::

    let temperatureEvent = device.temperature?.onDieThermistor.periodicRead(withPeriod: 500)
    // Get notifications when it changes by 2 degrees C
    let thresholdEvent = temperatureEvent?.change(ofEventAcrossThreshold: 25.0, hysteresis: 2.0, output: .absolute)
    thresholdEvent?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Temp Crossed Threshold!: \(obj.value.doubleValue)")
        }
    })
