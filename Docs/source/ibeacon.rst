.. highlight:: Objective-C

iBeacon
=======

iBeacon is an indoor positioning system that uses a particular Bluetooth low-energy payload to make your device visible to the Apple CoreLocation framework.  See the `Apple Documentation <https://developer.apple.com/ibeacon/Getting-Started-with-iBeacon.pdf>`_ for more information.  Functionality is encapsulated in the `MBLiBeacon <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLiBeacon.html>`_ class.

Start iBeacon
-------------

To start using iBeacon set up the different properties and call setBeaconOnAsync:YES

::

    // Easily create your own uuid by running 'uuidgen' in the terminal
    device.iBeacon.uuid = [CBUUID UUIDWithString:@"A1589B8C-3E02-4112-AA3C-54850F5C970A"];
    device.iBeacon.major = 10;
    device.iBeacon.minor = 20;
    device.iBeacon.calibratedReceiverPower = -55;
    device.iBeacon.transmitPower = MBLiBeaconTransmitPower0dBm;
    device.iBeacon.frequency = 100;
    
    [device.iBeacon setBeaconOnAsync:YES];
    // YOU MUST DISCONNECT BEFORE IT WILL BECOME A VISIBLE BEACON
    [[device disconnectAsync] success:^(MBLMetaWear * _Nonnull result) {
        NSLog(@"It's Beacon Time!");
    }];
