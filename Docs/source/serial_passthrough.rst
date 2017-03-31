.. highlight:: swift

Serial Passthrough
==================

A great way to extend the hardware features of MetaWear is to attach additional devices via a serial bus (I2C or SPI).

Read/Write
----------

To read or write to the registers on the device, first use the `MBLSerial <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLSerial.html>`_ module to create an `MBLI2CData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLI2CData.html>`_ or `MBLSPIData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLSPIData.html>`_ object, then invoke its read/write methods.

::

    let bmi160 = device.serial?.data(withSlaveSelectPin: 10,
                                     clockPin: 0,
                                     mosiPin: 11,
                                     misoPin: 7,
                                     lsbFirst: false,
                                     spiMode: 3,
                                     spiFrequency: 6,
                                     nativePinIndexing: true,
                                     length: 5)
    let byte: UInt8 = 0xDA
    bmi160?.read(withParamtersAsync: Data(bytes: [byte])).success { result in
        print(result)
    }

::

    let aReg = device.serial?.data(atDeviceAddress: 0x1C, registerAddress: 0x0D, length: 1)
    aReg?.writeByteAsync(0x55)

Periodic Reads
--------------

Since `MBLI2CData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLI2CData.html>`_ and `MBLSPIData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLSPIData.html>`_ derive from `MBLData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLData.html>`_ they inherit its periodic read methods:

::

    let reg = device.serial?.data(atDeviceAddress: 0x1C, registerAddress: 0x12, length: 1)
    let periodicRead = reg?.periodicRead(withPeriod: 1000)
    periodicRead?.startNotificationsAsync(handler: { (obj, error) in
        print("I am reading every second: " + String(describing: obj))
    })
