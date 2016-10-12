.. highlight:: Objective-C

Temperature
===========

The MetaWear board always has an on-die temperature sensor along with support for attaching an external thermistor, and some models even contain on on-board thermistor for super accurate results.  All logic is encapsulated with the `MBLTemperature <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLTemperature.html>`_ object.

Source Selection
----------------

The sources are available as different ``MBLData`` properties.

::

    MBLData *onDieThermistor = device.temperature.onDieThermistor;
    MBLExternalThermistor *externalThermistor = device.temperature.externalThermistor;
    MBLData *onboardThermistor = device.temperature.onboardThermistor;

Single Read
-----------

Here is how you get a single temperature reading.  Note that to use an external thermistor you must specify what GPIO pins it is connected to as well.

::

    [[device.temperature.onDieThermistor readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"on-die temp: %f", result.value.floatValue);
    }];
    
    [[device.temperature.onboardThermistor readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"on-board temp: %f", result.value.floatValue);
    }];
    
    MBLExternalThermistor *externalThermistor = device.temperature.externalThermistor;
    externalThermistor.readPin = 0;
    externalThermistor.enablePin = 1;
    [[externalThermistor readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"external thermistor temp: %f", result.value.floatValue);
    }];

Periodic Read
-------------

Since all temperature sources are MBLData objects, you can easily perform periodic reads.

::

    MBLEvent *temperatureEvent = [device.temperature.onDieThermistor periodicReadWithPeriod:500];
    [temperatureEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"on-die temp: %f", obj.value.floatValue);
    }];

Change Event
------------

The following code shows how to setup filters to notify when the temperature has changed by at least 2 degrees C.

::

    MBLEvent *temperatureEvent = [device.temperature.onDieThermistor periodicReadWithPeriod:500];
    // Get notifications when it changes by 2 degrees C
    MBLEvent *deltaTemperatureEvent = [temperatureEvent changeOfEventByDelta:2.0 output:MBLDeltaValueOutputAbsolute];
    [deltaTemperatureEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Temp Changed!: %@", obj);
    }];

Threshold Event
---------------

Similarly, we can use the filters to setup a notification when the temperature of the device crosses a threshold.

::

    MBLEvent *temperatureEvent = [device.temperature.onDieThermistor periodicReadWithPeriod:500];
    // Get notifications when it crosses 25 degrees C
    MBLEvent *thresholdEvent = [temperatureEvent changeOfEventAcrossThreshold:25.0 hysteresis:2.0 output:MBLThresholdValueOutputAbsolute];
    [thresholdEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Temp Crossed Threshold!: %@", obj);
    }];

