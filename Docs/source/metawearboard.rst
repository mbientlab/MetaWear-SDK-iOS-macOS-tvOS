.. highlight:: swift

MetaWear Board
==============

The `MetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWear.html>`_ interface is a software representation of the MetaWear boards and is the central class of the MetaWear API.  It contains methods for connecting, disconnecting, saving and restoring state.

You always get a `MetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWear.html>`_ object through the `MetaWearScanner <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWearScanner.html>`_ , afterwards, keep a reference to it as long as the app is running.  From here on assume that inside code blocks ``device`` is a `MetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MetaWear.html>`_ object reference

Bluetooth LE Connection
-----------------------
Before using any API features, you must first connect to the board with `connectAsync <https://mbientlab.com/docs/metawear/ios/latest/Classes/MetaWear.html#/s:8MetaWearAAC15connectAndSetup10BoltsSwift4TaskCyAFyABGGyF>`_.  The returned task will finish when a connection has been established and the ``MetaWear`` state has been initialized.  ::

    device.connectAndSetup().continueWith { t in
        if t.isCancelled {
            print("cancelConnection() called before connection completed")
        } else if t.isFaulted {
            print("Connection Error: \(t.error?.localizedDescription ?? "N/A")")
        } else {
            print("Connection Success")
        }
    }

Conversely, call `cancelConnection <https://mbientlab.com/docs/metawear/ios/latest/Classes/MetaWear.html#/c:@M@MetaWear@objc(cs)MetaWear(im)cancelConnection>`_ to close the connection.  If there is a pending ``connectAndSetup`` task when ``cancelConnection`` is called, the connect task will be cancelled.  ::

    device.cancelConnection().continueWith { t in
        print("Disconnected")
    }

Watching for Disconnects
^^^^^^^^^^^^^^^^^^^^^^^^
It is often useful to handle BLE disconnection events.  The task returned from ``connectAndSetup`` will completes once this device disconnects, either expectedly or unexpectedly.  ::

    device.connectAndSetup().continueWith { t in
        t.result?.continueWith { t in
            print("Lost connection")
        }
    }


API Access Queue
----------------

The core of this SDK is the MetaWearCpp library, and **it's not indented to be thread safe**.  Any time you call one of its mbl_mw_* functions you will want to make sure you are on the ``apiAccessQueue`` or ``apiAccessExecutor`` in order to ensure crash free behavior.

::

Saving MetaWears
----------------

If you expect to re-connect to a specific MetaWear device, you can "remember" it for easy retrieval later on through the MetaWearScanner.

Once you are done with the device, then "forget" it to remove it from the list.

::

    device.remember()

::

    device.forget()


Connection State
----------------

Get the state of the SDK connection.

::

    if device.isConnectedAndSetup {
        print("Connected!")
    }


Identifier
----------

Apple generates a unique identifier for each BLE device.  Note, two different Apple devices will generate two different identifiers for the same MetaWear.  It might be useful to use ``device.mac`` instead.

::

    print("\(device.peripheral.identifier)")

