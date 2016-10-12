/**
 * MBLSerial.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/20/15.
 * Copyright 2014-2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab via email: hello@mbientlab.com
 */

#import <MetaWear/MBLModule.h>
#import <MetaWear/MBLI2CData.h>
#import <MetaWear/MBLSPIData.h>
@class MBLDataSample;
@class MBLNumericData;

NS_ASSUME_NONNULL_BEGIN

/**
 Interface for reading/writing externally connected devices via a serial bus (I2C or SPI).
 */
@interface MBLSerial : MBLModule

/**
 Create an I2C data endpoint.  The deivce and register address
 will be available in the data sheet of whatever device you connect.
 Event callbacks will be provided an MBLDataSample object whose data
 property can be used to access the data as bytes.
 */
- (MBLI2CData<MBLDataSample *> *)dataAtDeviceAddress:(uint8_t)deviceAddress
                                     registerAddress:(uint8_t)registerAddress
                                              length:(uint8_t)length;

/**
 Create an I2C data endpoint.  The deivce and register address
 will be available in the data sheet of whatever device you connect.
 Event callbacks will be provided an MBLNumericData object whose value
 will contain the register value formatted as a number.
 */
- (MBLI2CData<MBLNumericData *> *)numberAtDeviceAddress:(uint8_t)deviceAddress
                                        registerAddress:(uint8_t)registerAddress
                                                 length:(uint8_t)length
                                               isSigned:(BOOL)isSigned;


/**
 Create an SPI data endpoint.  The deivce and register address
 will be available in the data sheet of whatever device you connect.
 */
- (MBLSPIData<MBLDataSample *> *)dataWithSlaveSelectPin:(uint8_t)slaveSelectPin
                                               clockPin:(uint8_t)clockPin
                                                mosiPin:(uint8_t)mosiPin
                                                misoPin:(uint8_t)misoPin
                                               lsbFirst:(BOOL)lsbFirst
                                                spiMode:(uint8_t)spiMode
                                           spiFrequency:(uint8_t)spiFrequency
                                      nativePinIndexing:(BOOL)nativePinIndexing
                                                 length:(uint8_t)length;

/**
 Create an SPI data endpoint.  The deivce and register address
 will be available in the data sheet of whatever device you connect.
 */
- (MBLSPIData<MBLNumericData *> *)numberWithSlaveSelectPin:(uint8_t)slaveSelectPin
                                                  clockPin:(uint8_t)clockPin
                                                   mosiPin:(uint8_t)mosiPin
                                                   misoPin:(uint8_t)misoPin
                                                  lsbFirst:(BOOL)lsbFirst
                                                   spiMode:(uint8_t)spiMode
                                              spiFrequency:(uint8_t)spiFrequency
                                         nativePinIndexing:(BOOL)nativePinIndexing
                                                    length:(uint8_t)length
                                                  isSigned:(BOOL)isSigned;

@end

NS_ASSUME_NONNULL_END
