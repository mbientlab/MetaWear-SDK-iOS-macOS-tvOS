.. highlight:: swift

Events
======
An event is an asynchronous notification from the MetaWear board represented in the C++ API by the 
`MblMwEvent <https://mbientlab.com/docs/metawear/cpp/latest/event__fwd_8h.html#a569b89edd88766619bb41a2471743695>`_ struct.  

Recording Commands
------------------
The board can be programmed to execute MetaWear commands in response to an event firing.  

An event can be many things such as a data filter (average the accelerometer signal), a disconnect (the board has disconnected from the Bluetooth link), or even a timer (10 seconds have passed).

To start recording commands, call 
`mbl_mw_event_record_commands <https://mbientlab.com/docs/metawear/cpp/latest/event_8h.html#a771158b2eedeea765163a7df5f6c51e7>`_.  While in a recording 
state, all MetaWear functions called will instead be recorded on the board and executed when the event is fired.  

To stop recording, call 
`eventEndRecord() <https://mbientlab.com/documents/metawear/ios/latest/Extensions/OpaquePointer.html#/s:s13OpaquePointerV8MetaWearE14eventEndRecord10BoltsSwift4TaskCyytGyF>`_. It returns a Task from Bolts.

In this example, when the board is put to sleep, the led blinks blue:

::

    // LED Feedback to indicate success
    metawear.flashLED(color: .blue, intensity: 1.0, _repeat: 10)
    
    // Powerdown the board
    mbl_mw_debug_enable_power_save(metawear.board)
                
    // Reset it after a few seconds to let the flashing finish
    metawear.timerCreate(period: MSEC_TO_FLASH, repetitions: 1, immediateFire: false).continueOnSuccessWith { timer in
        mbl_mw_event_record_commands(timer)
        mbl_mw_debug_reset(metawear.board)
        timer.eventEndRecord().continueOnSuccessWith { _ in
            mbl_mw_timer_start(timer)
        }
    }
    