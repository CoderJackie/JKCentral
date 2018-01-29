//
//  CLBLEBaseProtocol.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLBLEBaseApi.h"

typedef NSData* (^fetchSinglePacketDataBlock)();
typedef NSData* (^receiveAndParseDataBlock)(NSData*data,NSError**error);
typedef id    (^reformDataBlock)(NSData*data);

@interface CLBLEBaseProtocol : NSObject<CLBLEPacketHandle>

@property(nonatomic,strong)NSData* singleDeviceResponsePacketData;
@property(nonatomic,strong)NSData* singleAppResponsePacketData;

@property(nonatomic,strong)NSData* packetData;
@property(nonatomic,copy)fetchSinglePacketDataBlock SinglePacketDataBlock;
@property(nonatomic,copy)receiveAndParseDataBlock receiveAndParseDataBlock;
@property(nonatomic,copy)reformDataBlock reformDataBlock;
@property(nonatomic,assign) NSInteger singlePacketTotalSend;
@property(nonatomic,assign) NSInteger  packetDataLength;
@property(nonatomic,assign) NSInteger receiveBufferLength;
@property(nonatomic,strong) NSMutableData* mutableReceiveData;

@end
