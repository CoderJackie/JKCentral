//
//  MattressBLEManagerApi.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "CLBLEBaseApi.h"

@interface MattressBLEManagerApi : CLBLEBaseApi<CLBLEDataSource>

@property (nonatomic,strong) LGPeripheral* currentPeripheral;
@property (nonatomic,strong) NSString* currentBroadName;
@property (nonatomic,assign) BOOL BLEIsPowerOn;
@property (copy, nonatomic) NSString *uniqueID;
//固件升级时候版本号，如1.9.0
@property (nonatomic,assign) NSString* DeviceUpgradeVersion;
-(void)fetchHistoryDataWithSuccessBlock:(void(^)(NSData* data))success
                              FailBlock:(void(^)(NSError* error))fail;

-(void)fetchRealTimeDataSuccessBlock:(void(^)(NSData* data))success
                           FailBlock:(void(^)(NSError* error))fail;

-(void)fetchRealTimeDataWithInterVal:(NSTimeInterval)interval
                           WithTimes:(NSTimeInterval)times
                        SuccessBlock:(void(^)(NSData* data))success
                           FailBlock:(void(^)(NSError* error))fail;


-(void)fetchBLEHandShakeSuccessBlock:(void(^)(NSData* data))success
                           FailBlock:(void(^)(NSError* error))fail;


//还没有调用
-(void)deleteStatisticalDataWithSuccessBlock:(void(^)(NSData* data))success
                                   FailBlock:(void(^)(NSError* error))fail;

-(void)fetchProtocolVersionSuccessBlock:(void(^)(NSData* data))success
                              FailBlock:(void(^)(NSError* error))fail;

-(void)stopFetchRealTimeData;
-(void)resumeFetchRealTimeData;
-(void)suspendFetchRealTimeData;

@end
