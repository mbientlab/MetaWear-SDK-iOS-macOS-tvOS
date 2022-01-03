.. highlight:: swift

Data Processor Types
====================
Header files defining the data processors type are in the 
`processor <https://mbientlab.com/docs/metawear/cpp/latest/dir_ac375e5396e5f8152317e89ec5f046d1.html>`_ folder.  

.. list-table:: Data Processors
   :header-rows: 1

   * - #
     - Name
     - Description
   * - 1
     - Accounter
     - Adds additional information to the payload to facilitate packet reconstruction.
   * - 2
     - Accumulator
     - Tallies a running sum of the input.
   * - 3
     - Averager
     - Computes a running average of the input.
   * - 4
     - Buffer
     - Captures input data which can be retrieved at a later point in time.
   * - 5
     - Comparator
     - Only allows data through that satisfies a comparison operation.
   * - 6
     - Counter
     - Counts the number of times an event was fired.
   * - 7
     - Delta
     - Only allows data through that is a min distance from a reference value.
   * - 8
     - Fuser
     - Combine data from multiple data sources into 1 data packet.
   * - 9
     - Math
     - Performs arithmetic on sensor data.
   * - 10
     - Packer
     - Combines multiple data values into 1 BLE packet.
   * - 11
     - Passthrough
     - Gate that only allows data though based on a user configured internal state.
   * - 12
     - Pulse
     - Detects and quantifies a pulse over the input values.
   * - 13
     - RMS
     - Computes the root mean square of the input.
   * - 14
     - RSS
     - Computes the root sum square of the input.
   * - 15
     - Sample
     - Holds data until a certain amount has been collected.
   * - 16
     - Threshold
     - Allows data through that crosses a boundary.
   * - 17
     - Timer
     - Periodically allow data through.

The CPP APIs for the data processor are available in the file ``MblMwDataSignal+Async``.

To create a processor, call any functions that has ``Create`` in its name.  ::

    rmsCreate()
    thresholdCreate(mode:boundary:hysteresis:)
    sampleCreate(binSize:)

Most processors are available as iOS APIs that wrap around the CPP calls such as ``mbl_mw_dataprocessor_rms_create`` wrapped as ``rmsCreate()``:

All data processor create functions are Tasked using Bolts Swift and return a Task pointer.  ::

    /// Tasky interface to mbl_mw_dataprocessor_rms_create
    public func rmsCreate() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_rms_create(self, bridgeRetained(obj: source)) { (context, rms) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let rms = rms {
                source.trySet(result: rms)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create rms"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }

Input data signals that are marked with a `MblMwCartesianFloat <https://mbientlab.com/docs/metawear/cpp/latest/structMblMwCartesianFloat.html>`_ id, 
.i.e accelerometer, gyro, and magnetometer data, are limited to only using the :ref:`dataprocessor-math`, :ref:`dataprocessor-rms`, and 
:ref:`dataprocessor-rss` processors.  Once fed through an RMS or RSS processor however, they can utilize the rest of the data processing functions.

Accounter
---------
The accounter processor adds additional information to the BTLE packet to reconstruct the data's timestamp, typically used with streaming raw 
accelerometer, gyro, and magnetometer data.  

This processor is designed specifically for streaming, DO NOT use with the logger.  ::

    let signal = mbl_mw_baro_bosch_get_altitude_data_signal(device.board)!
    signal.accounterCreateCount()

Average
-------
The averager computes a running average over the over the inputs.  It will not produce any output until it has accumulated enough samples to match the specified sample size. 

There is no high level iOS API for the CPP ``mbl_mw_dataprocessor_averager_create`` function; so here is an example. ::
    
    /// Tasky interface to mbl_mw_dataprocessor_averager_create
    public func averagerCreate(avg_count: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_average_create(self, avg_count, bridgeRetained(obj: source)) { (context, averager) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let averager = averager {
                source.trySet(result: averager)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create averager"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }

    let signal = mbl_mw_multi_chnl_temp_get_temperature_data_signal(device.board, UInt8(MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM.rawValue))!
    signal.averagerCreate(8)

Accumulator
-----------
The accumulator computes a running sum over the inputs.  Users can explicitly specify an output size (1 to 4 bytes) or 
let the API infer an appropriate size.  

The output data type id of an accumulator is the same as its input source. ::

    let signal = mbl_mw_cd_tcs34725_get_adc_data_signal(device.board)!
    mbl_mw_dataprocessor_accumulator_create(signal, bridgeRetained(obj: source)) { (context, accumulator) in

    }

Buffer
------
The buffer processor captures input data which can be read at a later time using 
`mbl_mw_datasignal_read <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a0a456ad1b6d7e7abb157bdf2fc98f179>`_; no output is produced 
by this processor.  

The data type id of a buffer's state is the same as its input source. ::

    /// Tasky interface to mbl_mw_dataprocessor_buffer_create
    public func bufferCreate(avg_count: UInt8) -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_buffer_create(self, bridgeRetained(obj: source)) { (context, buffer) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let buffer = buffer {
                source.trySet(result: buffer)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create buffer"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }

    let signal = mbl_mw_switch_get_state_data_signal(device.board)!
    signal.bufferCreate().continueOnSuccessWith { buffer in
        // Do something with buffer
    }

Buffer processors can be used to capture data and retrieve it at a later time by reading its state.

Comparison
----------
The comparator removes data that does not satisfy the comparison operation.  Callers can force a signed or unsigned comparison, or let the API determine which is appropriate.  

The output data type id of comparator is the same as its input source. ::

    let signal = mbl_mw_gpio_get_pin_monitor_data_signal(device.board, pin)!
    signal.comparatorCreate(0,0,[8])

Multi-Value Comparison
^^^^^^^^^^^^^^^^^^^^^^
Starting from firmware v1.2.3, the comparator can accept multiple reference values to compare against and has additional operation modes that can 
modify output values and when outputs are produced.  The multi-value comparison filter is an extension of the comparison filter implemented on 
older firmware.

Operation modes are defined in the 
`MblMwComparatorOperation <https://mbientlab.com/docs/metawear/cpp/latest/comparator_8h.html#a021a5e13dd18fb4b5b2052bf547e5f54>`_ enum, copied below 
with a description on expected outputs:

===========  =====================================================================================================
Operation    Descripion
===========  =====================================================================================================
Absolute     Input value is returned when the comparison is satisfied, behavior of old comparator
Reference    The reference value is output when the comparison is satisfied
Zone         Outputs the index (0 based) of the reference value that satisfied the comparison, n if none are valid
Pass / Fail  0 if the comparison fails, 1 if it passed
===========  =====================================================================================================

Also note that you can only use one reference value when creating feedback/feedforward loops.  ::

    var references: [Float] = [18.0, 20.0, 22.0, 24.0]
    let signal = mbl_mw_multi_chnl_temp_get_temperature_data_signal(board,MBL_MW_METAWEAR_RPRO_CHANNEL_ON_BOARD_THERMISTOR)!
    signal.comparatorCreate(0,MBL_MW_COMPARATOR_MODE_ZONE, references)

Counter
-------
A counter keeps a tally of how many times it is called.  It can be used by 
`MblMwEvent <https://mbientlab.com/docs/metawear/cpp/latest/event__fwd_8h.html#a569b89edd88766619bb41a2471743695>`_ pointers to count the numbers of 
times a MetaWear event was fired and enable simple events to utilize the full set of firmware features.  

Counter data is only interpreted as an unsigned integer. ::

    /// Tasky interface to mbl_mw_dataprocessor_counter_create
    public func counterCreateCount() -> Task<OpaquePointer> {
        let source = TaskCompletionSource<OpaquePointer>()
        let code = mbl_mw_dataprocessor_counter_create(self, bridgeRetained(obj: source)) { (context, counter) in
            let source: TaskCompletionSource<OpaquePointer> = bridgeTransfer(ptr: context!)
            if let counter = counter {
                source.trySet(result: counter)
            } else {
                source.trySet(error: MetaWearError.operationFailed(message: "could not create counter"))
            }
        }
        errorCheck(code: Int(code), source: source)
        return source.task
    }

    var disEvent = mbl_mw_settings_get_disconnect_event(device.board)
    disEvent.counterCreateCount()

Delta
-----
A delta processor computes the difference between two successive data values and only allows data through that creates a difference greater in magnitude 
than the specified threshold.  

When creating a delta processor, users will also choose how the processor transforms the output which can, in some cases, alter the output data type id.  

=============  =======================================  ==============================================
Output         Transformation                           Data Type ID
=============  =======================================  ==============================================
Absolute       Input passed through untouched           Same as input source i.e. float -> float
Differential   Difference between current and previous  If input is unsigned int, output is signed int
Binary         1 if difference > 0, -1 if less than 0   Output is always signed int
=============  =======================================  ==============================================

Constants identifying the output modes are defined in the `MblMwDeltaMode <https://mbientlab.com/docs/metawear/cpp/latest/delta_8h.html#ac9e3bece74c3bafb355bb158cf93b843>`_ enum. ::

    let signal = mbl_mw_gpio_get_pin_monitor_data_signal(device.board, pin)!
    signal.deltaCreate(mode: MBL_MW_DELTA_MODE_BINARY, magnitude: 1.0)

High Pass Filter
----------------
High pass filters compute the difference of the current value from a running average of the previous N samples.  

Output from this processor is delayed until the first N samples have been received.  ::

    var signal = mbl_mw_acc_get_acceleration_data_signal(board);
    mbl_mw_dataprocessor_highpass_create(self, 4, bridgeRetained(obj: source)) { (context, filter) in
        if let filter = filter {
            // Do something
        }
    }

.. _dataprocessor-math:

Math
----
The math processor performs arithmetic or logical operations on the input.  Users can force signed or unsigned operation, or allow the API to determine which is appropriate.  

Depending on the operation, the output data type id can change.

========================    ====================================================
Operation                   Data Type ID
========================    ====================================================
Add, Sub, Mult, Div, Mod    If input is unsigned, output is signed
Sqrt, Abs                   If input is signed, output is unsigned
Const                       Output type id is the same as input type id
Remaining Ops               API cannot infer, up to user to reassemble the bytes
========================    ====================================================

Constants identifying the operations are defined in the 
`MblMwMathOperation <https://mbientlab.com/docs/metawear/cpp/latest/math_8h.html#acb93d624e6a4bdfcda9bac362197b232>`_ enum. ::

    var temp_signal = mbl_mw_multi_chnl_temp_get_temperature_data_signal(board, MBL_MW_METAWEAR_RPRO_CHANNEL_ON_DIE);
    // Added 273.15C to the input converting units to Kelvin
    mbl_mw_dataprocessor_math_create(temp_signal, MBL_MW_MATH_OP_ADD, 273.15, bridgeRetained(obj: source)) { (context, math) in

    }

Like the comparator, the math processor also supports feedback/feedforward loops.  Using 
`mbl_mw_dataprocessor_math_modify_rhs_signal <https://mbientlab.com/docs/metawear/cpp/latest/math_8h.html#a7c7af2e8139e824b82c45b846b96abc6>`_, you can 
set the second operand with the output of another data signal.

Packer
------
The packer processor combines multiple data samples into 1 BLE packet to increase the data throughput.  You can pack between 4 to 8 samples per packet 
depending on the data size.

Note that if you use the packer processor with raw motion data instead of using their packed data producer variants, you will only be able to combine 2 
data samples into a packet instead of 3 samples however, you can chain an accounter processor to associate a timestamp with the packed data.  ::

    let signal = mbl_mw_acc_get_acceleration_data_signal(board)!
    return signal.packerCreate(count: 2)

Passthrough
-----------
The passthrough processor is akin to a gate in which the user has manual control over, exercised by setting the processor's count value using  
`mbl_mw_dataprocessor_passthrough_set_count <https://mbientlab.com/docs/metawear/cpp/latest/passthrough_8h.html#a537a105294960629fd035adac1a5d65b>`_.  

It has three operation modes that each use the count value differently:

=========== ==========================================
Mode        Description
=========== ==========================================
All         Allow all data through
Conditional Only allow data through if the count > 0
Count       Only allow a set number of samples through
=========== ==========================================

Constants identifying the operation modes are defined in the 
`MblMwPassthroughMode <https://mbientlab.com/docs/metawear/cpp/latest/passthrough_8h.html#a3fdd23d48b54420240c112fa811a56dd>`_ enum. ::

    var abs_gpio_signal = mbl_mw_gpio_get_analog_input_data_signal(board, 0, MBL_MW_GPIO_ANALOG_READ_MODE_ABS_REF);
    // Create a passthrough processor in count mode
    // only allows 16 data samples through, then block all other samples
    abs_gpio_signal.passthroughCreate(MBL_MW_PASSTHROUGH_COUNT, 16).continueOnSuccessWith { passthrough in
    
    }

Pulse
-----
The pulse processor detects and quantifies a pulse over a set of data.  

Pulses are defined as a minimum number of data points that rise above then fall below a threshold and quantified by transforming the collection of data into three different values:

========= ======================================== =================================
Output    Description                              Data Type ID
========= ======================================== =================================
Width     Number of samples that made up the pulse Unsigned integer
Area      Summation of all the data in the pulse   Same as input i.e. float -> float
Peak      Highest value in the pulse               Same as input i.e. float -> float
On Detect Return 0x1 as soon as pulse is detected  Unsigned integer
========= ======================================== =================================

Constants defining the different output modes are defined in the 
`MblMwPulseOutput <https://mbientlab.com/docs/metawear/cpp/latest/pulse_8h.html#abd7edcb82fd29ec984390673c60b4904>`_ enum. ::

    var adc_gpio_signal = mbl_mw_gpio_get_analog_input_data_signal(board, 0, MBL_MW_GPIO_ANALOG_READ_MODE_ADC)
    // values must rise above then fall below 512 and have a min of 16 values
    // the highest value in the collected data will be returned
    mbl_mw_dataprocessor_pulse_create(self, MBL_MW_PULSE_OUTPUT_PEAK, 512.0, 16, bridgeRetained(obj: source)) { (context, pulse) in

    }

.. _dataprocessor-rms:

RMS
---
The RMS processor computes the root mean square over multi component data i.e. XYZ values from acceleration data.  

The processor will convert `MblMwCartesianFloat <https://mbientlab.com/docs/metawear/cpp/latest/structMblMwCartesianFloat.html>`_ inputs into float outputs.  ::

    var acc_signal = mbl_mw_acc_get_acceleration_data_signal(board)
    acc_signal.mbl_mw_dataprocessor_rms_create(bridgeRetained(obj: source)) { (context, rms) in

    }

.. _dataprocessor-rss:

RSS
---
The RSS processor computes the root sum square, or vector magnitude, over multi component data i.e. XYZ values from acceleration data.  

The processor will convert `MblMwCartesianFloat <https://mbientlab.com/docs/metawear/cpp/latest/structMblMwCartesianFloat.html>`_ inputs into float outputs.  ::

    var acc_signal = mbl_mw_acc_get_acceleration_data_signal(board)
    acc_signal.mbl_mw_dataprocessor_rss_create(bridgeRetained(obj: source)) { (context, rss) in

    }

Sample
------
The sample processor acts like a bucket, only allowing data through once it has collected a set number of samples. It functions as a data historian of 
sorts providing a way to look at the data values prior to an event.  

The output data type id of an accumulator is the same as its input source. ::

    var switch_signal = mbl_mw_switch_get_state_data_signal(board)
    // collect 16 samples of switch state data before allowing data to pass
    switch_signal.sampleCreate(16)

Threshold
---------
The threshold processor only allows data through that crosses a boundary, either crossing above or below it.  

It has two output modes:

=============  ========================================== ==============================================
Output         Transformation                             Data Type ID
=============  ========================================== ==============================================
Absolute       Input passed through untouched             Same as input source i.e. float -> float
Binary         1 if value rose above, -1 if it fell below Output is always signed int
=============  ========================================== ==============================================

Constants identifying the output modes are defined by the 
`MblMwThresholdMode <https://mbientlab.com/docs/metawear/cpp/latest/threshold_8h.html#a63e1cc001aa56601099db511d3d3109c>`_ enum. ::

    var temp_signal = mbl_mw_multi_chnl_temp_get_temperature_data_signal(board, MBL_MW_METAWEAR_RPRO_CHANNEL_ON_BOARD_THERMISTOR);
    // only allow data through when it rises above or falls below 25C
    temp_signal.thresholdCreate(MBL_MW_THRESHOLD_MODE_BINARY, 25, 0)

Time
----
The time processor only allows data to pass at fixed intervals.  It can used to limit the rate at which data is received if your sensor does not have 
the desired sampling rate.  

The processor has two output modes:

=============  ======================================= ==============================================
Output         Transformation                          Data Type ID
=============  ======================================= ==============================================
Absolute       Input passed through untouched          Same as input source i.e. float -> float
Differential   Difference between current and previous If input is unsigned int, output is signed int
=============  ======================================= ==============================================

Constants identifying the the output modes are defined by the 
`MblMwTimeMode <https://mbientlab.com/docs/metawear/cpp/latest/time_8h.html#ac5166dcd417797f9bc13a5e388d9073c>`_. ::

    var device: MetaWear!
    device.timerCreate(period: 700)