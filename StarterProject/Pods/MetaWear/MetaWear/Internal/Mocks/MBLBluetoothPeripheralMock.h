/**
 * MBLBluetoothPeripheralMock.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 9/23/16.
 * Copyright 2016 MbientLab Inc. All rights reserved.
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

#import "MBLBluetoothPeripheral.h"
#import <MetaWear/MetaWear.h>

typedef void (^MBLHapticHandler)(uint8_t dutyCycle, uint16_t pulseWidth);
typedef void (^MBLBuzzerHandler)(uint8_t dutyCycle, uint16_t pulseWidth);


@interface MBLBluetoothPeripheralMock : NSObject <MBLBluetoothPeripheral>
// Properties required by the MBLBluetoothPeripheral protocol
@property id<MBLBluetoothPeripheralDelegate> delegate;
@property NSString *name;
@property CBPeripheralState state;
@property NSArray<CBService *> *services;
@property NSUUID *identifier;

// Fun knobs to play with for testing
@property (nonatomic) double discoverServicesWaitTime;
@property (nonatomic) uint32_t keyRegister;
@property (nonatomic) BOOL isMetaBoot;
- (void)resetKnobs;

// In order to check that the peripherals are working you can watch them
// by attaching a handler to see what sort of outputs they report
@property (nonatomic) MBLHapticHandler hapticHandler;
@property (nonatomic) MBLBuzzerHandler buzzerHandler;

- (instancetype)initWithVersion:(MBLFirmwareVersion)version model:(MBLModel)model;

// Used by the mock modules to send firmware responses
- (void)messageSend:(uint8_t)modId regId:(uint8_t)regId notifyen:(uint8_t)notifyen data:(NSData *)data;

@end
