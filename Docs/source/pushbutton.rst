.. highlight:: swift

Pushbutton
==========

The MetaWear board comes with a builtin pushbutton switch, encapsulated with the `MBLMechanicalSwitch <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMechanicalSwitch.html>`_ object.

Reading Switch Value
--------------------

You can read the current state with the following code.

::

    device.mechanicalSwitch?.switchValue.readAsync().success { result in
        print("Switch State: \(result.value.boolValue)")
    }

Listening For Change
--------------------

It's likely you just want to know when the switch is pressed or released, for that use the following.

::

    device.mechanicalSwitch?.switchUpdateEvent.startNotificationsAsync(handler: { (obj, error) in
        if let obj = obj {
            print("Switch Changed \(obj)")
        }
    })

