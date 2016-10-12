.. highlight:: Objective-C

Pushbutton
==========

The MetaWear board comes with a builtin pushbutton switch, encapsulated with the `MBLMechanicalSwitch <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMechanicalSwitch.html>`_ object.

Reading Switch Value
--------------------

You can read the current state with the following code.

::

    [[device.mechanicalSwitch.switchValue readAsync] success:^(MBLNumericData * _Nonnull result) {
       NSLog(@"Switch State: %d", result.value.boolValue);
    }];

Listening For Change
--------------------

It's likely you just want to know when the switch is pressed or released, for that use the following.

::

    [device.mechanicalSwitch.switchUpdateEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        NSLog(@"Switch Changed: %@", obj);
    }];

