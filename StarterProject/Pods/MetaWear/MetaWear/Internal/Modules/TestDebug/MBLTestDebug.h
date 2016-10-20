/**
 * MBLTestDebug.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/12/14.
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

#import <MetaWear/MBLConstants.h>
#import <MetaWear/MBLModule.h>
#import <Bolts/Bolts.h>
@class MBLEvent;
@class MBLFormat;
@class MBLRegister;

NS_ASSUME_NONNULL_BEGIN

@interface MBLTestDebug : MBLModule
@property (nonatomic) uint32_t magicKey;
@property (nonatomic, readonly) MBLRegister *keyRegister;

/**
 Indicates if triggerDisconnect was called or not
 */
@property (nonatomic) BOOL triggerDisconnectInProgress;

/**
 Reset board immediately
 */
- (BFTask *)resetDevice;

/**
 This makes sure that non-volatile memory is clean'd up first before a rest happens
 */
- (BFTask *)resetDeviceAfterGarbageCollect;

/**
 Enter Bootloader mode
 */
- (BFTask *)jumpToBootloader;

/**
 Triggers a GAP disconnect
 */
- (BFTask *)triggerDisconnect;

/**
 This checks to see if we are the application that currently claims to own this MetaWear
 */
- (BFTask<NSNumber *> *)isGuestApplicationAsync;

/**
 Command values to write magic value to the key register
 */
- (NSData *)writeKeyRegisterCommand;

/**
 Get a spoofable event for use with 
 */
- (MBLEvent *)spoofEvent:(MBLFormat *)format;
/**
 Spoof an array of notifications on the MetaWear. Format is:
 @["01-02-03-01-10",
   "AB-CD-EF-01-88-22-33-44"];
 */
- (BFTask *)spoofData:(NSArray *)data notification:(BOOL)notification;

/**
 Spoof any event you want
 */
- (BFTask *)spoofRawData:(NSArray *)data;

/**
 Enters powerdown mode on next reset after resetting all sensors at boot.
 */
- (BFTask *)enterPowersaveOnReset;

/**
 Invalidate firmware image and force bootloader. 
 */
- (BFTask *)invalidateAppImage;

@end

NS_ASSUME_NONNULL_END
