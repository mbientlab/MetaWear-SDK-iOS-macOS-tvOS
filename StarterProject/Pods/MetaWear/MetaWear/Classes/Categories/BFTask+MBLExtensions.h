/**
 * BFTask+MBLExtensions.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 12/17/15.
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

#import <Bolts/Bolts.h>
#import <MetaWear/MBLConstants.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Convience functions for dealing with BFTasks within the MetaWear SDK
 */
@interface BFExecutor (MBLExtensions)

/**
 Executes on the [MBLMetaWearManager dispatchQueue]
 */
+ (instancetype)dispatchExecutor;

@end


/**
 Convience functions for dealing with BFTasks within the MetaWear SDK
 */
@interface BFTask<__covariant ResultType> (MBLExtensions)

typedef void (^MBLSuccessBlock)(ResultType result);
typedef void (^MBLErrorBlock)(NSError *error);

/**
 Add a block to be called if the task finishes successfully, complete with the 
 tasks result.  This callback will occur on the dispatchExecutor.
 */
- (instancetype)success:(MBLSuccessBlock)block;

/**
 Add a block to be called if the task finishes with an error.
 This callback will occur on the dispatchExecutor.
 */
- (instancetype)failure:(MBLErrorBlock)block;


/**
 Enqueues the given block to be run once this task completes successfully.
 This callback will occur on the dispatchExecutor.
 */
- (instancetype)continueOnDispatchWithSuccessBlock:(BFContinuationBlock)block;

/**
 Enqueues the given block to be run once this task completes.
 This callback will occur on the dispatchExecutor.
 */
- (instancetype)continueOnDispatchWithBlock:(BFContinuationBlock)block;

@end


extern void MBLForceLoadCategory_BFTask_MBLExtensions();

NS_ASSUME_NONNULL_END
