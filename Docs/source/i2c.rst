.. highlight:: cpp

I2C
===
The Inter-Integrated Circuit (I2C) Protocol is a protocol intended to allow multiple "peripheral" digital integrated circuits ("chips") to communicate with the MetaWear board. 

The I2C module allows you to directly communicate with a sensor via the I2C bus. If you want to add sensors to the MetaWear board that communicate with I2C, this is possible using the I2C module. 

I2C functions are defined in the 
`i2c.h <https://mbientlab.com/docs/metawear/cpp/latest/i2c_8h.html>`_ header file.

Data Signal
-----------
I2C data signals are retrieved by calling 
`mbl_mw_i2c_get_data_signal <https://mbientlab.com/docs/metawear/cpp/latest/i2c_8h.html#af95de21e3550c0fa483a0f5eb228a391>`_.  You will need to pass 
two parameters: 

* Length variable that sets how many bytes the signal is expected to receive
* An unique ID identifying the signal

If the id value has already been used, the length parameter will be ignored and the previously created signal will be returned.  ::

    var length: UInt8 = 1
    let signal = mbl_mw_i2c_get_data_signal(device.board, length, 0)!

Read
----
To read I2C data, use the 
`mbl_mw_datasignal_read_with_parameters <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a71391d5862eb18327ce2aaaac4a12159>`_ 
function with the parameters set by the `MblMwI2cReadParameters <https://mbientlab.com/docs/metawear/cpp/latest/structMblMwI2cReadParameters.html>`_ 
struct.  ::

    let deviceAddress = UInt8(0x1c)
    let registerAddress = UInt8(0xd)
    var length: UInt8 = 1
    let signal = mbl_mw_i2c_get_data_signal(device.board, length, 0)!
    mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
        let bytes: [UInt8] = obj!.pointee.valueAs()
        print(bytes.description)
    }
    var parameters = MblMwI2cReadParameters(device_addr: deviceAddress, register_addr: registerAddress)
    mbl_mw_datasignal_read_with_parameters(signal, &parameters)

Write
-----
Writing data through the I2C bus is handled with the 
`mbl_mw_i2c_write <https://mbientlab.com/docs/metawear/cpp/latest/i2c_8h.html#a484a0f6338a2d90eb9167283c6859165>`_ function.  ::

    let deviceAddress = UInt8(0x77)
    let registerAddress = UInt8(0xf4)
    var writeData = Int32(0x37, radix: 16)
    var length: UInt8 = 1
    let array = Array(Data(bytes: &writeData, count: Int(length)))
    mbl_mw_i2c_write(device.board, deviceAddress, registerAddress, array, length)