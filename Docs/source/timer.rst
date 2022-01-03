.. highlight:: swift

Timer
=====
A MetaWear timer can be thought of as an event that is fired at fixed intervals.  

These timers are represented by the 
`MblMwTimer <https://mbientlab.com/docs/metawear/cpp/latest/timer__fwd_8h.html#ac32a834c8b7bc7230ce6947425f43926>`_ struct and can be safely typcased to a 
`MblMwEvent <https://mbientlab.com/docs/metawear/cpp/latest/event__fwd_8h.html#a569b89edd88766619bb41a2471743695>`_ struct.  

Timers can be used to schedule periodic tasks or setup a delayed task execution. For example, you can use the timer to record temperature samples are extremely low frequencies such as once per day or once per hour.

ID
--
MblMwTimer objects are identified by a numerical id; you can retrieve the id by calling 
`mbl_mw_timer_get_id <https://mbientlab.com/docs/metawear/cpp/latest/timer_8h.html#a695e95e035825b626b78416b5df5611e>`_.  

The id is used to retrieve existing timers from the API with the 
`mbl_mw_timer_lookup_id <https://mbientlab.com/docs/metawear/cpp/latest/timer_8h.html#a84d84562f66090e61061b67321c22961>`_ function.

As with previous sections, you may want to keep the id handy so that you can retrieve a timer at a later time.

Task Scheduling
---------------
Before you can schedule tasks, you first need to create a timer, by calling either 
`mbl_mw_timer_create <https://mbientlab.com/docs/metawear/cpp/latest/timer_8h.html#a749457dc6c8a181990367d8b1f92284c>`_ or 
`mbl_mw_timer_create_indefinite <https://mbientlab.com/docs/metawear/cpp/latest/timer_8h.html#ae6a58f97ba8e443aec84769a9cc84453>`_.  These functions are asynchronous and 
will pass a pointer to the caller when the timer is created.  

When you have a valid `MblMwTimer <https://mbientlab.com/docs/metawear/cpp/latest/timer__fwd_8h.html#ac32a834c8b7bc7230ce6947425f43926>`_, you can use the command recording system outlined in 
:doc:`event` section to program the board to respond to the periodic events.  

Upon recording timer task commands, call 
`mbl_mw_timer_start <https://mbientlab.com/docs/metawear/cpp/latest/timer_8h.html#a90455d9e29548c1332ef7ad9db46c50e>`_ to start the timer.

When you are done using a timer, you can remove it with 
`mbl_mw_timer_remove <https://mbientlab.com/docs/metawear/cpp/latest/timer_8h.html#a96d102b4f39a46ccbaf8ee5a37a2a55e>`_. 

A good example is the one mentioned above. Because the humidity sensor is a slow sensor, it must be read using a timer to get periodic readings (unlike setting the ODR for the accelerometer):

::

    mbl_mw_humidity_bme280_set_oversampling(device.board, MBL_MW_HUMIDITY_BME280_OVERSAMPLING_16X)
    
    let signal = mbl_mw_humidity_bme280_get_percentage_data_signal(device.board)!
    mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
        let humidity: Float = obj!.pointee.valueAs()
        print(String(format: "%.2f", humidity))
    }

    // Create a timer to read every 700 ms
    device.timerCreate(period: 700).continueOnSuccessWith { timer in
        mbl_mw_timer_remove(timer)
        mbl_mw_datasignal_unsubscribe(signal)
        mbl_mw_event_record_commands(timer)
        mbl_mw_datasignal_read(signal)
        timer.eventEndRecord().continueOnSuccessWith {
            mbl_mw_timer_start(timer)
        }
    }