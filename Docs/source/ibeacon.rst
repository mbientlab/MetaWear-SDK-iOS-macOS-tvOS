.. highlight:: swift

iBeacon
=======

iBeacon is an indoor positioning system that uses a particular Bluetooth low-energy payload to make your device visible to the Apple CoreLocation framework.  See the `Apple Documentation <https://developer.apple.com/ibeacon/Getting-Started-with-iBeacon.pdf>`_ for more information.  Functionality is encapsulated in the `MBLiBeacon <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLiBeacon.html>`_ class.

Start iBeacon
-------------

To start using iBeacon set up the different properties and call setBeaconOnAsync(true)

::

    // Easily create your own uuid by running 'uuidgen' in the terminal
    device.iBeacon?.setUuid(CBUUID(string: "A1589B8C-3E02-4112-AA3C-54850F5C970A"))
    device.iBeacon?.setMajor(10)
    device.iBeacon?.setMinor(20)
    device.iBeacon?.setCalibratedReceiverPower(-55)
    device.iBeacon?.setTransmitPower(.power0dBm)
    device.iBeacon?.setFrequency(100)
    device.iBeacon?.setBeaconOnAsync(true)

    // YOU MUST DISCONNECT BEFORE IT WILL BECOME A VISIBLE BEACON
    device.disconnectAsync().success { _ in
        print("It's Beacon Time!")
    }
