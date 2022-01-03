.. highlight:: cpp

iBeacon
=======
iBeacon is a protocol developed by Apple. The main purpose of Beacons (which are simply Bluetooth advertisers - not connectable) is for location-data and proximity marketing. 

The MetaWear firmware supports the iBeacon format and can advertise itself as an iBeacon.  

To enable iBeacon mode, all you need to do is call 
`mbl_mw_ibeacon_enable <https://mbientlab.com/docs/metawear/cpp/latest/ibeacon_8h.html#a29227024839d419f2d536b6b3cc42481>`_ and disconnect from the 
board.  

The other functions in the `ibeacon.h <https://mbientlab.com/docs/metawear/cpp/latest/ibeacon_8h.html>`_ header file configure the 
advertisement parameters. ::

    let uuid = UUID().uuidString
    var array: [UInt8] = Array(uuid.utf8)
    let up: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.init(&array)
    mbl_mw_ibeacon_set_major(device.board, 78)
    mbl_mw_ibeacon_set_minor(device.board, 7453)
    mbl_mw_ibeacon_set_period(device.board, 15027)
    mbl_mw_ibeacon_set_rx_power(device.board, -55)
    mbl_mw_ibeacon_set_tx_power(device.board, -12)
    mbl_mw_ibeacon_set_uuid(device.board, up)
    mbl_mw_ibeacon_enable(device.board)
