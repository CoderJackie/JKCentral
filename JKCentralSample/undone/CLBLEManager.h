//
//  CLBLEManager.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLBLEBaseApi.h"

@protocol CLBLEManagerDelegate <NSObject>

-(void)scanAllPeripherals:(NSArray *)allLGPeripherals;

@end

@interface CLBLEManager : NSObject

@property (strong, nonatomic) LGPeripheral  *currentLGPeripheral;
@property (strong, nonatomic) CBCentralManager *manager;
@property (copy, nonatomic) NSString *broadName;
@property (assign, nonatomic) id <CLBLEManagerDelegate> multicasetDelegate;
+(CLBLEManager *)sharedInstance;


//初始化蓝牙并设置读取数据的回调，自动扫描，如果扫描设备名字broadName为空，则扫描所有设备并返回列表，如果broadName不为空则返回连接上的蓝牙设备
-(void)scanbleWithObject:(id<CLBLEDataSource>)child
         withScanTimeOut:(NSInteger)timeOut;
//scanPeripheralBlock:(void (^)(NSArray *peripherals,NSError *error))scanPeripheralBlock;
//连接蓝牙
//-(void)conntectPeripheral:(LGPeripheral *)peripheral withResultBlock:(void(^)(NSError *error))connectResultBlock;

-(void)conntectPeripheralWithBLEDataSource:(id<CLBLEDataSource>)child
                           withResultBlock:(void(^)(LGPeripheral* peripheral,NSError *error))connectResultBlock;
//OAD空中升级的时候必须先扫描后连接
-(void)oadConntectPeripheralWithBLEDataSource:(id<CLBLEDataSource>)child
                              withResultBlock:(void(^)(LGPeripheral* peripheral,NSError *error))connectResultBlock;

//发送数据
-(void)sendData:(NSData *)data peripheral:(LGPeripheral *)peripheral;
//设置Notify
-(void)setNotify:(LGPeripheral *)peripheral WithCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID withResultBlock:(void(^)(NSError *error))resultBlock withResultBlock:(void(^)(NSData *data,NSError *error))readDataBlock;
//断开蓝牙
-(void)disconntectPeripheral:(LGPeripheral *)peripheral withResultBlock:(void(^)(NSError *error))aCallback;

@end
