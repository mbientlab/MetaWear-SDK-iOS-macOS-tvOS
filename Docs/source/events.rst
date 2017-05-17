.. highlight:: swift

Events
======

Asynchronous data from MetaWear modules are exposed via `MBLEvent <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLEvent.html>`_ objects.  Being asynchronous, event objects will tell you when their data is ready, so you subscribe and then sit back and wait for notifications to come in.  These event objects could be generated from stimuli in the physical world or simply a periodic read:

* A trigger based on when/if the device is dropped
* Reading a heart rate sensor through GPIO and triggering when the pin value changes
* Periodic reading of data (i.e. accelerometer sample every 5ms)

In this section we will explain the generic features available to all events by going over a couple of useful examples.  Note that detailed documentation for each module's events can be found in the individual module sections below.

Notifications
-------------

One of the most basic use cases is to simply receive the data on your Apple device. This is done via blocks within your app. When an event occurs you get a callback with an event specific object containing all relevant data. In this example, we setup a trigger that notifies us when there is a change detected in the value of GPIO pin 0 and logs a message upon receipt of that notification.

Events will continue to stream in until the device is disconnected, or you call ``stopNotificationsAsync``

You can check if an event is currently streaming by checking the ``isNotifying`` property.

::

    if let pin0 = device.gpio?.pins.first {
        pin0.changeEvent?.startNotificationsAsync(handler: { (obj, error) in
            print("Cool, the pin changed: " + String(describing: obj))
        })
    }

::

    pin0.changeEvent?.stopNotificationsAsync()
    pin0.changeEvent?.isNotifying()

Command
-------

In order to free the MetaWear from needing constant phone connection, we can program the device to perform certain actions when an event occurs. It's a basic "If <event> then <action>" paradigm. The magic being, all logic is stored on the MetaWear, so it works even with the Apple device disconnected.

The device will continue to perform <action> on <event> until you either reset the device or call ``programCommandsToRunOnEventAsync``

You can check if an event is currently programmed by checking the ``hasCommands`` property.

**WARNING**
There are some important details to consider when using this feature.  At the lowest level all MetaWear API calls end up being a stream of bytes passed over the BLE connection.  The command system works by executing the block provided to  ``programCommandsToRunOnEventAsync`` right away, but instead of directly sending bytes they are encoded for execution later on.  This means you can't use API's with callbacks inside the block since they are not really executed.

::

    // Flash the LED when you press the button
    device.mechanicalSwitch?.switchUpdateEvent.programCommandsToRunOnEventAsync {
        device.led?.flashColorAsync(.red, withIntensity: 1.0, numberOfFlashes: 3)
    }

::

    device.mechanicalSwitch?.switchUpdateEvent.eraseCommandsToRunOnEventAsync()
    device.mechanicalSwitch?.switchUpdateEvent.hasCommands()

Logging
-------

Another common use case is "offline" (aka Apple device not connected) logging of event data. It allows you put this data directly into the MetaWear flash memory. Since this memory is non-volatile your data is safe even if the MetaWear crashes or the battery dies. There is room for around 14,000 entries, just call ``startLoggingAsync`` on the event of interest.

Once you start logging you can disconnect and even kill the app. Later on, re-connect and get the log by calling the download method.

::

    device.mechanicalSwitch?.switchUpdateEvent.startLoggingAsync()

::

    device.mechanicalSwitch?.switchUpdateEvent.downloadLogAndStopLoggingAsync(true, progressHandler: { number in
        // Update progress bar, as this can take anywhere from one minute
        // to a couple hours to download a full log
    }).success({ result in
        // array contains all the log entries
        for entry in result {
            print("Entry: " + String(describing: entry))
        }
    })

Filters
-------

Many of the events generated are raw sensor output, to help make sense of this data, MetaWear has several digital signal processing (DSP) functions builtin.  To use filters you call one of the "create filter" functions on an event object and it will return a new event object!  When you turn on notifications or logging of this new event, you will see the filtered data.

Since the filters work at the firmware level, they too function when the device is disconnected.  See the section on :doc:`data_processor` for details.

