.. highlight:: swift

MetaWear Board
==============

The `MBLMetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html>`_ interface is a software representation of the MetaWear boards and is the central class of the MetaWear API.  It contains all the logical methods you would expect for interacting with the device, such as connecting, disconnecting, reading and writing state.

Sensors and peripherals on the MetaWear are encapsulated within their own objects accessible via properties.  For example, all ``accelerometer`` functionality is contained in the `MBLAccelerometer <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLAccelerometer.html>`_ class and is accessed using the ``accelerometer`` property

You always get a `MBLMetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html>`_ object through the `MBLMetaWearManager <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWearManager.html>`_ , afterwards, keep a reference to it as long as the app is running.  From here on assume that inside code blocks ``device`` is a `MBLMetaWear <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html>`_ object reference


Bluetooth LE Connection
-----------------------
Before using any API features, you must first connect to the board with `connectAsync <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html#//api/name/connectAsync>`_.  The returned task will finish when a connection has been established and the ``MBLMetaWear`` state has been initialized.  ::

    device.connectAsync().success { _ in
        print("Connected")
    }.failure { error in
        print("Failed to connect", error)
    }

There is also a convenient `connectWithTimeoutAsync <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html#//api/name/connectWithTimeoutAsync:>`_ which will finish when the connection is complete, or timeout seconds have passed.  If a timeout occurs, the task will get an error of kMBLErrorDomain and kMBLErrorConnectionTimeout code.  ::

    device.connect(withTimeoutAsync: 5).success { _ in
        print("Connected")
    }.failure { error in
        print("Failed to connect", error)
    }

Conversely, call `disconnectAsync <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html#//api/name/disconnectAsync>`_ to close the connection.  If there is a pending ``connectAsync`` task when ``disconnectAsync`` is called, the connect task will be cancelled.  ::

    device.disconnectAsync().success { _ in
        print("Disconnected")
    }

Watching for Disconnects
^^^^^^^^^^^^^^^^^^^^^^^^
It is often useful to handle BLE disconnection events, `waitForDisconnect <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html#//api/name/waitForDisconnect>`_ will create a task that completes once this device disconnects, either expectedly or unexpectedly.  ::

    device.waitForDisconnect().continueOnDispatch { t in
        print("Lost connection")
        return nil
    }


Saving MetaWears
----------------

If you expect to re-connect to a specific MetaWear device, you can "remember" it for easy retrieval later on through the MetaWear Manager.

Once you are done with the device, then "forget" it to remove it from the list.

::

    device.rememberDevice()

::

    device.forgetDevice()

Model
-----
Despite the name, the ``MBLMetaWear`` interface communicates with all MetaSensor boards, not just MetaWear boards.  Because of this, the interface provides a `model <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html#//api/name/model>`_ property that determines exactly which board the interface is currently connected to.

::

    print(MBLModelString(device.model))

BLE Information
---------------
RSSI and some GATT characetristics can be read from the MBLMetaWear interface using `readRssiAsync <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html#//api/name/readRSSIAsync>`_, `readBatteryLifeAsync <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html#//api/name/readBatteryLifeAsync>`_.  Device information is avaliable througth the `deviceInfo <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html#//api/name/deviceInfo>`_ property.  ::

    device.readRSSIAsync().success { rssi in
        print("rssi: \(rssi)")
    }
    device.readBatteryLifeAsync().success { battery in
        print("battery: \(battery)")
    }


Connection State
----------------

Get the state of the BLE connection.

::

    if device.state == .connected {
        print("Connected!")
    }



Programmed by Other Application
-------------------------------

Since we do not support using a single MetaWear device with multiple application, you should take care if a user accidently tries to do this.  Once connected, your application should check this BOOL and if it is YES, then you shouldn't change settings or perform any operations unless you supply the user with an alert saying, "This device is in use by another application, are you sure you want to reprogram it?  This will cause errors and data loss for the other application”.  If they agree then you need to call setConfigurationAsync: to take ownership of the device.

::

    if device.programedByOtherApp {
        print("WARNING - device already programmed, are you sure you want to continue?  Call device.setConfigurationAsync(nil) if you wish to take ownership.")
    }

Identifier
----------

Apple generates a unique identifier for each BLE device.  Note, two different Apple devices will generate two different identifiers for the same MetaWear.

::

    print("\(device.identifier)")

Device Name
-----------

By using the ``name`` property you can change the advertised ``name`` of the MetaWear.

::

    device.name = "HAMMER"


Modules
-------
MetaWear modules, represented by the `MBLModule <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLModule.html>`_ interface, are sensors, peripherals, or on-board firmware features.  To interact with the underlying MetaWear modules, retrieve a reference to the desired interface via properties on ``MBLMetaWear``.  A null pointer will be returned if any of the following conditions are true:

* Requested module is not supported on the board  
* Board is in MetaBoot mode  
* Has not yet connected
