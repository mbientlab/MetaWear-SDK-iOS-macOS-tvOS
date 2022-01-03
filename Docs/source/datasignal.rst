.. highlight:: swift

Data Signal
===========
Data signals are an abstract representation of data producers.  The API treats them as an event that contains data and represents 
them with the `MblMwDataSignal <https://mbientlab.com/docs/metawear/cpp/latest/datasignal__fwd_8h.html#a1ce49f0af124dfa7984a59074c11e789>`_ struct.
  
They can be safely typecasted to an `MblMwEvent <https://mbientlab.com/docs/metawear/cpp/latest/event__fwd_8h.html#a569b89edd88766619bb41a2471743695>`_ as seen in the example in the previous section.

Data signals can come from the accelerometer:

::

    // Get accelerometer data
    acc = mbl_mw_acc_get_acceleration_data_signal(board);


Reading the battery level:

::

    // Get battery level
    batt = mbl_mw_settings_get_battery_state_data_signal(board);

Getting the switch state (is the button pushed or not):

::

    // Get switch state
    switch = mbl_mw_switch_get_state_data_signal(board);

There are many signals which are highlighted in the sections of our documentation:

::

    // Get analog gpio value
    analog_gpio = mbl_mw_gpio_get_analog_input_data_signal(board, pin, MBL_MW_GPIO_ANALOG_READ_MODE_ADC);


Data Handling
-------------
Signal data is encapsulated by the `MblMwData <https://mbientlab.com/docs/metawear/cpp/latest/structMblMwData.html>`_ struct.  

The struct contains a: 

* Timestamp of when the data was created
* Pointer to the data
* Data type id indicating how to cast the pointer

An enumeration of data types is defined by the 
`MblMwDataTypeId <https://mbientlab.com/docs/metawear/cpp/latest/data_8h.html#a8335412069204db23669001bcaed532e>`_ enum and structs wrapping non basic 
data types are defined in the `types.h <https://mbientlab.com/docs/metawear/cpp/latest/types_8h.html>`_ header file.

Let's take a look at the most common ``MblMwCartesianFloat`` data type. Angular velocity from the Gyroscope is represented by the ``MblMwCartesianFloat`` struct and is in units of degrees per second. The ``x``, ``y``, and ``z`` fields contain the angular velocity of the spin around that axis.

::

        func gyroBMI160StartStream(_ sender: Any) {
            let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(device.board)!
            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let gyroscope: MblMwCartesianFloat = obj!.pointee.valueAs()
                print(obj!.pointee.epoch, gyroscope, gyroscope.x, gyroscope.y, gyroscope.z)
            }
            mbl_mw_gyro_bmi160_enable_rotation_sampling(device.board)
            mbl_mw_gyro_bmi160_start(device.board)

            streamingCleanup[signal] = {
                mbl_mw_gyro_bmi160_stop(self.device.board)
                mbl_mw_gyro_bmi160_disable_rotation_sampling(self.device.board)
                mbl_mw_datasignal_unsubscribe(signal)
            }
        }

You can take a look at our `swift binding file <https://github.com/mbientlab/MetaWear-SDK-Cpp/blob/master/bindings/swift/cbindings.swift>`_ for all the available data types.

Streaming
---------
Streaming data is sending live data from the sensors on the MetaWear board, through the Bluetooth link, to the device of your choice in real-time.

Aside from the latency of the Bluetooth link, data is received instantaneously.

Note that there are limits to the Bluetooth link as well as the sensors. Please see the `Bluetooth SIG <https://www.bluetooth.com/specifications/bluetooth-core-specification/>`_ and the MetaWear `datasheet <https://mbientlab.com/documentation>`_  to learn more.

To stream data live to your device, call 
`mbl_mw_datasignal_subscribe <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#ab2708a821b8cca7c0d67cf61acec42c3>`_  with the 
desired data signal and a callback function for handling the received data.  Terminating the live stream is done by calling 
`mbl_mw_datasignal_unsubscribe <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#ab2708a821b8cca7c0d67cf61acec42c3>`_. ::

    func accelStream() -> Task<Void> {
        guard let device = device, let board = device.board else {
            return Task<Void>(())
        }
        return Task<Void>(()).continueWithTask(device.apiAccessExecutor) { _ in
           guard mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_ACCELEROMETER) != -1,
            let accel = mbl_mw_acc_get_acceleration_data_signal(board) else {
                return Task<Void>(())
            }
            mbl_mw_acc_set_odr(board, 10.0)
            mbl_mw_acc_set_range(board, 4.0)
            mbl_mw_acc_write_acceleration_config(board)
            mbl_mw_datasignal_subscribe(accel, bridge(obj: self)) { (context, data) in
                let _self: Tutorial = bridge(ptr: context!)
                let point: MblMwCartesianFloat = data!.pointee.valueAs()
                print(CGFloat(point.magnitude))
            }
            mbl_mw_acc_enable_acceleration_sampling(board)
            mbl_mw_acc_start(board)
            return Task<Void>.withDelay(8.0).continueWith(device.apiAccessExecutor) { _ in
                mbl_mw_acc_stop(board)
                mbl_mw_acc_disable_acceleration_sampling(board)
                mbl_mw_datasignal_unsubscribe(accel)
                mbl_mw_debug_disconnect(board)
            }
        }
    }

Logging
-------
Alternatively, data can be logged and retrieved at a later time.  

When the data is logged, it is stored in the board memory. The memory is finite and once it is full, old data may be overwritten by new data. Please consult the `Tutorials <https://mbientlab.com/tutorials/>`_ and the `datasheet <https://mbientlab.com/documentation>`_ of your board for more information.

The data must be retrieved at some point in time from the MetaWear board to the device of your choice using the logger APIs.

See the :doc:`logger` section for more details.

Readable Signals
----------------
Some sensors will only send data when they receive a command to do so. These are typically either slower sensors or analog sensors where data doesn't need to be read at 100Hz (such as the temperature sensor). 

Data signals that represent this type of data source are called readable signals.  
You can check if a data signal is readable by calling 
`mbl_mw_datasignal_is_readable <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a9633497a3785ba2369f57b939bd156c2>`_.  

The read command is issued by calling 
`mbl_mw_datasignal_read <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a0a456ad1b6d7e7abb157bdf2fc98f179>`_ or 
`mbl_mw_datasignal_read_with_parameters <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a71391d5862eb18327ce2aaaac4a12159>`_.  Most 
readable data signals will use the former function which does not require any additional parameters.  The latter function is for reads that require 
additional parameters which are bundled into one struct.

Reading the humidity from the barometer is a good example of a single read:

::

    let signal = mbl_mw_humidity_bme280_get_percentage_data_signal(device.board)!
    mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
        let humidity: Float = obj!.pointee.valueAs()
        print(String(format: "%.2f", humidity))
    }
    mbl_mw_datasignal_read(signal)

When using readable signals, you must decide up front if the data will be streamed or logged before interacting with it.  That is, you should either 
have subscribed to or setup a logger for a readable signal before reading it.

Data Processing
---------------
Data signals can be fed through the on-board data processors to filter and/or transform the data in the firmware.  By performing computations on the 
MetaWear side, you can reduce the amount of data that is sent over the radio and the amount of postprocessing that is done on your mobile device.  

For example, a threshold processor can be used to determine if the ambient temperature has exceeded 40 degrees. A highpass filter can be used to determine if the board has moved or the comparison processor can be used to determine if and when the light in the room has been turned on.

Data processors can also be chained together to perform more complex tasks, such as using the rss, average, and threshold processors to determine if the 
board is in freefall based on the XYZ acceleration data. 

See the :doc:`dataprocessor` section for more details on the data processing system. 

Here is an example where the x,y,z components of the accelerometer are combined using the rss processor to calculate the vector magnitude:

::

    acc_signal = mbl_mw_acc_get_acceleration_data_signal(board)
    let code = mbl_mw_dataprocessor_rss_create(acc_signal, bridgeRetained(obj: source)) { (context, rms) in
        if let rms = rms {
            print(rms)
        }
    }

Component Signals
-----------------
Some signals, such as the acceleration data signal, are composed of multiple values.  While you can interact with them as a whole, sometimes it is more 
convenient to only use individual values.  

To access the component values, call 
`mbl_mw_datasignal_get_component <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#abf5eaa69c5f5978cb7bdd9ea04a910e0>`_ with the signal 
and an index represnting which component to retrieve.  If a signal is single valued, the function will return null. 

In this example, only the z-axis is from the accelerometer is retrieved:

::

    acc_root = mbl_mw_acc_get_acceleration_data_signal(board);
    acc_z = mbl_mw_datasignal_get_component(acc_root, MBL_MW_ACC_ACCEL_Z_AXIS_INDEX);
    mbl_mw_datasignal_subscribe(acc_z, bridge(obj: self)) { (context, obj) in  
        let value: UInt32 = obj!.pointee.valueAs()
        print(value)
    }
