//
//  CLBLEDataSource.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLBLEDataSource <NSObject>

@required

-(NSArray*)scanServiceArray;              //扫描到的服务

-(NSString*)readSeriveID;                 //读取数据的服务ID

-(NSString*)readCharacteristicID;         //读取数据的特征ID

-(NSString*)writeSeriveID;

-(NSString*)writeCharacteristicID;

-(LGPeripheral*)connectedPeripheral;      //连接到的外设

-(NSString *)broadName;                   //广播名

@end
