#ifndef __MMA8452Q_H__
#define __MMA8452Q_H__
/**
 * mma8452q.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/1/14.
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
#include <stdbool.h>

// Sensor I2C address
#define MMA8452Q_I2C_ADDRESS          	    0x1C

#define MMA8452Q_INT_PIN										6

// MMA8452Q register addresses
#define MMA8452Q_REG_ADDR_STATUS            0x00 // R
#define MMA8452Q_REG_ADDR_XOUT_H            0x01 // R
#define MMA8452Q_REG_ADDR_XOUT_L            0x02 // R
#define MMA8452Q_REG_ADDR_YOUT_H            0x03 // R
#define MMA8452Q_REG_ADDR_YOUT_L            0x04 // R
#define MMA8452Q_REG_ADDR_ZOUT_H            0x05 // R
#define MMA8452Q_REG_ADDR_ZOUT_L            0x06 // R

#define MMA8452Q_REG_ADDR_SYSMOD            0x0B // R 00 Standby, 01 Wake, 10 sleep
#define MMA8452Q_REG_ADDR_INT_SRC           0x0C // R
#define MMA8452Q_REG_ADDR_WHO_AM_I          0x0D // R 0x2A

#define MMA8452Q_REG_ADDR_XYZ_DATA_CFG      0x0E // R/W
#define MMA8452Q_REG_ADDR_HP_FILTER_CUTOFF  0x0F // R/W

#define MMA8452Q_REG_ADDR_PL_STATUS         0x10 // R
#define MMA8452Q_REG_ADDR_PL_CFG            0x11 // R/W
#define MMA8452Q_REG_ADDR_PL_COUNT          0x12 // R/W
#define MMA8452Q_REG_ADDR_PL_BF_ZCOMP       0x13 // R
#define MMA8452Q_REG_ADDR_P_L_THS_REG       0x14 // R

#define MMA8452Q_REG_ADDR_FF_MT_CFG         0x15 // R/W
#define MMA8452Q_REG_ADDR_FF_MT_SRC         0x16 // R
#define MMA8452Q_REG_ADDR_FF_MT_THS         0x17 // R/W
#define MMA8452Q_REG_ADDR_FF_MT_COUNT       0x18 // R/W

#define MMA8452Q_REG_ADDR_TRANSIENT_CFG     0x1D // R/W
#define MMA8452Q_REG_ADDR_TRANSIENT_SRC     0x1E // R
#define MMA8452Q_REG_ADDR_TRANSIENT_THS     0x1F // R/W
#define MMA8452Q_REG_ADDR_TRANSIENT_COUNT   0x20 // R/W

#define MMA8452Q_REG_ADDR_PULSE_CFG         0x21 // R/W
#define MMA8452Q_REG_ADDR_PULSE_SRC         0x22 // R
#define MMA8452Q_REG_ADDR_PULSE_THSX        0x23 // R/W
#define MMA8452Q_REG_ADDR_PULSE_THSY        0x24 // R/W
#define MMA8452Q_REG_ADDR_PULSE_THSZ        0x25 // R/W
#define MMA8452Q_REG_ADDR_PULSE_TMLT        0x26 // R/W
#define MMA8452Q_REG_ADDR_PULSE_LTCY        0x27 // R/W
#define MMA8452Q_REG_ADDR_PULSE_WIND        0x28 // R/W

#define MMA8452Q_REG_ADDR_ASLP_COUNT        0x29 // R/W

#define MMA8452Q_REG_ADDR_OFF_X             0x2F // R/W
#define MMA8452Q_REG_ADDR_OFF_Y             0x30 // R/W
#define MMA8452Q_REG_ADDR_OFF_Z             0x31 // R/W

#define MMA8452Q_REG_ADDR_CTRL_REG1         0x2A // R/W
#define MMA8452Q_REG_ADDR_CTRL_REG2         0x2B // R/W
#define MMA8452Q_REG_ADDR_CTRL_REG3         0x2C // R/W
#define MMA8452Q_REG_ADDR_CTRL_REG4         0x2D // R/W
#define MMA8452Q_REG_ADDR_CTRL_REG5         0x2E // R/W

// Select register valies
#define MMA8452Q_REG_VAL_WHO_AM_I           0x2A // R 

typedef enum {
	MMA8452Q_ASLP_RATE_50HZ = 0, 
	MMA8452Q_ASLP_RATE_12_5HZ, 
	MMA8452Q_ASLP_RATE_6_25HZ, 
	MMA8452Q_ASLP_RATE_1_56HZ
} mma8452q_aslp_rate_t;

typedef struct {
	uint8_t		active:1;
	uint8_t		f_read:1;
	uint8_t		lnoise:1;
	uint8_t		dr:3;
	uint8_t		aslp_rate:2;
} mma8452q_ctrl_reg1_t;

typedef struct {
	uint8_t		mods:2;
	uint8_t		slpe:1;
	uint8_t		smods:2;
	uint8_t		:1;
	uint8_t		rst:1;
	uint8_t		st:1;
} mma8452q_ctrl_reg2_t;

typedef struct {
	uint8_t 	pp_od:1;
	uint8_t		ipol:1;
	uint8_t		:1;
	uint8_t		wake_ff_mt:1;
	uint8_t		wake_pulse:1;
	uint8_t		wake_lndprt:1;
	uint8_t		wake_trans:1;
	uint8_t		:1;
} mma8452q_ctrl_reg3_t;

typedef struct {
	uint8_t		int_en_drdy:1;
	uint8_t		:1;
	uint8_t		int_en_ff_mt:1;
	uint8_t		int_en_pulse:1;
	uint8_t		int_en_lndprt:1;
	uint8_t		int_en_trans:1;
	uint8_t		:1;
	uint8_t		int_en_aslp:1;
} mma8452q_ctrl_reg4_t;

typedef struct {
	uint8_t		int_cfg_drdy:1;
	uint8_t		:1;
	uint8_t		int_cfg_ff_mt:1;
	uint8_t		int_cfg_pulse:1;
	uint8_t		int_cfg_lndprt:1;
	uint8_t		int_cfg_trans:1;
	uint8_t		:1;
	uint8_t		int_cfg_aslp:1;
} mma8452q_ctrl_reg5_t;
	
typedef struct {
	mma8452q_ctrl_reg1_t	ctrl_reg1;
	mma8452q_ctrl_reg2_t	ctrl_reg2;
	mma8452q_ctrl_reg3_t	ctrl_reg3;
	mma8452q_ctrl_reg4_t	ctrl_reg4;
	mma8452q_ctrl_reg5_t	ctrl_reg5;
} mma8452q_ctrl_regs_t;

typedef struct {
	uint8_t		fs:2;
	uint8_t		:2;
	uint8_t		hpf_out:1;
	uint8_t		:3;
} mma8452q_xyz_data_cfg_t;

typedef struct {
	uint8_t		sel:2;
	uint8_t		:2;
	uint8_t		pulselpfen:1;
	uint8_t		pulsehpfen:1;
	uint8_t		:2;
} mma8452q_hp_filter_cutoff_t;

typedef struct {
	uint8_t		aslp_count;
} mma8452q_aslp_count_reg_t;

typedef struct {
	mma8452q_xyz_data_cfg_t				xyz_data_cfg;
	mma8452q_hp_filter_cutoff_t		hp_filter_cutoff;
	mma8452q_ctrl_reg1_t					ctrl_reg1;
	mma8452q_ctrl_reg2_t					ctrl_reg2;
	mma8452q_aslp_count_reg_t			aslp_count;
} mma8452q_data_regs_t;

typedef struct {
	uint8_t		:3;
	uint8_t		xefe:1;
	uint8_t		yefe:1;
	uint8_t		zefe:1;
	uint8_t		oae:1;
	uint8_t		ele:1;
} mma8452q_ff_mt_cfg_t;

typedef struct {
	uint8_t		xhp:1;
	uint8_t		xhe:1;
	uint8_t		yhp:1;
	uint8_t		yhe:1;
	uint8_t		zhp:1;
	uint8_t		zhe:1;
	uint8_t		:1;
	uint8_t		ea:1;
} mma8452q_ff_mt_src_t;

typedef struct {
	uint8_t		ths:7;
	uint8_t		dbcntm:1;
} mma8452q_ff_mt_ths_t;

typedef struct {
	uint8_t		count;
} mma8452q_ff_mt_count_t;

typedef struct {
	mma8452q_ff_mt_cfg_t		ff_mt_cfg;
	mma8452q_ff_mt_src_t		ff_mt_src;
	mma8452q_ff_mt_ths_t		ff_mt_ths;
	mma8452q_ff_mt_count_t	ff_mt_count;
} mma8452q_ff_mt_regs_t;

typedef struct {
	uint8_t		bafro:1;
	uint8_t		lapo:2;
	uint8_t		:3;
	uint8_t		lo:1;
	uint8_t		newlp:1;
} mma8452q_pl_status_t;

typedef struct {
	uint8_t		:6;
	uint8_t		pl_en:1;
	uint8_t		dbcntm:1;
} mma8452q_pl_cfg_t;

typedef struct {
	uint8_t		dbnce;
} mma8452q_pl_count_t;

typedef struct {
	uint8_t		zlock:3;
	uint8_t		:3;
	uint8_t		bkfr:2;
} mma8452q_pl_bf_zcomp_t;

typedef struct {
	uint8_t		hys:3;
	uint8_t		pl_ths:5;
} mma8452q_pl_ths_t;

typedef struct {
	mma8452q_pl_status_t 		pl_status;
	mma8452q_pl_cfg_t 			pl_cfg;
	mma8452q_pl_count_t 		pl_count;
	mma8452q_pl_bf_zcomp_t 	pl_bf_zcomp;
	mma8452q_pl_ths_t 			pl_ths;
} mma8452q_pl_regs_t;

typedef struct {
	uint8_t		xspefe:1;
	uint8_t		xdpefe:1;
	uint8_t		yspefe:1;
	uint8_t		ydpefe:1;
	uint8_t		zspefe:1;
	uint8_t		zdpefe:1;
	uint8_t		ele:1;
	uint8_t 	dpa:1;
} mma8452q_pulse_cfg_t;

typedef struct {
	uint8_t		polx:1;
	uint8_t		poly:1;
	uint8_t		polz:1;
	uint8_t		dpe:1;
	uint8_t		axx:1;
	uint8_t		axy:1;
	uint8_t		axz:1;
	uint8_t 	ea:1;
} mma8452q_pulse_src_t;

typedef struct {
	uint8_t		ths:7;
	uint8_t		:1;
} mma8452q_pulse_ths_t;

typedef struct {
	uint8_t		tmlt:8;
} mma8452q_pulse_tmlt_t;

typedef struct {
	uint8_t		ltcy:8;
} mma8452q_pulse_ltcy_t;

typedef struct {
	uint8_t		wind:8;
} mma8452q_pulse_wind_t;

typedef struct {
	mma8452q_pulse_cfg_t		pulse_cfg;
	mma8452q_pulse_src_t		pulse_src;
	mma8452q_pulse_ths_t		pulse_thsx;
	mma8452q_pulse_ths_t		pulse_thsy;
	mma8452q_pulse_ths_t		pulse_thyz;
	mma8452q_pulse_tmlt_t		pulse_tmlt;
	mma8452q_pulse_ltcy_t		pulse_ltcy;
	mma8452q_pulse_wind_t		pulse_wind;
}	mma8452q_pulse_regs_t;

typedef struct {
	uint8_t		hpf_byp:1;
	uint8_t		xtefe:1;
	uint8_t		ytefe:1;
	uint8_t		ztefe:1;
	uint8_t		ele:1;
	uint8_t		:3;
} mma8452q_transient_cfg_t;

typedef struct {
	uint8_t		xtranspol:1;
	uint8_t		xtranse:1;
	uint8_t		ytranspol:1;
	uint8_t		ytranse:1;
	uint8_t		ztranspol:1;
	uint8_t		ztranse:1;
	uint8_t		ea:1;
	uint8_t		:1;
} mma8452q_transient_src_t;

typedef struct {
	uint8_t		ths:7;
	uint8_t		dbcntm:1;
} mma8452q_transient_ths_t;

typedef struct {
	uint8_t		dbnce:8;
} mma8452q_transient_count_t;

typedef struct {
	mma8452q_transient_cfg_t			transient_cfg;
	mma8452q_transient_src_t			transient_src;
	mma8452q_transient_ths_t			transient_ths;
	mma8452q_transient_count_t		transient_count;
}	mma8452q_transient_regs_t;

typedef struct {
	uint8_t 	off;
} mma8452q_off_t;

typedef struct {
	mma8452q_off_t		off_x;
	mma8452q_off_t		off_y;
	mma8452q_off_t		off_z;
} mma8452q_off_regs_t;
	
typedef struct {
	uint8_t		src_drdy:1;
	uint8_t		:1;
	uint8_t		src_ff_mt:1;
	uint8_t		src_pulse:1;
	uint8_t		src_lndprt:1;
	uint8_t		src_trans:1;
	uint8_t		:1;
	uint8_t		src_aslp:1;
} mma8452q_int_source_t;

typedef void (*mma8542q_evt_handler_t)(uint8_t *data, uint8_t len);

void mma8452q_init(void);
uint8_t mma8452q_whoami(void);

void mma8452q_enable(void);
void mma8452q_disable(void);
void mma8452q_getdata(uint8_t *data);

void mma8452q_data_enable(void);
void mma8452q_data_disable(void);
void mma8452q_data_setmoderegs(mma8452q_data_regs_t *regs);
void mma8452q_data_setmode(uint8_t *param, uint8_t len);
void mma8452q_data_getmoderegs(mma8452q_data_regs_t *regs);
void mma8452q_data_sethandler(mma8542q_evt_handler_t handler);

void mma8452q_ff_mt_enable(void);
void mma8452q_ff_mt_disable(void);
//void mma8452q_ff_mt_setmode(bool elatch, bool motion, bool x, bool y, bool z, bool dbcntm, uint8_t threshhold, uint8_t dbcnt);
void mma8452q_ff_mt_setmoderegs(mma8452q_ff_mt_regs_t *regs);
void mma8452q_ff_mt_setmode(uint8_t *param, uint8_t len);
void mma8452q_ff_mt_getmoderegs(mma8452q_ff_mt_regs_t *regs);
void mma8452q_ff_mt_sethandler(mma8542q_evt_handler_t handler);

void mma8452q_pl_enable(void);
void mma8452q_pl_disable(void);
void mma8452q_pl_setmoderegs(mma8452q_pl_regs_t *regs);
void mma8452q_pl_setmode(uint8_t *param, uint8_t len);
void mma8452q_pl_getmoderegs(mma8452q_pl_regs_t *regs);
void mma8452q_pl_sethandler(mma8542q_evt_handler_t handler);

void mma8452q_pulse_enable(void);
void mma8452q_pulse_disable(void);
void mma8452q_pulse_setmoderegs(mma8452q_pulse_regs_t *regs);
void mma8452q_pulse_setmode(uint8_t *param, uint8_t len);
void mma8452q_pulse_getmoderegs(mma8452q_pulse_regs_t *regs);
void mma8452q_pulse_sethandler(mma8542q_evt_handler_t handler);

void mma8452q_trans_enable(void);
void mma8452q_trans_disable(void);
void mma8452q_trans_setmoderegs(mma8452q_transient_regs_t *regs);
void mma8452q_trans_setmode(uint8_t *param, uint8_t len);
void mma8452q_trans_getmoderegs(mma8452q_transient_regs_t *regs);
void mma8452q_trans_sethandler(mma8542q_evt_handler_t handler);

void mma8452q_off_setmoderegs(mma8452q_off_regs_t *regs);
void mma8452q_off_setmode(uint8_t *param, uint8_t len);
void mma8452q_off_getmoderegs(mma8452q_off_regs_t *regs);

#endif

