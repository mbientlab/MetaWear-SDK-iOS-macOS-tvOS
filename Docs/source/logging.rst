.. highlight:: swift

Logging
=======
Logging functions in the `logging.h <https://mbientlab.com/docs/metawear/cpp/latest/logging_8h.html>`_ header file control the on-board logger.  

These functions go hand in hand with the data signal logger outlined in the :doc:`datasignal` section.  

Once a logger is created; logging functions can be used. After you have setup the signal loggers, start 
the logger by calling `mbl_mw_logging_start <https://mbientlab.com/docs/metawear/cpp/latest/logging_8h.html#acab2d6b1c4f5449a39fe3bf60205471f>`_. ::

    mbl_mw_logging_start(device.board, 0)

Once we are done logging, simply call: ::

    mbl_mw_logging_stop(device.board)

Note for the MMS
----------------
The MMS (MetaMotionS) board uses NAND flash memory to store data on the device itself. The NAND memory stores data in pages that are 512 entries large. When data is retrieved, it is retrieved in page sized chunks.

Before doing a full download of the log memory on the MMS, the final set of data needs to be written to the NAND flash before it can be downloaded as a page. To do this, you must call the function: ::

   mbl_mw_logging_flush_page(board);

This should not be called if you are still logging data.

Downloading Data
----------------
When you are ready to retrieve the data, execute 
`mbl_mw_logging_download <https://mbientlab.com/docs/metawear/cpp/latest/logging_8h.html#a5d972af91fc37cfcb235785e20974ed3>`_.  

You will need to pass in a `MblMwLogDownloadHandler <https://mbientlab.com/docs/metawear/cpp/latest/structMblMwLogDownloadHandler.html>`_ struct to handle notifications 
from the logger. ::

    var handlers = MblMwLogDownloadHandler()
    handlers.context = bridgeRetained(obj: self)
    handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
        let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
    }
    handlers.received_unknown_entry = { (context, id, epoch, data, length) in
        print("received_unknown_entry")
    }
    handlers.received_unhandled_entry = { (context, data) in
        print("received_unhandled_entry")
    }
    mbl_mw_logging_download(device.board, 100, &handlers)

Typical setup
----------------
Here is the skeleton code for a typical scenario logging and downloading the accelerometer data: ::

    func accelerometerStartLog() {
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            // Save logger for StopLog()
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
    }

    func accelerometerStopLog(logger:OpaquePointer) {
        mbl_mw_acc_stop(device.board)
        mbl_mw_acc_disable_acceleration_sampling(device.board)
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            DispatchQueue.main.async {
                print(acceleration.x, acceleration.y, acceleration.z)
            }
        }
        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            print(progress)
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
    }