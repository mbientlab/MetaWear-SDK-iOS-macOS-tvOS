.. highlight:: cpp

Temperature
===========
A temperature sensor measures the ambient temperature in C or F degrees.

All boards come with various temperature sensors that measure ambient temperature. Some of the temperature sensors are on the main CPU chip, others come in analog form as a thermistor and some temperature sensors are included in the barometer chip. 

Functions communicating with the on-board temperature sensors are 
defined in the `multichanneltemperature.h <https://mbientlab.com/docs/metawear/cpp/latest/multichanneltemperature_8h.html>`_ header file.  

Source Types
------------
There are four types temperature sources providing data: 

===================  ===================================================================
Source               Description
===================  ===================================================================
nRF SOC              Temperature sensor on the nRF SOC
External Thermistor  Separate thermistor that can be connected to the gpio pins
Bosch Barometer      Temperature sensor from either the BMP280 or BME280 barometers
On-board Thermistor  Thermistor on the MetaWear board
===================  ===================================================================

The 
`MblMwMetaWearRChannel <https://mbientlab.com/docs/metawear/cpp/latest/multichanneltemperature_8h.html#a96960da7a5a3d192076d4a8d645a551c>`_ and 
`MblMwMetaWearRProChannel <https://mbientlab.com/docs/metawear/cpp/latest/multichanneltemperature_8h.html#ae9fc440a8349749f72dff273ecf75f71>`_ enums 
map the channel ids to temperature sources providing a quick way to interact with the specific temperature source if you know specifically what board 
you are using.  The RProChannel enum can be used with all boards except the MetaWear R.

Users can also programatically check which source corresponds to each channel using the 
`mbl_mw_multi_chnl_temp_get_source <https://mbientlab.com/docs/metawear/cpp/latest/multichanneltemperature_8h.html#a3cf72ca4088b55db7f447d9bc5d66e78>`_ 
function. ::

    let channedCount = mbl_mw_multi_chnl_temp_get_num_channels(device.board)
    for i in 0..<channedCount {
        print("Channel: \(i)")
        let source = mbl_mw_multi_chnl_temp_get_source(device.board, i)
        switch source {
        case MBL_MW_TEMPERATURE_SOURCE_NRF_DIE:
            //"On-Die"
        case MBL_MW_TEMPERATURE_SOURCE_EXT_THERM:
            //"External"
        case MBL_MW_TEMPERATURE_SOURCE_BMP280:
            //"BMP280"
        case MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM:
            //"On-Board"
        default:
            //"Custom"
        }
    }

External Thermistor
###################
External thermistors require additional configuration before they can produce reliable data.  Call 
`mbl_mw_multi_chnl_temp_configure_ext_thermistor <https://mbientlab.com/docs/metawear/cpp/latest/multichanneltemperature_8h.html#adaa6e52054fbb68b18c99fd60d57b4fa>`_ 
to tell the MetaWear what GPIO pins the thermistor is connected to and whether it is active high or low.

We have a blog post on our project's page explaining how to connect an external thermistor to the gpio pins, link 
`here <http://projects.mbientlab.com/metawear-and-thermistor/>`_.

Bosch Barometer
###############
Both the BMP280 and BME380 chips also measure ambient temperature.  To read from these temperature sources, you will need to first start the Bosch 
barometer.  

Boards that do not have a Bosch barometer, e.g. RG, C, and Detector boards, will always report 0C from this temperature source.

Reading Temperature
-------------------
Temperature reads are manually triggered by calling 
`mbl_mw_datasignal_read <https://mbientlab.com/docs/metawear/cpp/latest/datasignal_8h.html#a0a456ad1b6d7e7abb157bdf2fc98f179>`_.  The data is 
represented as a float and is in units of Celsius. ::

    let source = mbl_mw_multi_chnl_temp_get_source(device.board, UInt8(MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM.rawValue))
    let selected = mbl_mw_multi_chnl_temp_get_temperature_data_signal(device.board, UInt8(MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM.rawValue))!
    selected.read().continueOnSuccessWith(.mainThread) { obj in
        print(String(format: "%.1f°C", (obj.valueAs() as Float)))
    }

