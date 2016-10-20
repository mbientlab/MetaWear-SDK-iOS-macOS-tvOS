/**
 * MBLEvent.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 9/15/14.
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
#import <MetaWear/MBLEvent.h>
#import <MetaWear/MBLModule.h>
#import <MetaWear/MBLData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBLCommand : MBLModule

/**
 This method is used for programing the Metawear device to perform actions
 automatically.  Any time this even occurs you can have it trigger other
 Metawear API calls even when the phone isn't connected.
 When this method is called, the given block executed and checked for
 validity.  All Metawear API calls inside the block are sent to the device
 for execution later.  THE BLOCK IS ONLY EXECUTED ONCE DURNING THIS CALL AND
 NEVER AGAIN, DON'T ATTEMPT TO USE CALLBACKS INSIDE THIS BLOCK
 @param block Block consisting of API calls to make when this event occus
 */
- (BFTask *)programCommandsToRunOnEventAsync:(MBLEvent *)event commands:(MBLVoidHandler)block;
/**
 Removes all commands setup when calling programCommandsToRunOnEventAsync:
 */
- (BFTask *)eraseCommandsToRunOnEventAsync:(MBLEvent *)event;

@property (nonatomic, copy, nullable) MBLObjectHandler activatedRegHandler;

@end

NS_ASSUME_NONNULL_END
