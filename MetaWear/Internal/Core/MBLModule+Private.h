/**
 * MBLModule+Private.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/28/14.
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

#import "MBLModule.h"
#import "MBLConstants.h"
#import "MBLModuleInfo.h"
#import <Bolts/Bolts.h>

@class MBLMetaWear;
@class MBLRegister;
@class MBLEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 Internal header hiding unnessary functions from API user
 */
@interface MBLModule (Private)
/**
 Weak back pointer to the device which this module belongs to
 */
@property (nonatomic, weak, nullable) MBLMetaWear *device;
/**
 List of all registers that have been added to the module.
 */
@property (nonatomic) NSMutableArray *registers;
/**
 Module info as read from register 0
 */
@property (nonatomic) MBLModuleInfo *moduleInfo;
/**
 How many registers/events/data are currently using this module
 */
@property (nonatomic, readonly) int activateCount;
@property (nonatomic, readonly) int initializeCount;
/**
 A common firmware paradigm is to have one register that takes 0x1 to enable 
 it and 0x0 to disable it.  If such register exists, assign it here
 */
@property (nonatomic, nullable) MBLRegister *globalEnable;


/**
 You should always use this factory function to create modules because
 this instatiantes the proper subclass based on moduleInfo version
 */
+ (instancetype)objectWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo;

/**
 Init the device object
 */
- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo;

/**
 Make sure the state is valid, this is called on re-connect to make
 sure the MetaWear isn't tampered with
 */
- (BFTask *)isStateValid;

/**
 The module needs to know about all the registers it has for data routing
 purposes.
 */
- (void)addRegister:(MBLRegister *)reg;
/**
 Find the register for this message.  Data should be in the format
 of [module id, reg id, index] each a uint8_t.
 */
- (BFTask<MBLRegister *> *)getRegister:(NSData *)data;

/**
 Data from BLE radio first goes to the MBLMetaWear, which routes it
 to the appropriate module (by calling this method).  This method will
 then pass the data along to the appropriate MBLRegister
 */
- (void)recievedData:(NSData *)data error:(nullable NSError *)error;

/**
 Let the module know our BLE link was disconnected for some reason
 */
- (void)deviceDisconnected:(nullable NSError *)error;
/**
 Let the module know our BLE link connected
 */
- (BFTask *)deviceConnected;

/**
 A common firmware paradigm is the need to write one or more register to
 initialize the module.  This should be called before attempting to use
 this module.  Internally this just increments a counter, and when the count
 goes from 0 to 1 (first call) it will invoke performAsyncInitialization.
 As such MBLModule derivatives shouldn't override this, but rather
 performAsyncInitialization.
 */
- (BFTask *)initializeAsync;
/**
 A common firmware paradigm is the need to write one or more register to
 deinitialize the module.  This should be called after you are finished using
 this module.  Internally this just decrements a counter, and when the count
 goes from 1 to 0 (no more users) it will invoke performAsyncDeinitialization.
 As such MBLModule derivatives shouldn't override this, but rather performAsyncDeinitialization.
 */
- (BFTask *)deinitializeAsync;

/**
 A common firmware paradigm is the need to write one or more register to
 activate, or enable, the module.  This should be called after you have the module
 all setup and are ready to recieve data. Internally this just increments a counter,
 and when the count goes from 0 to 1 (first call) it will invoke performAsyncActivation.
 As such MBLModule derivatives shouldn't override this, but rather
 performAsyncActivation
 */
- (BFTask *)activateAsync;
/**
 A common firmware paradigm is the need to write one or more register to
 deactivate, or disable, the module.  This should be called after you are finished
 using this module.  Internally this just decrements a counter, and when the count
 goes from 1 to 0 (no more users) it will invoke performAsyncDeactivation.
 As such MBLModule derivatives shouldn't override this, but rather performAsyncDeactivation.
 */
- (BFTask *)deactivateAsync;

/**
 Derieved classes should override this and put in module specific initialization code
 */
- (BFTask *)performAsyncInitialization;
/**
 Derieved classes should override this and put in module specific deinitialization code
 */
- (BFTask *)performAsyncDeinitialization;
/**
 Derieved classes should override this and put in module specific activation code
 */
- (BFTask *)performAsyncActivation;
/**
 Derieved classes should override this and put in module specific deactivation code
 */
- (BFTask *)performAsyncDeactivation;

@end

NS_ASSUME_NONNULL_END
