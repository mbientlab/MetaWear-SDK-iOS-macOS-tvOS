.. highlight:: swift

Data Processor
==============

Filtered data is represented by the `MBLFilter <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLFilter.html>`_ class.  You create filter objects by calling one of the filters methods on the `MBLEvent <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLEvent.html>`_ object (which serves as the input).

Since `MBLFilter <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLFilter.html>`_ derives from `MBLEvent <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLEvent.html>`_, all of the features available to events are available to filters, and filters can be chained together to perform complex processing.

Summation (accumulator)
-----------------------

One simple filter is the accumulator, which simply adds together all the input values.

::

    let switchPressCount = device.mechanicalSwitch?.switchUpdateEvent.summationOfEvent()
    switchPressCount?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Switch Change Count: \(obj)")
        }
    })

Average
-------

A very useful DSP technique for filtering out noise is averaging.  This is how use the averaging filter:

The depth parameter determines how many pervious samples get averaged together.  This means the first output won't occur until N input events occur.

NOTE: This uses a recursive average technique so the answers are approximate.
NOTE: This works fastest when depth is a power of 2

::

    if let pin0 = device.gpio?.pins.first {
        let periodicPinValue = pin0.analogAbsolute?.periodicRead(withPeriod: 100)
        let averagePinValue = periodicPinValue?.averageOfEvent(withDepth: 8)
        averagePinValue?.startNotificationsAsync(handler: { (obj, error) in
            if let obj = obj {
                print("Analog Value: \(obj)")
            }
        })
    }

Comparison
----------

You may want to conditionally ignore some values coming from sensors.  Here is an example:

::

    if let pin0 = device.gpio?.pins.first {
        let periodicPinValue = pin0.analogAbsolute?.periodicRead(withPeriod: 100)
        let filteredPinValue = periodicPinValue?.compare(using: .greaterThan, data: [1.0], output: .value)
        filteredPinValue?.startNotificationsAsync(handler: { (obj, error) in
            if let obj = obj {
                print("Pin Value Over 1.0V: \(obj)")
            }
        })
    }

Or you may want to quickly see what range a sensor value is in.  Here is an example:

::

    if let pin0 = device.gpio?.pins.first {
        let periodicPinValue = pin0.analogAbsolute?.periodicRead(withPeriod: 100)
        let filteredPinValue = periodicPinValue?.compare(using: .lessThan, data: [0.5, 1.0, 2.0], output: .zone)
        filteredPinValue?.startNotificationsAsync(handler: { (obj, error) in
            if let obj = obj {
                // Zone Map
                // 0 == [0, 0.5)
                // 1 == [0.5, 1.0)
                // 2 == [1.0, 2.0)
                // 3 == [2.0, inf)
                print("Pin in zone: \(obj)")
            }
        })
    }

Modify
------

You can apply basic math operations to data as well.  We support add/subtract/multiply/divide, and the others listed in `MBLArithmeticOperation <https://mbientlab.com/docs/metawear/ios/latest/Constants/MBLArithmeticOperation.html>`_. Here are some examples of how you might initialize them:

::

    let temp = device.temperature?.onDieThermistor.periodicRead(withPeriod: 500)
    let doubleTemp = temp?.modifyEvent(using: .multiply, withData: 2)
    let halfTemp = temp?.modifyEvent(using: .divide, withData: 2)
    let fiftyLessTemp = temp?.modifyEvent(using: .subtract, withData: 50.0)
    let absTemp = fiftyLessTemp?.modifyEvent(using: .absoluteValue, withData: 0)

Periodic Sampling
-----------------

If you want control over the frequency an event occurs you can use a periodic sampling filter.  It simply stores the most recent value from the input and passes it through at a predefined interval.  This is useful for taking high frequency events, and logging them at a lower frequency.

Here we accumulate RMS data from the accelerometer and log it every 20 seconds:

::

    // The rmsDataReadyEvent event will occur at the accelerometer sample frequency (i.e. every 10ms)
    let runningRMS = device.accelerometer?.rmsDataReadyEvent.summationOfEvent()
    // Since we don't need absolute precision, we can just log the value every 20 seconds
    // and recreate an approximate graph later
    let periodicRMS = runningRMS?.periodicSample(ofEvent: 20000)
    periodicRMS?.startLoggingAsync()

Differential Sampling
---------------------

Similar to Periodic Sampling, but instead of passing through the last value of the input directly, it reports the difference between the last value reported and the current value.

::

    // The rmsDataReadyEvent event will occur at the accelerometer sample frequency (i.e. every 10ms)
    let runningRMS = device.accelerometer?.rmsDataReadyEvent.summationOfEvent()
    // Since we don't need absolute precision, we can just log the differnce every 20 seconds
    // and recreate an approximate graph later
    let differentialRMS = runningRMS?.differentialSample(ofEvent: 20000)
    differentialRMS?.startLoggingAsync()

Delay
-----

The delay filter buffers N samples of input, and after N input events are generated, the filter passes through the first input.

::

    let delayedSwitch = device.mechanicalSwitch?.switchUpdateEvent.delayOfEvent(withCount: 3)
    delayedSwitch?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print(obj)
        }
    })

Pulse
-----

The pulse filter detect pulses in the input signal.  It works on a simple principal that a pulse occurs when a signal goes over a given threshold for N samples.

::

    let temperatureEvent = device.temperature?.onDieThermistor.periodicRead(withPeriod: 500)
    let pulseEvent = temperatureEvent?.pulseDetectorOfEvent(withThreshold: 25.0, width: 10, output: .area)
    pulseEvent?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Temp Pulsed!: \(obj)")
        }
    })

Conditional Data Switch
-----------------------

This filter can pass data through or not, also you may programmatically activate or deactivate the switch.

::

    let presses = device.mechanicalSwitch?.switchUpdateEvent.conditionalDataSwitch(true)
    presses?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print(obj)
        }
    })
    // Turn off the filter after 3 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        presses?.resetConditionalAsync(false)
    }

Counting Data Switch
--------------------

This filter can pass N samples through, and all subsequent events are blocked.

::

    let twoPresses = device.mechanicalSwitch?.switchUpdateEvent.countingDataSwitch(2)
    twoPresses?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print(obj)
        }
    })

Delta
-----

This filter monitors a signal and notifies when the signal value changes by a given delta.

::

    let temperatureEvent = device.temperature?.onDieThermistor.periodicRead(withPeriod: 500)
    // Get notifications when it changes by 2 degrees C
    let deltaTemperatureEvent = temperatureEvent?.changeOfEvent(byDelta: 3.0, output: .absolute)
    deltaTemperatureEvent?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Temp Changed!: \(obj)")
        }
    })

Threshold
---------

This filter monitors a signal and notifies when it crosses a given threshold.  It also takes a hysteresis value to prevent multiple events if the signal oscillates right on the threshold.

::

    let temperatureEvent = device.temperature?.onDieThermistor.periodicRead(withPeriod: 500)
    // Get notifications when it crosses 25 degrees C
    let thresholdEvent = temperatureEvent?.change(ofEventAcrossThreshold: 25.0, hysteresis: 2.0, output: .absolute)
    thresholdEvent?.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Temp Crossed Threshold!: \(obj)")
        }
    })
