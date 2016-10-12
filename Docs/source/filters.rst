.. highlight:: Objective-C

Filters
=======

Filtered data is represented by the `MBLFilter <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLFilter.html>`_ class.  You create filter objects by calling one of the filters methods on the `MBLEvent <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLEvent.html>`_ object (which serves as the input).

Since `MBLFilter <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLFilter.html>`_ derives from `MBLEvent <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLEvent.html>`_, all of the features available to events are available to filters, and filters can be chained together to perform complex processing.

Summation (accumulator)
-----------------------

One simple filter is the accumulator, which simply adds together all the input values.

::

    MBLFilter<MBLNumericData *> *switchPressCount = [device.mechanicalSwitch.switchUpdateEvent summationOfEvent];
    [switchPressCount startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {                     
        NSLog(@"Switch Change Count: %@", obj);
    }];

Average
-------

A very useful DSP technique for filtering out noise is averaging.  This is how use the averaging filter:

The depth parameter determines how many pervious samples get averaged together.  This means the first output won't occur until N input events occur.

NOTE: This uses a recursive average technique so the answers are approximate.
NOTE: This works fastest when depth is a power of 2

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    MBLEvent<MBLNumericData *> *periodicPinValue = [pin0.analogAbsolute periodicReadWithPeriod:100];
    MBLEvent<MBLNumericData *> *averagePinValue = [periodicPinValue averageOfEventWithDepth:8];
    [averagePinValue startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Analog Value: %@", obj);
    }];

Comparison
----------

You may want to conditionally ignore some values coming from sensors.  Here is an example:

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    MBLEvent<MBLNumericData *> *periodicPinValue = [pin0.analogAbsolute periodicReadWithPeriod:100];
    MBLEvent<MBLNumericData *> *filteredPinValue = [periodicPinValue compareEventUsingOperation:MBLComparisonOperationGreaterThan data:@[@1.0] output:MBLComparisonOutputValue];
    [filteredPinValue startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Pin Value Over 1.0V: %@", obj);
    }];

Or you may want to quickly see what range a sensor value is in.  Here is an example:

::

    MBLGPIOPin *pin0 = device.gpio.pins[0];
    MBLEvent<MBLNumericData *> *periodicPinValue = [pin0.analogAbsolute periodicReadWithPeriod:100];
    MBLEvent<MBLNumericData *> *filteredPinValue = [periodicPinValue compareEventUsingOperation:MBLComparisonOperationLessThan data:@[@0.5, @1.0, @2.0] output:MBLComparisonOutputZone];
    [filteredPinValue startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        // Zone Map
        // 0 == [0, 0.5)
        // 1 == [0.5, 1.0)
        // 2 == [1.0, 2.0)
        // 3 == [2.0, inf)
        NSLog(@"Pin in zone: %@", obj);
    }];

Periodic Sampling
-----------------

If you want control over the frequency an event occurs you can use a periodic sampling filter.  It simply stores the most recent value from the input and passes it through at a predefined interval.  This is useful for taking high frequency events, and logging them at a lower frequency.

Here we accumulate RMS data from the accelerometer and log it every 20 seconds:

::

    // The rmsDataReadyEvent event will occur at the accelerometer sample frequency (i.e. every 10ms)
    MBLFilter<MBLRMSAccelerometerData *> *runningRMS = [device.accelerometer.rmsDataReadyEvent summationOfEvent];
    // Since we don't need absolute precision, we can just log the value every 20 seconds
    // and recreate an approximate graph later 
    MBLFilter<MBLRMSAccelerometerData *> *periodicRMS = [runningRMS periodicSampleOfEvent:20000];
    [periodicRMS startLoggingAsync];

Differential Sampling
---------------------

Similar to Periodic Sampling, but instead of passing through the last value of the input directly, it reports the difference between the last value reported and the current value.

::

    // The rmsDataReadyEvent event will occur at the accelerometer sample frequency (i.e. every 10ms)
    MBLFilter<MBLRMSAccelerometerData *> *runningRMS = [device.accelerometer.rmsDataReadyEvent summationOfEvent];
    // Since we don't need absolute precision, we can just log the differnce every 20 seconds
    // and recreate an approximate graph later
    MBLFilter<MBLRMSAccelerometerData *> *differentialRMS = [runningRMS differentialSampleOfEvent:20000];
    [differential startLoggingAsync];

Delay
-----

The delay filter buffers N samples of input, and after N input events are generated, the filter passes through the first input.

::

    MBLFilter<MBLNumericData *> *delayedSwitch = [device.mechanicalSwitch.switchUpdateEvent delayOfEventWithCount:3];
    [delayedSwitch startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];

Pulse
-----

The pulse filter detect pulses in the input signal.  It works on a simple principal that a pulse occurs when a signal goes over a given threshold for N samples.

::

    MBLEvent *temperatureEvent = [device.temperature.onDieThermistor periodicReadWithPeriod:500];
    MBLEvent *pulseEvent = [temperatureEvent pulseDetectorOfEventWithThreshold:25.0 width:10 output:MBLPulseOutputArea];
    [pulseEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Temp Pulsed!: %@", obj);
    }];

Conditional Data Switch
-----------------------

This filter can pass data through or not, also you may programmatically activate or deactivate the switch.

::

    MBLDataSwitch<MBLNumericData *> *presses = [device.mechanicalSwitch.switchUpdateEvent conditionalDataSwitch:YES];
    [presses startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    // Turn off the filter after 3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [presses resetConditionalAsync:NO];
    });

Counting Data Switch
--------------------

This filter can pass N samples through, and all subsequent events are blocked.

::

    MBLDataSwitch<MBLNumericData *> *twoPresses = [device.mechanicalSwitch.switchUpdateEvent countingDataSwitch:2];
    [twoPresses startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];

Delta
-----

This filter monitors a signal and notifies when the signal value changes by a given delta.

::

    MBLEvent *temperatureEvent = [device.temperature.onDieThermistor periodicReadWithPeriod:500];
    // Get notifications when it changes by 2 degrees C
    MBLEvent *deltaTemperatureEvent = [temperatureEvent changeOfEventByDelta:2.0 output:MBLDeltaValueOutputAbsolute];
    [deltaTemperatureEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Temp Changed!: %@", obj);
    }];

Threshold
---------

This filter monitors a signal and notifies when it crosses a given threshold.  It also takes a hysteresis value to prevent multiple events if the signal oscillates right on the threshold.

::

    MBLEvent<MBLNumericData *> *temperatureEvent = [device.temperature.onDieThermistor periodicReadWithPeriod:500];
    // Get notifications when it crosses 25 degrees C
    MBLEvent<MBLNumericData *> *thresholdEvent = [temperatureEvent changeOfEventAcrossThreshold:25.0 hysteresis:2.0 output:MBLThresholdValueOutputAbsolute];
    [thresholdEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Temp Crossed Threshold!: %@", obj);
    }];

