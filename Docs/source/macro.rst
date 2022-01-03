.. highlight:: cpp

Macro
=====
The on-board flash memory can also be used to store MetaWear commands instead of sensor data. 

A good example of this feature is to change the name of a device permanently so that is does not advertise as MetaWear. 

Recorded commands can be executed any time after being 
programmed with the functions in `macro.h <https://mbientlab.com/docs/metawear/cpp/0/macro_8h.html>`_ header file.  

Recording Commands
------------------
To record commands:

1. Call `mbl_mw_macro_record <https://mbientlab.com/docs/metawear/cpp/0/macro_8h.html#aa99e58c7cbc1bbecb10985bd08643bba>`_ to put the API in macro mode  
2. Use the MetaWear commands that you want programmed  
3. Exit macro mode with `macroEndRecord <https://mbientlab.com/documents/metawear/ios/latest/Classes/MetaWear.html#/s:8MetaWearAAC14macroEndRecord10BoltsSwift4TaskCys5Int32VGyF>`_  

::

        mbl_mw_macro_record(device.board, 1)
        // COMMANDS TO RECORD GO HERE
        device.macroEndRecord()

Macros can be set to run on boot by setting the ``exec_on_boot`` parameter with a non-zero value.

::

    mbl_mw_macro_record(board, 1) // ON BOOT
    mbl_mw_macro_record(board, 0) // NOT ON BOOT

In this example, the LED will blink blue on boot:

::

    // Record everything to startup macro
    mbl_mw_macro_record(device.board, 1)
            
    // Setup LED
    mbl_mw_led_stop_and_clear(device.board)
    // Success flash
    var greenPattern = MblMwLedPattern(high_intensity: 31,
                                        low_intensity: 0,
                                        rise_time_ms: 100,
                                        high_time_ms: 200,
                                        fall_time_ms: 100,
                                        pulse_duration_ms: 800,
                                        delay_time_ms: 0,
                                        repeat_count: 3)
    mbl_mw_led_write_pattern(device.board, &greenPattern, MBL_MW_LED_COLOR_GREEN)
    mbl_mw_led_play(device.board)
                
    // Finish off this macro
    device.macroEndRecord()

Erasing Macros
--------------
Erasing macros is done with the `mbl_mw_macro_erase_all <https://mbientlab.com/docs/metawear/cpp/0/macro_8h.html#aa1c03d8f08b5058d8f81b532a6930d67>`_ 
method.  The erase operation will not occur until you disconnect from the board.

::

    mbl_mw_macro_erase_all(board);

