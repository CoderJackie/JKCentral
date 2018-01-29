//
//  BLEMattressProtocol.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/23.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "BLEMattressProtocol.h"
#import "IGBluetoothHeader.h"

@implementation BLEMattressProtocol
#if 0
//获取统计数据的数据包
+(BLEMattressProtocol*)getRequestStatisticalPacketData:(NSString*)uinqueIDString{
    uint8_t packetHead[sizeof(Ble_Protocol_Head_T)]={0};
    //    uint8_t uinqueID[6]={0};
    uint8_t* uinqueID=(uint8_t*)[uinqueIDString UTF8String];
    
    Init_Ble_Protocol_Head(packetHead, REQUEST_GET_DATA_COMMAND, 0,uinqueID,nil);
    
    NSMutableData* packetData=[[NSMutableData alloc] initWithCapacity:0];
    NSData* packetHeadData=[NSData dataWithBytes:packetHead length:sizeof(Ble_Protocol_Head_T)];
    [packetData appendData:packetHeadData];
    
    uint8_t endCommand=BLE_PROTOCOL_END_FLAG;
    [packetData appendBytes:&endCommand length:1];
    
    BLEMattressProtocol* obj= [[self alloc] init];
    uint8_t byte[]={0};
    
    //    obj.singleAppResponsePacketData = [NSData dataWithBytes:byte length:1];
    obj.singleDeviceResponsePacketData = [NSData dataWithBytes:byte length:1];  //这里就是给BleProtocal里的那些属性赋值
    obj.packetData = packetData;
    return obj;
    
    //    return packetData;
}
#endif

@end
