/**
 * MetaWear.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/30/14.
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

#import <MetaWear/MBLAccelerometer.h>
#import <MetaWear/MBLAccelerometerBMA255.h>
#import <MetaWear/MBLAccelerometerBMA255MotionEvent.h>
#import <MetaWear/MBLAccelerometerBMI160.h>
#import <MetaWear/MBLAccelerometerBMI160MotionEvent.h>
#import <MetaWear/MBLAccelerometerBosch.h>
#import <MetaWear/MBLAccelerometerBoschLowOrHighGEvent.h>
#import <MetaWear/MBLAccelerometerData.h>
#import <MetaWear/MBLAccelerometerMMA8452Q.h>
#import <MetaWear/MBLAmbientLight.h>
#import <MetaWear/MBLAmbientLightLTR329.h>
#import <MetaWear/MBLANCS.h>
#import <MetaWear/MBLANCSEventData.h>
#import <MetaWear/MBLBarometer.h>
#import <MetaWear/MBLBarometerBosch.h>
#import <MetaWear/MBLBarometerBME280.h>
#import <MetaWear/MBLBarometerBMP280.h>
#import <MetaWear/bmi160.h>
#import <MetaWear/MBLConstants.h>
#import <MetaWear/MBLData.h>
#import <MetaWear/MBLDataSample.h>
#import <MetaWear/MBLDataSwitch.h>
#import <MetaWear/MBLDeviceInfo.h>
#import <MetaWear/MBLEntityEvent.h>
#import <MetaWear/MBLEntityModule.h>
#import <MetaWear/MBLEvent.h>
#import <MetaWear/MBLExternalThermistor.h>
#import <MetaWear/MBLEulerAngleData.h>
#import <MetaWear/MBLFilter.h>
#import <MetaWear/MBLFirmwareUpdateInfo.h>
#import <MetaWear/MBLGPIO.h>
#import <MetaWear/MBLGPIOPin.h>
#import <MetaWear/MBLConductance.h>
#import <MetaWear/MBLGyro.h>
#import <MetaWear/MBLGyroBMI160.h>
#import <MetaWear/MBLGyroData.h>
#import <MetaWear/MBLHapticBuzzer.h>
#import <MetaWear/MBLHygrometer.h>
#import <MetaWear/MBLHygrometerBME280.h>
#import <MetaWear/MBLI2C.h>
#import <MetaWear/MBLI2CData.h>
#import <MetaWear/MBLiBeacon.h>
#import <MetaWear/MBLLED.h>
#import <MetaWear/MBLMagnetometer.h>
#import <MetaWear/MBLMagnetometerBMM150.h>
#import <MetaWear/MBLMagnetometerData.h>
#import <MetaWear/MBLMechanicalSwitch.h>
#import <MetaWear/MBLMetaWear.h>
#import <MetaWear/MBLMetaWearManager.h>
#import <MetaWear/MBLModule.h>
#import <MetaWear/MBLNeopixel.h>
#import <MetaWear/MBLNeopixelStrand.h>
#import <MetaWear/MBLNumericData.h>
#import <MetaWear/MBLOrientationData.h>
#import <MetaWear/MBLPhotometer.h>
#import <MetaWear/MBLPhotometerTCS3472.h>
#import <MetaWear/MBLProximity.h>
#import <MetaWear/MBLProximityTSL2671.h>
#import <MetaWear/MBLQuaternionData.h>
#import <MetaWear/MBLRegister.h>
#import <MetaWear/MBLRGBData.h>
#import <MetaWear/MBLRMSAccelerometerData.h>
#import <MetaWear/MBLSensorFusion.h>
#import <MetaWear/MBLSerial.h>
#import <MetaWear/MBLSettings.h>
#import <MetaWear/MBLSPIData.h>
#import <MetaWear/MBLStringData.h>
#import <MetaWear/MBLTemperature.h>
#import <MetaWear/MBLTimer.h>
#import <MetaWear/MBLTimerEvent.h>

#import <MetaWear/BFTask+MBLExtensions.h>
