//
//  CLBLEBaseApi.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLBLEDataSource.h"
#import "CLBLEPacketHandle.h"

@class CLBLEBaseApi;
typedef NS_ENUM (NSUInteger, CLBLEState){
    CLBLEStateIdle,
    CLBLEStateSending,
    CLBLEStateReceiving,
};

typedef void (^BLEScanDiscoverPeripheralsCallback) (NSArray *peripherals);

typedef void (^BLEProgressiveDownLoadBlock) (NSInteger totalBytesRead, NSInteger totalBytesExpected);

typedef void (^BLESuccessBlock) (NSData *data);

typedef void (^BLEFailBlock) (NSError* error);

typedef void (^BleStateBlock)(CBCentralManagerState state);


@interface CLBLEBaseApi : NSObject

@property (nonatomic,weak) NSObject<CLBLEDataSource>* child;

@property (nonatomic,assign) CLBLEState state;

@property (nonatomic,assign) BOOL bleIsReady;


-(void)setProgressiveBlock:(BLEProgressiveDownLoadBlock)progressBlock;
-(void)sendBLEDataWithDataPacketProtocol:(id<CLBLEPacketHandle>)packetDelegate
                                 Success:(BLESuccessBlock)successBlock
                                    fail:(BLEFailBlock)failBlock;
@end
