.. highlight:: Objective-C

Serial
======

A great way to extend the hardware features of MetaWear is to attach additional devices via a serial bus (I2C or SPI).

Read/Write
----------

To read or write to the registers on the device, first use the `MBLSerial <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLSerial.html>`_ module to create an `MBLI2CData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLI2CData.html>`_ or `MBLSPIData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLSPIData.html>`_ object, then invoke its read/write methods.

::

    MBLSPIData *bmi160 = [device.serial dataWithSlaveSelectPin:10
                                                      clockPin:0
                                                       mosiPin:11
                                                       misoPin:7
                                                      lsbFirst:0
                                                       spiMode:3
                                                  spiFrequency:6
                                             nativePinIndexing:1
                                                        length:5];

    uint8_t byte = 0xDA;
    [[bmi160 readWithParamtersAsync:[NSData dataWithBytes:&byte length:1]] success:^(MBLDataSample *result) {
        NSLog(@"%@", result);
    }];

::

    MBLI2CData<MBLDataSample *> *aReg = [device.serial dataAtDeviceAddress:0x1C
                                                           registerAddress:0x0D
                                                                    length:1];
    [aReg writeByteAsync:self.i2cScratchRegValue];

Periodic Reads
--------------

Since `MBLI2CData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLI2CData.html>`_ and `MBLSPIData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLSPIData.html>`_ derive from `MBLData <https://www.mbientlab.com/docs/metawear/ios/latest/Classes/MBLData.html>`_ they inherit its periodic read methods:

::

    MBLI2CData *reg = [device.i2c dataAtDeviceAddress:0x1C registerAddress:0x12 length:1];
    MBLEvent *periodicRead = [reg periodicReadWithPeriod:1000];
    [periodicRead startNotificationsWithHandlerAsync:^(MBLDataSample *obj, NSError *error) {
        NSLog(@"I am reading every second: %@", obj.data);
    }];

