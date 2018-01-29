//
//  MattressBLEManagerApi.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "MattressBLEManagerApi.h"
#import "CLBLEManager.h"
#import "BLEMattressProtocol.h"

@implementation MattressBLEManagerApi
#if 0
-(void)fetchHistoryDataWithSuccessBlock:(void(^)(NSData* data))success
                              FailBlock:(void(^)(NSError* error))fail{
    
    GGLog(@"fetchHistoryDataWithSuccessBlock0");
    GGLog(@"CLBLEStateIdle == %d",CLBLEStateIdle);
    GGLog(@"self.state == %d",self.state);
    
    //不相等说明蓝牙繁忙
    if ( self.state != CLBLEStateIdle) {
        NSError* error=[NSError errorWithDomain:kCLBLEManagerErrorDomain code:kBLEBusyErrorCode userInfo:@{@"message":kBLEBusyErrorCodeErrorMessage}];;
        fail(error);
        return ;
    }
    id <CLBLEPacketHandle> sendRealTimeData;
    __weak MattressBLEManagerApi* weakSelf=self;
    if (self.connectedPeripheral.cbPeripheral.state==CBPeripheralStateConnected) {
        sendRealTimeData =[BLEMattressProtocol getRequestStatisticalPacketData:self.uniqueID];
        [self sendBLEDataWithDataPacketProtocol:sendRealTimeData
                                        Success:^(NSData *data) {
                                            /*历史数据比较简单，获取历史数据，上传到服务器，然后通知设备，清除数据。
                                             然后告诉外面结果就说成功了，
                                             业务接口自己去服务器拉取数据，整个上传数据流程完毕。
                                             */
                                            success(data);
                                            GGLog(@"data is %@",data);
                                        } fail:^(NSError *error) {
                                            GGLog(@"error is %@",error);
                                            fail(error);
                                        }];
    }
    else{
        GGLog(@"fetchHistoryDataWithSuccessBlock11");
        self.currentPeripheral=nil;
        [[CLBLEManager sharedInstance] conntectPeripheralWithBLEDataSource:self
                                                           withResultBlock:^(LGPeripheral *peripheral, NSError *error) {
                                                               GGLog(@"fetchHistoryDataWithSuccessBlock1");
                                                               if (error) {
                                                                   fail(error);
                                                               }
                                                               else{
                                                                   weakSelf.currentPeripheral=peripheral;
                                                                   sendRealTimeData =[BLEMattressProtocol getRequestStatisticalPacketData:self.uniqueID];
                                                                   [weakSelf sendBLEDataWithDataPacketProtocol:sendRealTimeData
                                                                                                       Success:^(NSData *data) {
                                                                                                           /*历史数据比较简单，获取历史数据，上传到服务器，然后通知设备，清除数据。
                                                                                                            然后告诉外面结果就说成功了，
                                                                                                            业务接口自己去服务器拉取数据，整个上传数据流程完毕。
                                                                                                            */
                                                                                                           success(data);
                                                                                                           GGLog(@"data is %@",data);
                                                                                                       } fail:^(NSError *error) {
                                                                                                           GGLog(@"error is %@",error);
                                                                                                           fail(error);
                                                                                                       }];
                                                               }
                                                           }];
    }
    
}
#endif
@end
