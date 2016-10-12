.. highlight:: Objective-C

Settings
========

You can control several BLE settings on the MetaWear board, encapsulated with the `MBLSettings <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLSettings.html>`_ object.

Radio Power
-----------

The radio transmit power is also exposed through a property.  Setting a smaller (lower dBm) value will result in a weaker radio signal, default is MBLTransmitPower0dBm

::

    device.settings.transmitPower = MBLTransmitPower0dBm;

Circular Buffer Log
-------------------

Choose what happens if the internal log fills up.  If circularBufferLog is YES then the oldest log entries will be deleted to make room for now entries, if NO then new entries will be discared.  Defaults to NO.

::

    device.settings.circularBufferLog = NO;

Scan Response
-------------

You can modify the BLE Ad Packet to advertise application specific data, this is done by setting a raw byte array which will be sent in the BLE scan response.  One example is to have the MetaWear behave as a `URI Beacon <http://uribeacon.org>`_:

::

    // Make it advertise http://www.mbientlab.com
    uint8_t rawuri[] = { 0x03, 0x03, 0xD8, 0xFE, 0x10, 0x16, 0xD8, 0xFE, 0x00, 0x12, 0x00, 0x6D, 0x62, 0x69, 0x65, 0x6E, 0x74, 0x6C, 0x61, 0x62, 0x00 };
    device.settings.scanResponse = [NSData dataWithBytes:rawuri length:sizeof(rawuri)];

Advertising Settings
--------------------

You can change the advertising interval and advertising timeout if you require advanced power saving features.  This should be carefully considered, because it affects the time to discovery and connect performance, and also battery life.

This is a startAdvertisement method which can be explicitly use to start advertisement after an advertising timeout has occured.  You can hook this call up to any MBLEvent if you need advanced ways to start advertising.  Note a button press it already hard coded to always trigger advertising, which should cover most cases.

::

    device.settings.advertisingInterval = 417.5; // Default value
    device.settings.advertisingTimeout = 0; // Default value - always advertise
    [device.settings startAdvertisementAsync];

Pairing/Bonding
---------------

In a few special cases, you may need to enable of Bluetooth level bonding. This is still in development, so not everything is exposed. To begin pairing simply call: ::

    [device.settings initiatePairingAsync];

To fully destroy the bond, you need to first call ``deleteAllBonds`` then disconnect.  Second, "Forget" the device in the iOS Settings APP under Bluetooth. ::

    [device.settings deleteAllBondsAsync];

Disconnect Event
----------------

Event representing a BLE disconnection event.  Note this doesn't make sense to stream, but it's likely that programCommandsToRunOnEventAsync will have utility.

::

    // Flash red LED twice on disconnect
    [device.settings.disconnectEvent programCommandsToRunOnEventAsync:^{
        [device.led flashLEDColorAsync:[UIColor redColor] withIntensity:1.0 numberOfFlashes:2];
    }];

MAC Address
-----------

Get the MAC address of the MetaWear.

::

    [[device.settings.macAddress readAsync] success:^(MBLStringData * _Nonnull result) {
        NSLog(@"%@", result.value);
    }];

