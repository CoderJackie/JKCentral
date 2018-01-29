//
//  CLBLEBaseApi.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "CLBLEBaseApi.h"

#define kCLBLEManagerErrorDomain @"kCLBLEManagerErrorDomain"

#define kBLEBusyErrorCodeErrorMessage @"kBLEBusyErrorCodeErrorMessage"
#define kBLEObjErrorCodeErrorMessage @"kBLEObjErrorCodeErrorMessage"
#define kBLECommunConnectErrorCodeErrorMessage @"kBLECommunConnectErrorCodeErrorMessage"

#define kBLEBusyErrorCode 1
#define kBLEObjErrorCode 2
#define kBLECommunConnectErrorCode 3

@interface CLBLEBaseApi()
@property (assign, nonatomic) id <CLBLEPacketHandle> dataPacketHandleDelegate;
@end

@implementation CLBLEBaseApi
-(void)sendBLEDataWithDataPacketProtocol:(id<CLBLEPacketHandle>)packetDelegate
                                 Success:(BLESuccessBlock)successBlock
                                    fail:(BLEFailBlock)failBlock{
    if (self.state!= CLBLEStateIdle) {
        
        NSError* error=[NSError errorWithDomain:kCLBLEManagerErrorDomain code:kBLEBusyErrorCode userInfo:@{@"message":kBLEBusyErrorCodeErrorMessage}];
        failBlock(error);
        return;
    }
    self.child=(id <CLBLEDataSource>)self;
    
    if (!self.child.connectedPeripheral) {
        NSError* error=[NSError errorWithDomain:kCLBLEManagerErrorDomain code:kBLEObjErrorCode userInfo:@{@"message":kBLEObjErrorCodeErrorMessage}];
        failBlock(error);
        return;
    }
    if (self.child.connectedPeripheral.cbPeripheral.state!=CBPeripheralStateConnected) {
        //NSError* error=[NSError errorWithDomain:kCLBLEManagerErrorDomain code:kBLECommunConnectErrorCode userInfo:@{@"message":@"设备没有连接，发个毛啊！"}];
        NSError* error=[NSError errorWithDomain:kCLBLEManagerErrorDomain code:kBLECommunConnectErrorCode userInfo:@{@"message":kBLECommunConnectErrorCodeErrorMessage}];
        failBlock(error);
        return;
    }
    self.dataPacketHandleDelegate=packetDelegate;
    [self sendBLEDataWithData:[self.dataPacketHandleDelegate fetchCompletePacketData]
                      Success:successBlock
                         fail:failBlock];
}

-(void)sendBLEDataWithData:(NSData *)packetDelegate
                   Success:(BLESuccessBlock)successBlock
                      fail:(BLEFailBlock)failBlock
{
    
}
@end
