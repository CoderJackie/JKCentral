//
//  BLEMattressProtocol.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/23.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "CLBLEBaseProtocol.h"

@interface BLEMattressProtocol : CLBLEBaseProtocol

uint8_t ble_currentTimeOffset();

void ble_gmtTimeString(uint8_t* timeValue);

void ble_gmtTimeString_new(uint8_t* timeValue);
void Init_Ble_Protocol_Head(uint8_t *packetArray,short comdNo,uint16_t dataLength,uint8_t* uniqueID,NSString *deviceVersion);
void Init_Ble_Protocol_Head_New(uint8_t *packetArray,short comdNo,uint16_t dataLength,uint8_t* uniqueID);
//获取统计数据的数据包
+(BLEMattressProtocol*)getRequestStatisticalPacketData:(NSString*)uinqueIDString;

//通知设备清除统计数据的数据包
+(BLEMattressProtocol*)getDeleteStatisticalPacketData:(NSString*)uinqueIDString;


/**
 *  获取实时数据数据包
 *
 *  @param uinqueIDString 唯一ID
 *
 *  @return 返回获取实时数据的数据包
 */
+(BLEMattressProtocol*)getRequestRealTimePacketData:(NSString*)uinqueIDString;

/**
 *  确认蓝牙升级的数据包
 *
 *  @param uinqueIDString 唯一ID
 *
 *  @return 返回获取蓝牙升级的数据包
 */
+(BLEMattressProtocol *)getRequestConfirmUpgrade:(NSString *)uinqueIDString;

@end
