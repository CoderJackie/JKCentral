//
//  BluetoothUUIDHeader.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/17.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#ifndef BluetoothUUIDHeader_h
#define BluetoothUUIDHeader_h

#define Pass_Through_Service @"8A97F7C0-8506-11E3-bAA7-0800200C9A10"
//BLE发送给App
#define Receive_Data_Status_Characteristic @"A010"
#define Receive_Data_Characteristic @"A011"
//App发送给BLE
#define Transmit_Data_Status_Characteristic @"B010"
#define Transmit_Data_Characteristic @"B011"

#define Share_State_Synchronize_Service @"8A97F7C0-8506-11E3-bAA7-0800200C9A11"
#define BLE_Status_Characteristic @"C010"
#define Digital_Key_Status_Characteristic @"C011"
#define Main_MCU_Status_Characteristic @"C012"

#endif /* BluetoothUUIDHeader_h */
