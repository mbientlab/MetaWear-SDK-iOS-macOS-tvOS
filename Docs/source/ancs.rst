.. highlight:: swift

ANCS
====

Apple Notification Center Service (ANCS) gives MetaWear a simple and convenient way to access many kinds of notifications that are generated on iOS devices.   See the `Apple Documentation <https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/AppleNotificationCenterServiceSpecification/AppleNotificationCenterServiceSpecification.pdf>`_ for more information.

NOTE: The first time you invoke one of these functions, the iOS device will ask the user to Pair with the MetaWear board, Pairing is required for ANCS to work.  After Pairing, the iOS device will always keep an active connection to the MetaWear when in range to ensure prompt delievery of ANCS messages.

Notification Events
-------------------

It's simple to have the MetaWear flash when a notification comes in.

::

    let ancs = device.ancs?.event(withCategoryIds: .any)
    ancs?.programCommandsToRunOnEventAsync {
        device.led?.flashColorAsync(.red, withIntensity: 1.0)
    }

Filter Notification Events
--------------------------

You may want to be notified when you get a message from a special someone:

::

    let ancs = device.ancs?.event(withCategoryIds: .any,
                                  eventIds: .notificationAdded,
                                  eventFlags: .init(rawValue: 0),
                                  attributeId: .title,
                                  attributeData: "John Doe")
    ancs?.programCommandsToRunOnEventAsync {
        device.led?.flashColorAsync(.green, withIntensity: 1.0, numberOfFlashes: 5)
        device.hapticBuzzer?.startHapticAsync(dutyCycle: 255, pulseWidth: 500, completion: nil)
    }
