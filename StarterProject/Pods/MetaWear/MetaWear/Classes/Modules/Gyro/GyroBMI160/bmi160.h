#ifndef __BMI160_H__
#define __BMI160_H__
/**
 * bmi160.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/19/15.
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

#include <stdint.h>

#define BMI160_SPI_RD_MASK                      0x80   /* for spi read transactions on SPI the
            MSB has to be set */

#define BMI160_I2C_ADDR1                        0x68 /**< I2C Address needs to be changed */
#define BMI160_I2C_ADDR2                        0x69 /**< I2C Address needs to be changed */
#define BMI160_BMM150_I2C_ADDRESS               0x10 /**< I2C address of BMM150*/

#define BMI160_CHIP_ID                          0xD1

#define BMI160_MAXIMUM_TIMEOUT                  ((uint8_t)10)

#define E_BMI160_NULL_PTR                       ((int8_t)-127)
#define E_BMI160_COMM_RES                       ((int8_t)-1)
#define E_BMI160_OUT_OF_RANGE                   ((int8_t)-2)
#define E_BMI160_BUSY                           ((int8_t)-3)
#define SUCCESS                                 ((uint8_t)0)
#define ERROR                                   ((int8_t)-1)

/* Constants */
#define BMI160_NULL                              0
#define BMI160_DELAY_SETTLING_TIME               5

#define BMI160_USER_CHIP_ID_ADDR                 0x00
#define BMI160_USER_ERROR_ADDR                   0x02
#define BMI160_USER_PMU_STAT_ADDR                0x03

/*******************/
/**\name MAG DATA REGISTERS */
/*******************/
#define BMI160_USER_DATA_0_ADDR                  0x04
#define BMI160_USER_DATA_1_ADDR                  0x05
#define BMI160_USER_DATA_2_ADDR                  0x06
#define BMI160_USER_DATA_3_ADDR                  0x07
#define BMI160_USER_DATA_4_ADDR                  0x08
#define BMI160_USER_DATA_5_ADDR                  0x09
#define BMI160_USER_DATA_6_ADDR                  0x0A
#define BMI160_USER_DATA_7_ADDR                  0x0B

/*******************/
/**\name GYRO DATA REGISTERS */
/*******************/
#define BMI160_USER_DATA_8_ADDR                  0x0C
#define BMI160_USER_DATA_9_ADDR                  0x0D
#define BMI160_USER_DATA_10_ADDR                 0x0E
#define BMI160_USER_DATA_11_ADDR                 0x0F
#define BMI160_USER_DATA_12_ADDR                 0x10
#define BMI160_USER_DATA_13_ADDR                 0x11

/*******************/
/**\name ACCEL DATA REGISTERS */
/*******************/
#define BMI160_USER_DATA_14_ADDR                 0x12
#define BMI160_USER_DATA_15_ADDR                 0x13
#define BMI160_USER_DATA_16_ADDR                 0x14
#define BMI160_USER_DATA_17_ADDR                 0x15
#define BMI160_USER_DATA_18_ADDR                 0x16
#define BMI160_USER_DATA_19_ADDR                 0x17

/*******************/
/**\name SENSOR TIME REGISTERS */
/*******************/
#define BMI160_USER_SENSORTIME_0_ADDR            0x18
#define BMI160_USER_SENSORTIME_1_ADDR            0x19
#define BMI160_USER_SENSORTIME_2_ADDR            0x1A

/*******************/
/**\name STATUS REGISTER FOR SENSOR STATUS FLAG */
/*******************/
#define BMI160_USER_STAT_ADDR                    0x1B

/*******************/
/**\name INTERRUPY STATUS REGISTERS */
/*******************/
#define BMI160_USER_INTR_STAT_0_ADDR             0x1C
#define BMI160_USER_INTR_STAT_1_ADDR             0x1D
#define BMI160_USER_INTR_STAT_2_ADDR             0x1E
#define BMI160_USER_INTR_STAT_3_ADDR             0x1F

/*******************/
/**\name TEMPERATURE REGISTERS */
/*******************/
#define BMI160_USER_TEMPERATURE_0_ADDR           0x20
#define BMI160_USER_TEMPERATURE_1_ADDR           0x21

/*******************/
/**\name FIFO REGISTERS */
/*******************/
#define BMI160_USER_FIFO_LENGTH_0_ADDR           0x22
#define BMI160_USER_FIFO_LENGTH_1_ADDR           0x23
#define BMI160_USER_FIFO_DATA_ADDR               0x24

/***************************************************/
/**\name ACCEL CONFIG REGISTERS  FOR ODR, BANDWIDTH AND UNDERSAMPLING*/
/******************************************************/
#define BMI160_USER_ACCEL_CONFIG_ADDR            0x40

/*******************/
/**\name ACCEL RANGE */
/*******************/
#define BMI160_USER_ACCEL_RANGE_ADDR             0x41

/***************************************************/
/**\name GYRO CONFIG REGISTERS  FOR ODR AND BANDWIDTH */
/******************************************************/
#define BMI160_USER_GYRO_CONFIG_ADDR             0x42

/*******************/
/**\name GYRO RANGE */
/*******************/
#define BMI160_USER_GYRO_RANGE_ADDR              0x43

/***************************************************/
/**\name MAG CONFIG REGISTERS  FOR ODR*/
/******************************************************/
#define BMI160_USER_MAG_CONFIG_ADDR              0x44

/***************************************************/
/**\name REGISTER FOR GYRO AND ACCEL DOWNSAMPLING RATES FOR FIFO*/
/******************************************************/
#define BMI160_USER_FIFO_DOWN_ADDR               0x45

/***************************************************/
/**\name FIFO CONFIG REGISTERS*/
/******************************************************/
#define BMI160_USER_FIFO_CONFIG_0_ADDR           0x46
#define BMI160_USER_FIFO_CONFIG_1_ADDR           0x47

/***************************************************/
/**\name MAG INTERFACE REGISTERS*/
/******************************************************/
#define BMI160_USER_MAG_IF_0_ADDR                0x4B
#define BMI160_USER_MAG_IF_1_ADDR                0x4C
#define BMI160_USER_MAG_IF_2_ADDR                0x4D
#define BMI160_USER_MAG_IF_3_ADDR                0x4E
#define BMI160_USER_MAG_IF_4_ADDR                0x4F

/***************************************************/
/**\name INTERRUPT ENABLE REGISTERS*/
/******************************************************/
#define BMI160_USER_INTR_ENABLE_0_ADDR           0x50
#define BMI160_USER_INTR_ENABLE_1_ADDR           0x51
#define BMI160_USER_INTR_ENABLE_2_ADDR           0x52
#define BMI160_USER_INTR_OUT_CTRL_ADDR           0x53

/***************************************************/
/**\name LATCH DURATION REGISTERS*/
/******************************************************/
#define BMI160_USER_INTR_LATCH_ADDR              0x54

/***************************************************/
/**\name MAP INTERRUPT 1 and 2 REGISTERS*/
/******************************************************/
#define BMI160_USER_INTR_MAP_0_ADDR              0x55
#define BMI160_USER_INTR_MAP_1_ADDR              0x56
#define BMI160_USER_INTR_MAP_2_ADDR              0x57

/***************************************************/
/**\name DATA SOURCE REGISTERS*/
/******************************************************/
#define BMI160_USER_INTR_DATA_0_ADDR             0x58
#define BMI160_USER_INTR_DATA_1_ADDR             0x59

/***************************************************/
/**\name
INTERRUPT THRESHOLD, HYSTERESIS, DURATION, MODE CONFIGURATION REGISTERS*/
/******************************************************/
#define BMI160_USER_INTR_LOWHIGH_0_ADDR          0x5A
#define BMI160_USER_INTR_LOWHIGH_1_ADDR          0x5B
#define BMI160_USER_INTR_LOWHIGH_2_ADDR          0x5C
#define BMI160_USER_INTR_LOWHIGH_3_ADDR          0x5D
#define BMI160_USER_INTR_LOWHIGH_4_ADDR          0x5E
#define BMI160_USER_INTR_MOTION_0_ADDR           0x5F
#define BMI160_USER_INTR_MOTION_1_ADDR           0x60
#define BMI160_USER_INTR_MOTION_2_ADDR           0x61
#define BMI160_USER_INTR_MOTION_3_ADDR           0x62
#define BMI160_USER_INTR_TAP_0_ADDR              0x63
#define BMI160_USER_INTR_TAP_1_ADDR              0x64
#define BMI160_USER_INTR_ORIENT_0_ADDR           0x65
#define BMI160_USER_INTR_ORIENT_1_ADDR           0x66
#define BMI160_USER_INTR_FLAT_0_ADDR             0x67
#define BMI160_USER_INTR_FLAT_1_ADDR             0x68

/***************************************************/
/**\name FAST OFFSET CONFIGURATION REGISTER*/
/******************************************************/
#define BMI160_USER_FOC_CONFIG_ADDR              0x69

/***************************************************/
/**\name MISCELLANEOUS CONFIGURATION REGISTER*/
/******************************************************/
#define BMI160_USER_CONFIG_ADDR                  0x6A

/***************************************************/
/**\name SERIAL INTERFACE SETTINGS REGISTER*/
/******************************************************/
#define BMI160_USER_IF_CONFIG_ADDR               0x6B

/***************************************************/
/**\name GYRO POWER MODE TRIGGER REGISTER */
/******************************************************/
#define BMI160_USER_PMU_TRIGGER_ADDR             0x6C

/***************************************************/
/**\name SELF_TEST REGISTER*/
/******************************************************/
#define BMI160_USER_SELF_TEST_ADDR               0x6D

/***************************************************/
/**\name SPI,I2C SELECTION REGISTER*/
/******************************************************/
#define BMI160_USER_NV_CONFIG_ADDR               0x70

/***************************************************/
/**\name ACCEL AND GYRO OFFSET REGISTERS*/
/******************************************************/
#define BMI160_USER_OFFSET_0_ADDR                0x71
#define BMI160_USER_OFFSET_1_ADDR                0x72
#define BMI160_USER_OFFSET_2_ADDR                0x73
#define BMI160_USER_OFFSET_3_ADDR                0x74
#define BMI160_USER_OFFSET_4_ADDR                0x75
#define BMI160_USER_OFFSET_5_ADDR                0x76
#define BMI160_USER_OFFSET_6_ADDR                0x77

/***************************************************/
/**\name STEP COUNTER INTERRUPT REGISTERS*/
/******************************************************/
#define BMI160_USER_STEP_COUNT_0_ADDR            0x78
#define BMI160_USER_STEP_COUNT_1_ADDR            0x79

/***************************************************/
/**\name STEP COUNTER CONFIGURATION REGISTERS*/
/******************************************************/
#define BMI160_USER_STEP_CONFIG_0_ADDR           0x7A
#define BMI160_USER_STEP_CONFIG_1_ADDR           0x7B

/***************************************************/
/**\name COMMAND REGISTER*/
/******************************************************/
#define BMI160_CMD_COMMANDS_ADDR                 0x7E

/***************************************************/
/**\name PAGE REGISTERS*/
/******************************************************/
#define BMI160_CMD_EXT_MODE_ADDR                 0x7F
#define BMI160_COM_C_TRIM_FIVE_ADDR              0x85

#define BMM150_MAX_RETRY_WAKEUP                 5
#define BMM150_POWER_OFF                        0x00
#define BMM150_POWER_ON                         0x01
#define BMM150_FORCE_MODE                       0x02
#define BMM150_POWER_ON_SUCCESS                 0
#define BMM150_POWER_ON_FAIL                    ((int8_t)-1)

#define BMM150_CALIB_HEX_FOUR_THOUSAND          0x4000
#define BMM150_CALIB_HEX_LACKS                  0x100000
#define BMM150_CALIB_HEX_A_ZERO                 0xA0
#define BMM150_DIG_X1                           0
#define BMM150_DIG_Y1                           1
#define BMM150_DIG_X2                           2
#define BMM150_DIG_Y3                           3
#define BMM150_DIG_XY1                          4
#define BMM150_DIG_XY2                          5
#define BMM150_DIG_Z1_LSB                       6
#define BMM150_DIG_Z1_MSB                       7
#define BMM150_DIG_Z2_LSB                       8
#define BMM150_DIG_Z2_MSB                       9
#define BMM150_DIG_DIG_Z3_LSB                   10
#define BMM150_DIG_DIG_Z3_MSB                   11
#define BMM150_DIG_DIG_Z4_LSB                   12
#define BMM150_DIG_DIG_Z4_MSB                   13
#define BMM150_DIG_DIG_XYZ1_LSB                 14
#define BMM150_DIG_DIG_XYZ1_MSB                 15

/**************************************************************/
/**\name    STRUCTURE DEFINITIONS                         */
/**************************************************************/
/*!
*    @brief bmi160 structure
*    This structure holds all relevant information about bmi160
*/
typedef struct {
  uint8_t             chip_id; /**< chip id of BMI160 */
  uint8_t             dev_addr; /**< device address of BMI160 */
  uint8_t             mag_manual_enable;  /**< used for check the mag manual/auto mode status */
//  BMI160_WR_FUNC_PTR;/**< bus write function pointer */
//  BMI160_RD_FUNC_PTR;/**< bus read function pointer */
//  BMI160_BRD_FUNC_PTR;/**< burst write function pointer */
//  void (*delay_msec)(BMI160_MDELAY_DATA_TYPE);/**< delay function pointer */
} bmi160_t;

typedef struct {
  uint8_t   fatal_err:1;
  uint8_t   err_code:4;
  uint8_t   i2c_fail_err:1;
  uint8_t   drop_cmd_err:1;
  uint8_t   mag_drdy_err:1;
} bmi160_reg_err_reg_t;

typedef struct {
  uint8_t   mag_pmu_status:2;
  uint8_t   gyr_pmu_status:2;
  uint8_t   acc_pmu_status:2;
  uint8_t   :2;
} bmi160_reg_pmu_status_t;

/*!
 * @brief Structure containing bmm150 and akm09911
 *    magnetometer values for x,y and
 *    z-axis in int16_t
 */
typedef struct {
  int16_t x;  /**< BMM150 and AKM09911 X raw data*/
  int16_t y;  /**< BMM150 and AKM09911 Y raw data*/
  int16_t z;  /**< BMM150 and AKM09911 Z raw data*/
} bmi160_mag_data_t;

/*!
 * @brief Structure containing bmm150 xyz data and temperature
 */
typedef struct {
  int16_t x;  /**< BMM150 X raw data*/
  int16_t y;  /**< BMM150 Y raw data*/
  int16_t z;  /**<BMM150 Z raw data*/
  uint16_t r; /**<BMM150 R raw data*/
} bmi160_mag_data_xyzr_t;

/*!
 * @brief Structure bmm150 mag compensated data with int32_t output
 */
typedef struct {
  int32_t x;  /**<BMM150 X compensated data*/
  int32_t y;  /**<BMM150 Y compensated data*/
  int32_t z;  /**<BMM150 Z compensated data*/
} bmi160_mag_xyz_int32_t_t;

/*!
 * @brief Structure containing gyro xyz data
 */
typedef struct {
  int16_t x;  /**<gyro X  data*/
  int16_t y;  /**<gyro Y  data*/
  int16_t z;  /**<gyro Z  data*/
} bmi160_gyro_data_t;

/*!
 * @brief Structure containing accel xyz data
 */
typedef struct {
  int16_t x;  /**<accel X  data*/
  int16_t y;  /**<accel Y  data*/
  int16_t z;  /**<accel Z  data*/
} bmi160_accel_data_t;

/*!
 * @brief Structure bmm150 mag trim data
 */
typedef struct {
  int8_t dig_x1;  /**<BMM150 trim x1 data*/
  int8_t dig_y1;  /**<BMM150 trim y1 data*/

  int8_t dig_x2;  /**<BMM150 trim x2 data*/
  int8_t dig_y2;  /**<BMM150 trim y2 data*/

  uint16_t dig_z1;  /**<BMM150 trim z1 data*/
  int16_t dig_z2;   /**<BMM150 trim z2 data*/
  int16_t dig_z3;   /**<BMM150 trim z3 data*/
  int16_t dig_z4;   /**<BMM150 trim z4 data*/

  uint8_t dig_xy1;  /**<BMM150 trim xy1 data*/
  int8_t dig_xy2;   /**<BMM150 trim xy2 data*/

  uint16_t dig_xyz1;/**<BMM150 trim xyz1 data*/
} bmm150_trim_data_t;

typedef struct {
  uint32_t sensor_time:24;
} bmi160_reg_sensortime_t;

typedef struct {
  uint8_t :1;
  uint8_t gyr_self_test_ok:1;
  uint8_t mag_man_op:1;
  uint8_t foc_rdy:1;
  uint8_t nvm_rdy:1;
  uint8_t drdy_mag:1;
  uint8_t drdy_gyr:1;
  uint8_t drdy_acc:1;
} bmi160_reg_status_t;

typedef struct {
  uint8_t step_int:1;
  uint8_t sigmot_int:1;
  uint8_t anym_int:1;
  uint8_t pmu_trigger_int:1;
  uint8_t d_tap_int:1;
  uint8_t s_tap_int:1;
  uint8_t orient_int:1;
  uint8_t flat_int:1;
} bmi160_reg_int_status_0_t;

typedef struct {
  uint8_t :2;
  uint8_t highg_int:1;
  uint8_t lowg_int:1;
  uint8_t drdy_int:1;
  uint8_t ffull_int:1;
  uint8_t fwm_int:1;
  uint8_t nomo_int:1;
} bmi160_reg_int_status_1_t;

typedef struct {
  uint8_t anym_first_x:1;
  uint8_t anym_first_y:1;
  uint8_t anym_first_z:1;
  uint8_t anym_sign:1;
  uint8_t tap_first_x:1;
  uint8_t tap_first_y:1;
  uint8_t tap_first_z:1;
  uint8_t tap_sign:1;
} bmi160_reg_int_status_2_t;

typedef struct {
  uint8_t high_first_x:1;
  uint8_t high_first_y:1;
  uint8_t high_first_z:1;
  uint8_t high_sign:1;
  uint8_t orient:3;
  uint8_t flat:1;
} bmi160_reg_int_status_3_t;

typedef struct {
  uint16_t temperature;
} bmi160_reg_temperature_t;

typedef struct {
  uint16_t fifo_byte_counter:11;
  uint16_t :5;
} bmi160_reg_fifo_length_t;

typedef struct {
  uint8_t acc_odr:4;
  uint8_t acc_bwp:3;
  uint8_t acc_us:1;
} bmi160_reg_acc_conf_t;

typedef struct {
  uint8_t acc_range:4;
  uint8_t :4;
} bmi160_reg_acc_range_t;

typedef struct {
  uint8_t gyr_odr:4;
  uint8_t gyr_bwp:2;
  uint8_t :2;
} bmi160_reg_gyr_conf_t;

typedef struct {
  uint8_t gyr_range:3;
  uint8_t :5;
} bmi160_reg_gyr_range_t;

typedef struct {
  uint8_t mag_odr:4;
  uint8_t :4;
} bmi160_reg_mag_conf_t;

typedef struct {
  uint8_t gyr_fifo_downs:3;
  uint8_t gyr_fifo_filt_data:1;
  uint8_t acc_fifo_downs:3;
  uint8_t acc_fifo_filt_data:1;
} bmi160_reg_fifo_downs_t;

typedef struct {
  uint8_t fifo_water_mark;
} bmi160_reg_fifo_config_0_t;

typedef struct {
  uint8_t :1;
  uint8_t fifo_time_en:1;
  uint8_t fifo_tag_int2_en:1;
  uint8_t fifo_tag_int1_en:1;
  uint8_t fifo_header_en:1;
  uint8_t fifo_mag_en:1;
  uint8_t fifo_acc_en:1;
  uint8_t fifo_gyr_en:1;
} bmi160_reg_fifo_config_1_t;

typedef struct {
  uint8_t int_anymo_x_en:1;
  uint8_t int_anymo_y_en:1;
  uint8_t int_anymo_z_en:1;
  uint8_t :1;
  uint8_t int_d_tap_en:1;
  uint8_t int_s_tap_en:1;
  uint8_t int_orient_en:1;
  uint8_t int_flat_en:1;
} bmi160_reg_int_en_0_t;

typedef struct {
  uint8_t int_highg_x_en:1;
  uint8_t int_highg_y_en:1;
  uint8_t int_highg_z_en:1;
  uint8_t int_low_en:1;
  uint8_t int_drdy_en:1;
  uint8_t int_ffull_en:1;
  uint8_t int_fwm_en:1;
  uint8_t :1;
} bmi160_reg_int_en_1_t;

typedef struct {
  uint8_t int_nomox_en:1;
  uint8_t int_nomoy_en:1;
  uint8_t int_nomoz_en:1;
  uint8_t int_step_det_en:1;
  uint8_t :4;
} bmi160_reg_int_en_2_t;

typedef struct {
  uint8_t int1_edge_ctrl:1;
  uint8_t int1_lvl:1;
  uint8_t int1_od:1;
  uint8_t int1_output_en:1;
  uint8_t int2_edge_ctrl:1;
  uint8_t int2_lvl:1;
  uint8_t int2_od:1;
  uint8_t int2_output_en:1;
} bmi160_reg_int_out_ctrl_t;

typedef struct {
  uint8_t int_latch:4;
  uint8_t int1_input_en:1;
  uint8_t int2_input_en:1;
  uint8_t :2;
} bmi160_reg_int_latch_t;

typedef struct {
  uint8_t int1_logw_step:1;
  uint8_t int1_highg:1;
  uint8_t int1_anymotion:1;
  uint8_t int1_nomotion:1;
  uint8_t int1_d_tap:1;
  uint8_t int1_s_tap:1;
  uint8_t int1_orient:1;
  uint8_t int1_flat:1;
} bmi160_reg_int_map_0_t;

typedef struct {
  uint8_t int2_pmu_trig:1;
  uint8_t int2_ffull:1;
  uint8_t int2_fwm:1;
  uint8_t int2_drdy:1;
  uint8_t int1_pmu_trig:1;
  uint8_t int1_ffull:1;
  uint8_t int1_fwm:1;
  uint8_t int1_drdy:1;
} bmi160_reg_int_map_1_t;

typedef struct {
  uint8_t int2_lowg_step:1;
  uint8_t int2_highg:1;
  uint8_t int2_anymotion:1;
  uint8_t int2_nomotion:1;
  uint8_t int2_d_tap:1;
  uint8_t int2_s_tap:1;
  uint8_t int2_orient:1;
  uint8_t int2_flat:1;
} bmi160_reg_int_map_2_t;

typedef struct {
  uint8_t :3;
  uint8_t int_tap_src:1;
  uint8_t :3;
  uint8_t int_low_high_src:1;
} bmi160_reg_int_data_0_t;

typedef struct {
  uint8_t :7;
  uint8_t int_motion_src:1;
} bmi160_reg_int_data_1_t;

typedef struct {
  uint8_t int_low_dur:8;
} bmi160_reg_int_lowhigh_0_t;

typedef struct {
  uint8_t int_low_th:8;
} bmi160_reg_int_lowhigh_1_t;

typedef struct {
  uint8_t int_low_hy:2;
  uint8_t int_low_mode:1;
  uint8_t :3;
  uint8_t int_high_hy:2;
} bmi160_reg_int_lowhigh_2_t;

typedef struct {
  uint8_t int_high_dur:8;
} bmi160_reg_int_lowhigh_3_t;

typedef struct {
  uint8_t int_high_th:8;
} bmi160_reg_int_lowhigh_4_t;

typedef struct {
  uint8_t int_anym_dur:2;
  uint8_t int_slo_nomo_dur:6;
} bmi160_reg_int_motion_0_t;

typedef struct {
  uint8_t int_anymo_th:8;
} bmi160_reg_int_motion_1_t;

typedef struct {
  uint8_t int_slo_nomo_th:8;
} bmi160_reg_int_motion_2_t;

typedef struct {
  uint8_t int_slo_nomo_sel:1;
  uint8_t int_sig_mot_sel:1;
  uint8_t int_sig_mot_skip:2;
  uint8_t int_sig_mot_proof:2;
  uint8_t :2;
} bmi160_reg_int_motion_3_t;

typedef struct {
  uint8_t int_tap_dur:3;
  uint8_t :3;
  uint8_t int_tap_shock:1;
  uint8_t int_tap_quiet:1;
} bmi160_reg_int_tap_0_t;

typedef struct {
  uint8_t int_tap_th:5;
  uint8_t :3;
} bmi160_reg_int_tap_1_t;

typedef struct {
  uint8_t int_orient_mode:2;
  uint8_t int_orient_blocking:2;
  uint8_t int_orient_hy:4;
} bmi160_reg_int_orient_0_t;

typedef struct {
  uint8_t int_orient_theta:6;
  uint8_t int_orient_ud_en:2;
  uint8_t int_orient_axes_ex:2;
} bmi160_reg_int_orient_1_t;

typedef struct {
  uint8_t int_flat_theta:6;
  uint8_t :2;
} bmi160_reg_int_flat_0_t;

typedef struct {
  uint8_t int_flat_hy:4;
  uint8_t int_flag_hold:2;
  uint8_t :2;
} bmi160_reg_int_flat_1_t;

typedef struct {
  uint8_t foc_acc_z:2;
  uint8_t foc_acc_y:2;
  uint8_t foc_acc_x:2;
  uint8_t foc_gyr_en:1;
  uint8_t :1;
} bmi160_reg_foc_conf_t;

typedef struct {
  uint8_t :1;
  uint8_t nvm_prog_en:1;
  uint8_t :6;
} bmi160_reg_conf_t;

typedef struct {
  uint8_t spi3:1;
  uint8_t :3;
  uint8_t if_mode:2;
  uint8_t :2;
} bmi160_reg_if_conf_t;

typedef struct {
  uint8_t gyr_sleep_trigger:3;
  uint8_t gyr_wakeup_trigger:2;
  uint8_t gyr_sleep_state:1;
  uint8_t wakeup_int:1;
  uint8_t :1;
} bmi160_reg_pmu_trigger_t;

typedef struct {
  uint8_t acc_self_test_enable:2;
  uint8_t acc_self_test_sign:1;
  uint8_t acc_self_test_amp:1;
  uint8_t gyr_self_test_enable:1;
  uint8_t :3;
} bmi160_reg_self_test_t;

typedef struct {
  uint8_t spi_en:1;
  uint8_t i2c_wdt_sel:1;
  uint8_t i2c_wdt_en:1;
  uint8_t u_spare_0:1;
  uint8_t :4;
} bmi160_reg_nv_conf_t;

typedef struct {
  int8_t off_acc_x;
  int8_t off_acc_y;
  int8_t off_acc_z;
  uint8_t off_gyr_x_7_0;
  uint8_t off_gyr_y_7_0;
  uint8_t off_gyr_z_7_0;
  uint8_t off_gyr_x_9_8:2;
  uint8_t off_gyr_y_9_8:2;
  uint8_t off_gyr_z_9_8:2;
  uint8_t acc_off_en:1;
  uint8_t gyr_off_en:1;
} bmi160_reg_offset_t;

typedef struct {
  uint16_t step_cnt;
} bmi160_reg_step_cnt_t;

typedef struct {
  uint8_t steptime_min:3;
  uint8_t min_threshold:2;
  uint8_t alpha:3;
} bmi160_reg_step_conf_0_t;

typedef struct {
  uint8_t min_step_buf:3;
  uint8_t step_cnt_en:1;
  uint8_t reserved:4;
} bmi160_reg_step_conf_1_t;

typedef struct {
  uint8_t cmd;
} bmi160_reg_cmd_t;

typedef struct {
  bmi160_reg_int_status_0_t int_status_0;
  bmi160_reg_int_status_1_t int_status_1;
  bmi160_reg_int_status_2_t int_status_2;
  bmi160_reg_int_status_3_t int_status_3;
} bmi160_reg_int_status_t;

typedef struct {
  bmi160_reg_acc_conf_t acc_conf;
  bmi160_reg_acc_range_t acc_range;
} bmi160_regs_acc_t;

typedef struct {
  bmi160_reg_gyr_conf_t gyr_conf;
  bmi160_reg_gyr_range_t gyr_range;
} bmi160_regs_gyr_t;

typedef struct {
  bmi160_reg_int_en_0_t int_en_0;
  bmi160_reg_int_en_1_t int_en_1;
  bmi160_reg_int_en_2_t int_en_2;
} bmi160_reg_int_en_t;

typedef struct {
  bmi160_reg_int_map_0_t int_map_0;
  bmi160_reg_int_map_1_t int_map_1;
  bmi160_reg_int_map_2_t int_map_2;
} bmi160_reg_int_map_t;

typedef struct {
  bmi160_reg_int_lowhigh_0_t int_lowhigh_0;
  bmi160_reg_int_lowhigh_1_t int_lowhigh_1;
  bmi160_reg_int_lowhigh_2_t int_lowhigh_2;
  bmi160_reg_int_lowhigh_3_t int_lowhigh_3;
  bmi160_reg_int_lowhigh_4_t int_lowhigh_4;
} bmi160_reg_int_lowhigh_t;

typedef struct {
  bmi160_reg_int_motion_0_t int_motion_0;
  bmi160_reg_int_motion_1_t int_motion_1;
  bmi160_reg_int_motion_2_t int_motion_2;
  bmi160_reg_int_motion_3_t int_motion_3;
} bmi160_reg_int_motion_t;

typedef struct {
  bmi160_reg_int_tap_0_t int_tap_0;
  bmi160_reg_int_tap_1_t int_tap_1;
} bmi160_reg_int_tap_t;

typedef struct {
  bmi160_reg_int_orient_0_t int_orient_0;
  bmi160_reg_int_orient_1_t int_orient_1;
} bmi160_reg_int_orient_t;

typedef struct {
  bmi160_reg_int_flat_0_t int_flat_0;
  bmi160_reg_int_flat_1_t int_flat_1;
} bmi160_reg_int_flat_t;

typedef struct {
  bmi160_reg_step_conf_0_t step_conf_0;
  bmi160_reg_step_conf_1_t step_conf_1;
} bmi160_reg_step_conf_t;

/**************************************************/
/**\name    FIFO FRAME COUNT DEFINITION           */
/*************************************************/
#define FIFO_FRAME                      1024
#define FIFO_CONFIG_CHECK1              0x00
#define FIFO_CONFIG_CHECK2              0x80

/**************************************************/
/**\name    ACCEL RANGE          */
/*************************************************/
#define BMI160_ACCEL_RANGE_2G           0x03
#define BMI160_ACCEL_RANGE_4G           0x05
#define BMI160_ACCEL_RANGE_8G           0x08
#define BMI160_ACCEL_RANGE_16G          0x0C

/**************************************************/
/**\name    ACCEL ODR          */
/*************************************************/
#define BMI160_ACCEL_OUTPUT_DATA_RATE_RESERVED       0x00
#define BMI160_ACCEL_OUTPUT_DATA_RATE_0_78HZ         0x01
#define BMI160_ACCEL_OUTPUT_DATA_RATE_1_56HZ         0x02
#define BMI160_ACCEL_OUTPUT_DATA_RATE_3_12HZ         0x03
#define BMI160_ACCEL_OUTPUT_DATA_RATE_6_25HZ         0x04
#define BMI160_ACCEL_OUTPUT_DATA_RATE_12_5HZ         0x05
#define BMI160_ACCEL_OUTPUT_DATA_RATE_25HZ           0x06
#define BMI160_ACCEL_OUTPUT_DATA_RATE_50HZ           0x07
#define BMI160_ACCEL_OUTPUT_DATA_RATE_100HZ          0x08
#define BMI160_ACCEL_OUTPUT_DATA_RATE_200HZ          0x09
#define BMI160_ACCEL_OUTPUT_DATA_RATE_400HZ          0x0A
#define BMI160_ACCEL_OUTPUT_DATA_RATE_800HZ          0x0B
#define BMI160_ACCEL_OUTPUT_DATA_RATE_1600HZ         0x0C
#define BMI160_ACCEL_OUTPUT_DATA_RATE_RESERVED0      0x0D
#define BMI160_ACCEL_OUTPUT_DATA_RATE_RESERVED1      0x0E
#define BMI160_ACCEL_OUTPUT_DATA_RATE_RESERVED2      0x0F

/**************************************************/
/**\name    ACCEL BANDWIDTH PARAMETER         */
/*************************************************/
#define BMI160_ACCEL_OSR4_AVG1            0x00
#define BMI160_ACCEL_OSR2_AVG2            0x01
#define BMI160_ACCEL_NORMAL_AVG4          0x02
#define BMI160_ACCEL_CIC_AVG8             0x03
#define BMI160_ACCEL_RES_AVG16            0x04
#define BMI160_ACCEL_RES_AVG32            0x05
#define BMI160_ACCEL_RES_AVG64            0x06
#define BMI160_ACCEL_RES_AVG128           0x07

/**************************************************/
/**\name    GYRO ODR         */
/*************************************************/
#define BMI160_GYRO_OUTPUT_DATA_RATE_RESERVED        0x00
#define BMI160_GYRO_OUTPUT_DATA_RATE_25HZ            0x06
#define BMI160_GYRO_OUTPUT_DATA_RATE_50HZ            0x07
#define BMI160_GYRO_OUTPUT_DATA_RATE_100HZ           0x08
#define BMI160_GYRO_OUTPUT_DATA_RATE_200HZ           0x09
#define BMI160_GYRO_OUTPUT_DATA_RATE_400HZ           0x0A
#define BMI160_GYRO_OUTPUT_DATA_RATE_800HZ           0x0B
#define BMI160_GYRO_OUTPUT_DATA_RATE_1600HZ          0x0C
#define BMI160_GYRO_OUTPUT_DATA_RATE_3200HZ          0x0D

/**************************************************/
/**\name    GYRO BANDWIDTH PARAMETER         */
/*************************************************/
#define BMI160_GYRO_OSR4_MODE          0x00
#define BMI160_GYRO_OSR2_MODE          0x01
#define BMI160_GYRO_NORMAL_MODE        0x02
#define BMI160_GYRO_CIC_MODE           0x03

/**************************************************/
/**\name    GYROSCOPE RANGE PARAMETER         */
/*************************************************/
#define BMI160_GYRO_RANGE_2000_DEG_SEC   0x00
#define BMI160_GYRO_RANGE_1000_DEG_SEC   0x01
#define BMI160_GYRO_RANGE_500_DEG_SEC    0x02
#define BMI160_GYRO_RANGE_250_DEG_SEC    0x03
#define BMI160_GYRO_RANGE_125_DEG_SEC    0x04

/**************************************************/
/**\name    MAG ODR         */
/*************************************************/
#define BMI160_MAG_OUTPUT_DATA_RATE_RESERVED       0x00
#define BMI160_MAG_OUTPUT_DATA_RATE_0_78HZ         0x01
#define BMI160_MAG_OUTPUT_DATA_RATE_1_56HZ         0x02
#define BMI160_MAG_OUTPUT_DATA_RATE_3_12HZ         0x03
#define BMI160_MAG_OUTPUT_DATA_RATE_6_25HZ         0x04
#define BMI160_MAG_OUTPUT_DATA_RATE_12_5HZ         0x05
#define BMI160_MAG_OUTPUT_DATA_RATE_25HZ           0x06
#define BMI160_MAG_OUTPUT_DATA_RATE_50HZ           0x07
#define BMI160_MAG_OUTPUT_DATA_RATE_100HZ          0x08
#define BMI160_MAG_OUTPUT_DATA_RATE_200HZ          0x09
#define BMI160_MAG_OUTPUT_DATA_RATE_400HZ          0x0A
#define BMI160_MAG_OUTPUT_DATA_RATE_800HZ          0x0B
#define BMI160_MAG_OUTPUT_DATA_RATE_1600HZ         0x0C
#define BMI160_MAG_OUTPUT_DATA_RATE_RESERVED0      0x0D
#define BMI160_MAG_OUTPUT_DATA_RATE_RESERVED1      0x0E
#define BMI160_MAG_OUTPUT_DATA_RATE_RESERVED2      0x0F

/**************************************************/
/**\name    ENABLE/DISABLE SELECTIONS        */
/*************************************************/

/* Enable accel and gyro offset */
#define ACCEL_OFFSET_ENABLE             0x01
#define GYRO_OFFSET_ENABLE              0x01

/* command register definition */
#define START_FOC_ACCEL_GYRO            0x03

 /* INT ENABLE 1 */
#define BMI160_ANY_MOTION_X_ENABLE      0
#define BMI160_ANY_MOTION_Y_ENABLE      1
#define BMI160_ANY_MOTION_Z_ENABLE      2
#define BMI160_DOUBLE_TAP_ENABLE        4
#define BMI160_SINGLE_TAP_ENABLE        5
#define BMI160_ORIENT_ENABLE            6
#define BMI160_FLAT_ENABLE              7

/* INT ENABLE 1 */
#define BMI160_HIGH_G_X_ENABLE          0
#define BMI160_HIGH_G_Y_ENABLE          1
#define BMI160_HIGH_G_Z_ENABLE          2
#define BMI160_LOW_G_ENABLE             3
#define BMI160_DATA_RDY_ENABLE          4
#define BMI160_FIFO_FULL_ENABLE         5
#define BMI160_FIFO_WM_ENABLE           6

/* INT ENABLE 2 */
#define BMI160_NOMOTION_X_ENABLE        0
#define BMI160_NOMOTION_Y_ENABLE        1
#define BMI160_NOMOTION_Z_ENABLE        2

/* FOC axis selection for accel*/
#define FOC_X_AXIS                      0
#define FOC_Y_AXIS                      1
#define FOC_Z_AXIS                      2

/* IN OUT CONTROL */
#define BMI160_INTR1_EDGE_CTRL          0
#define BMI160_INTR2_EDGE_CTRL          1
#define BMI160_INTR1_LEVEL              0
#define BMI160_INTR2_LEVEL              1
#define BMI160_INTR1_OUTPUT_TYPE        0
#define BMI160_INTR2_OUTPUT_TYPE        1
#define BMI160_INTR1_OUTPUT_ENABLE      0
#define BMI160_INTR2_OUTPUT_ENABLE      1

#define BMI160_INTR1_INPUT_ENABLE       0
#define BMI160_INTR2_INPUT_ENABLE       1

/*  INTERRUPT MAPS    */
#define BMI160_INTR1_MAP_LOW_G          0
#define BMI160_INTR2_MAP_LOW_G          1
#define BMI160_INTR1_MAP_HIGH_G         0
#define BMI160_INTR2_MAP_HIGH_G         1
#define BMI160_INTR1_MAP_ANY_MOTION     0
#define BMI160_INTR2_MAP_ANY_MOTION     1
#define BMI160_INTR1_MAP_NOMO           0
#define BMI160_INTR2_MAP_NOMO           1
#define BMI160_INTR1_MAP_DOUBLE_TAP     0
#define BMI160_INTR2_MAP_DOUBLE_TAP     1
#define BMI160_INTR1_MAP_SINGLE_TAP     0
#define BMI160_INTR2_MAP_SINGLE_TAP     1
#define BMI160_INTR1_MAP_ORIENT         0
#define BMI160_INTR2_MAP_ORIENT         1
#define BMI160_INTR1_MAP_FLAT           0
#define BMI160_INTR2_MAP_FLAT           1
#define BMI160_INTR1_MAP_DATA_RDY       0
#define BMI160_INTR2_MAP_DATA_RDY       1
#define BMI160_INTR1_MAP_FIFO_WM        0
#define BMI160_INTR2_MAP_FIFO_WM        1
#define BMI160_INTR1_MAP_FIFO_FULL      0
#define BMI160_INTR2_MAP_FIFO_FULL      1
#define BMI160_INTR1_MAP_PMUTRIG        0
#define BMI160_INTR2_MAP_PMUTRIG        1

/* Interrupt mapping*/
#define BMI160_MAP_INTR1                0
#define BMI160_MAP_INTR2                1

/**************************************************/
/**\name     TAP DURATION         */
/*************************************************/
#define BMI160_TAP_DURN_50MS            0x00
#define BMI160_TAP_DURN_100MS           0x01
#define BMI160_TAP_DURN_150MS           0x02
#define BMI160_TAP_DURN_200MS           0x03
#define BMI160_TAP_DURN_250MS           0x04
#define BMI160_TAP_DURN_375MS           0x05
#define BMI160_TAP_DURN_500MS           0x06
#define BMI160_TAP_DURN_700MS           0x07

/**************************************************/
/**\name    TAP SHOCK         */
/*************************************************/
#define BMI160_TAP_SHOCK_50MS           0x00
#define BMI160_TAP_SHOCK_75MS           0x01

/**************************************************/
/**\name    TAP QUIET        */
/*************************************************/
#define BMI160_TAP_QUIET_30MS           0x00
#define BMI160_TAP_QUIET_20MS           0x01

/**************************************************/
/**\name    STEP DETECTION SELECTION MODES      */
/*************************************************/
#define BMI160_STEP_NORMAL_MODE         0
#define BMI160_STEP_SENSITIVE_MODE      1
#define BMI160_STEP_ROBUST_MODE         2

/**************************************************/
/**\name    STEP CONFIGURATION SELECT MODE    */
/*************************************************/
#define STEP_CONFIG_NORMAL              0x315
#define STEP_CONFIG_SENSITIVE           0x2D
#define STEP_CONFIG_ROBUST              0x71D

/**************************************************/
/**\name    BMM150 TRIM DATA DEFINITIONS      */
/*************************************************/
#define BMI160_MAG_DIG_X1                      0x5D
#define BMI160_MAG_DIG_Y1                      0x5E
#define BMI160_MAG_DIG_Z4_LSB                  0x62
#define BMI160_MAG_DIG_Z4_MSB                  0x63
#define BMI160_MAG_DIG_X2                      0x64
#define BMI160_MAG_DIG_Y2                      0x65
#define BMI160_MAG_DIG_Z2_LSB                  0x68
#define BMI160_MAG_DIG_Z2_MSB                  0x69
#define BMI160_MAG_DIG_Z1_LSB                  0x6A
#define BMI160_MAG_DIG_Z1_MSB                  0x6B
#define BMI160_MAG_DIG_XYZ1_LSB                0x6C
#define BMI160_MAG_DIG_XYZ1_MSB                0x6D
#define BMI160_MAG_DIG_Z3_LSB                  0x6E
#define BMI160_MAG_DIG_Z3_MSB                  0x6F
#define BMI160_MAG_DIG_XY2                     0x70
#define BMI160_MAG_DIG_XY1                     0x71

/**************************************************/
/**\name    BMM150 PRE-SET MODE DEFINITIONS     */
/*************************************************/
#define BMI160_MAG_PRESETMODE_LOWPOWER                  1
#define BMI160_MAG_PRESETMODE_REGULAR                   2
#define BMI160_MAG_PRESETMODE_HIGHACCURACY              3
#define BMI160_MAG_PRESETMODE_ENHANCED                  4

/**************************************************/
/**\name    BMM150 PRESET MODES - DATA RATES    */
/*************************************************/
#define BMI160_MAG_LOWPOWER_DR                       0x02
#define BMI160_MAG_REGULAR_DR                        0x02
#define BMI160_MAG_HIGHACCURACY_DR                   0x2A
#define BMI160_MAG_ENHANCED_DR                       0x02

/**************************************************/
/**\name    BMM150 PRESET MODES - REPETITIONS-XY RATES */
/*************************************************/
#define BMI160_MAG_LOWPOWER_REPXY                     1
#define BMI160_MAG_REGULAR_REPXY                      4
#define BMI160_MAG_HIGHACCURACY_REPXY                23
#define BMI160_MAG_ENHANCED_REPXY                     7

/**************************************************/
/**\name    BMM150 PRESET MODES - REPETITIONS-Z RATES */
/*************************************************/
#define BMI160_MAG_LOWPOWER_REPZ                      2
#define BMI160_MAG_REGULAR_REPZ                      14
#define BMI160_MAG_HIGHACCURACY_REPZ                 82
#define BMI160_MAG_ENHANCED_REPZ                     26

/**************************************************/
/**\name    USED FOR MAG OVERFLOW CHECK FOR BMM150  */
/*************************************************/
#define BMI160_MAG_OVERFLOW_OUTPUT            ((int16_t)-32768)
#define BMI160_MAG_OVERFLOW_OUTPUT_S32        ((int32_t)(-2147483647-1))
#define BMI160_MAG_NEGATIVE_SATURATION_Z      ((int16_t)-32767)
#define BMI160_MAG_POSITIVE_SATURATION_Z      ((uint16_t)32767)
#define BMI160_MAG_FLIP_OVERFLOW_ADCVAL       ((int16_t)-4096)
#define BMI160_MAG_HALL_OVERFLOW_ADCVAL       ((int16_t)-16384)

/**************************************************/
/**\name    BMM150 REGISTER DEFINITION */
/*************************************************/
#define BMI160_BMM150_POWE_CONTROL_REG    0x4B
#define BMI160_BMM150_POWE_MODE_REG       0x4C
#define BMI160_BMM150_DATA_REG            0x42
#define BMI160_BMM150_XY_REP              0x51
#define BMI160_BMM150_Z_REP               0x52

/**************************************************/
/**\name    AKM COMPENSATING DATA REGISTERS     */
/*************************************************/
#define BMI160_BST_AKM_ASAX               0x60
#define BMI160_BST_AKM_ASAY               0x61
#define BMI160_BST_AKM_ASAZ               0x62

/**************************************************/
/**\name    AKM POWER MODE SELECTION     */
/*************************************************/
#define AKM_POWER_DOWN_MODE               0
#define AKM_SINGLE_MEAS_MODE              1
#define FUSE_ROM_MODE                     2

/**************************************************/
/**\name    SECONDARY_MAG POWER MODE SELECTION    */
/*************************************************/
#define BMI160_MAG_FORCE_MODE             0
#define BMI160_MAG_SUSPEND_MODE           1

/**************************************************/
/**\name    MAG POWER MODE SELECTION    */
/*************************************************/
#define FORCE_MODE                        0
#define SUSPEND_MODE                      1
#define NORMAL_MODE                       2
#define MAG_SUSPEND_MODE                  1

/* FIFO definitions*/
#define FIFO_HEAD_A                       0x84
#define FIFO_HEAD_G                       0x88
#define FIFO_HEAD_M                       0x90

#define FIFO_HEAD_G_A                     0x8C
#define FIFO_HEAD_M_A                     0x94
#define FIFO_HEAD_M_G                     0x98

#define FIFO_HEAD_M_G_A                   0x9C

#define FIFO_HEAD_SENSOR_TIME             0x44
#define FIFO_HEAD_SKIP_FRAME              0x40
#define FIFO_HEAD_OVER_READ_LSB           0x80
#define FIFO_HEAD_OVER_READ_MSB           0x00


/* FIFO 1024 byte, max fifo frame count not over 150 */
#define FIFO_FRAME_CNT                    146

#define FIFO_OVER_READ_RETURN             ((int8_t)-10)
#define FIFO_SENSORTIME_RETURN            ((int8_t)-9)
#define FIFO_SKIP_OVER_LEN                ((int8_t)-8)
#define FIFO_M_G_A_OVER_LEN               ((int8_t)-7)
#define FIFO_M_G_OVER_LEN                 ((int8_t)-6)
#define FIFO_M_A_OVER_LEN                 ((int8_t)-5)
#define FIFO_G_A_OVER_LEN                 ((int8_t)-4)
#define FIFO_M_OVER_LEN                   ((int8_t)-3)
#define FIFO_G_OVER_LEN                   ((int8_t)-2)
#define FIFO_A_OVER_LEN                   ((int8_t)-1)

/**************************************************/
/**\name    ACCEL POWER MODE    */
/*************************************************/
#define ACCEL_MODE_NORMAL                 0x11
#define ACCEL_LOWPOWER                    0x12
#define ACCEL_SUSPEND                     0x10

/**************************************************/
/**\name    GYRO POWER MODE    */
/*************************************************/
#define GYRO_MODE_SUSPEND                 0x14
#define GYRO_MODE_NORMAL                  0x15
#define GYRO_MODE_FASTSTARTUP             0x17

/**************************************************/
/**\name    MAG POWER MODE    */
/*************************************************/
#define MAG_MODE_SUSPEND                  0x18
#define MAG_MODE_NORMAL                   0x19
#define MAG_MODE_LOWPOWER                 0x1A

#define CMD_SOFT_RESET                    0xB6
#define CMD_FIFO_FLUSH                    0xB0
#define CMD_INT_RESET                     0xB1

/**************************************************/
/**\name    ENABLE/DISABLE BIT VALUES    */
/*************************************************/
#define BMI160_ENABLE                     0x01
#define BMI160_DISABLE                    0x00

/**************************************************/
/**\name    INTERRUPT EDGE TRIGGER ENABLE    */
/*************************************************/
#define BMI160_EDGE                       0x01
#define BMI160_LEVEL                      0x00

/**************************************************/
/**\name    INTERRUPT LEVEL ENABLE    */
/*************************************************/
#define BMI160_LEVEL_LOW                  0x00
#define BMI160_LEVEL_HIGH                 0x01

/**************************************************/
/**\name    INTERRUPT OUTPUT ENABLE    */
/*************************************************/
#define BMI160_OPEN_DRAIN                 0x01
#define BMI160_PUSH_PULL                  0x00

/* interrupt output enable*/
#define BMI160_INPUT                      0x01
#define BMI160_OUTPUT                     0x00

/**************************************************/
/**\name    INTERRUPT TAP SOURCE ENABLE    */
/*************************************************/
#define FILTER_DATA                       0x00
#define UNFILTER_DATA                     0x01

/**************************************************/
/**\name    SLOW MOTION/ NO MOTION SELECT   */
/*************************************************/
#define SLOW_MOTION                       0x00
#define NO_MOTION                         0x01

/**************************************************/
/**\name    SIGNIFICANT MOTION SELECTION   */
/*************************************************/
#define ANY_MOTION                        0x00
#define SIGNIFICANT_MOTION                0x01

/**************************************************/
/**\name    LATCH DURATION   */
/*************************************************/
#define BMI160_LATCH_DUR_NONE             0x00
#define BMI160_LATCH_DUR_312_5_MICRO_SEC  0x01
#define BMI160_LATCH_DUR_625_MICRO_SEC    0x02
#define BMI160_LATCH_DUR_1_25_MILLI_SEC   0x03
#define BMI160_LATCH_DUR_2_5_MILLI_SEC    0x04
#define BMI160_LATCH_DUR_5_MILLI_SEC      0x05
#define BMI160_LATCH_DUR_10_MILLI_SEC     0x06
#define BMI160_LATCH_DUR_20_MILLI_SEC     0x07
#define BMI160_LATCH_DUR_40_MILLI_SEC     0x08
#define BMI160_LATCH_DUR_80_MILLI_SEC     0x09
#define BMI160_LATCH_DUR_160_MILLI_SEC    0x0A
#define BMI160_LATCH_DUR_320_MILLI_SEC    0x0B
#define BMI160_LATCH_DUR_640_MILLI_SEC    0x0C
#define BMI160_LATCH_DUR_1_28_SEC         0x0D
#define BMI160_LATCH_DUR_2_56_SEC         0x0E
#define BMI160_LATCHED                    0x0F

/**************************************************/
/**\name    GYRO OFFSET MASK DEFINITION   */
/*************************************************/
#define BMI160_GYRO_MANUAL_OFFSET_0_7     0x00FF
#define BMI160_GYRO_MANUAL_OFFSET_8_9     0x0300

/**************************************************/
/**\name    STEP CONFIGURATION MASK DEFINITION   */
/*************************************************/
#define BMI160_STEP_CONFIG_0_7            0x00FF
#define BMI160_STEP_CONFIG_8_10           0x0700
#define BMI160_STEP_CONFIG_11_14          0xF000

/**************************************************/
/**\name    MAG INIT DEFINITION  */
/*************************************************/
#define BMI160_COMMAND_REG_ONE            0x37
#define BMI160_COMMAND_REG_TWO            0x9A
#define BMI160_COMMAND_REG_THREE          0xC0
#define RESET_STEP_COUNTER                0xB2

#endif // BMI160_H__
