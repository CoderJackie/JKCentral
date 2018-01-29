//
//  BleProtocal.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "CLBLEBaseProtocol.h"
#import "IGBluetoothHeader.h"

@implementation CLBLEBaseProtocol
-(receiveAndParseDataBlock)receiveAndParseDataBlock
{
    __weak  CLBLEBaseProtocol * weakself = self;
    receiveAndParseDataBlock block = ^NSData*(NSData*data,NSError**error){
        
        if (!data) {
            *error=[NSError errorWithDomain:@"BLEReceiveDataHelper" code:01 userInfo:@{@"errorInfo":@"解析数据不能传空值"}];
            return nil;
            
        }
        if (data.length<=0) {
            *error=[NSError errorWithDomain:@"BLEReceiveDataHelper" code:01 userInfo:@{@"errorInfo":@"解析数据不能传空值"}];
            return nil;
        }
        
        
        if (weakself.receiveBufferLength==0) {
            uint8_t startFlag=0;
            [data getBytes:&startFlag length:1];
            if (startFlag!=0xf2) {
                [self clear];
                *error=[NSError errorWithDomain:@"BLEReceiveDataHelper" code:02 userInfo:@{@"errorInfo":@"起始不是0xf2"}];
                return nil;
            }
        }
        if (!weakself.mutableReceiveData) {
            weakself.mutableReceiveData=[[NSMutableData alloc] initWithCapacity:0];
        }
        [weakself.mutableReceiveData appendData:data];
        weakself.receiveBufferLength+=data.length;
        
        if (weakself.receiveBufferLength>=sizeof(Ble_Protocol_Head_T)) {
            
            Ble_Protocol_Head_T bleProtocolHeaderT={0};
            
            int offset = (int)((size_t)&(bleProtocolHeaderT.body_length)-(size_t)&bleProtocolHeaderT);
            
            typeof (weakself.packetDataLength) length;
            [[weakself.mutableReceiveData subdataWithRange:NSMakeRange(offset, 2)] getBytes:&length length:2];
            
            weakself.packetDataLength = length;
            weakself.packetDataLength=htons(weakself.packetDataLength);
            weakself.packetDataLength=sizeof(Ble_Protocol_Head_T)+1+weakself.packetDataLength;
            
            if (weakself.receiveBufferLength>=weakself.packetDataLength) {
                
                NSData* resultPacketData=[weakself.mutableReceiveData subdataWithRange:NSMakeRange(0, weakself.packetDataLength)];
                
                uint8_t endFlag=0;
                [[weakself.mutableReceiveData subdataWithRange:NSMakeRange(weakself.packetDataLength-1, 1)] getBytes:&endFlag length:1];
                
                if (endFlag==0xf3) {
                    if (weakself.receiveBufferLength==weakself.packetDataLength) {
                        //                        [weakself clear];
                    }
                    *error=nil;
                    //接收完成
                    return resultPacketData;
                }
                else{
                    *error=[NSError errorWithDomain:@"BLEReceiveDataHelper" code:02 userInfo:@{@"errorInfo":@"结束标志不是0xf3"}];
                    return nil;
                }
            }
        }
        //接收 ing
        *error=nil;
        return nil;
    };
    return [block copy];
}
- (void)clear
{
    
}
-(fetchSinglePacketDataBlock)SinglePacketDataBlock
{
    
    __weak  CLBLEBaseProtocol * weakself = self;
    fetchSinglePacketDataBlock block = ^NSData*(){
        
        
        if ( weakself.singlePacketTotalSend >= weakself.packetData.length)
        {
            return nil;
        }
        int cur_send = ((self.packetData.length - _singlePacketTotalSend) > MAX_SINGLE_PACKET_LEN)? MAX_SINGLE_PACKET_LEN: (int)(self.packetData.length - self.singlePacketTotalSend);
        NSData* singleData=[self.packetData subdataWithRange:NSMakeRange(self.singlePacketTotalSend, cur_send)];
        self.singlePacketTotalSend += cur_send;
        
        return singleData;
        
    };
    
    return [block copy];
}

#pragma mark- BLEDataReformer
-(id)apiManager:(CLBLEBaseApi *)manager reformData:(NSData *)data
{
    return self.reformDataBlock?self.reformDataBlock(data):nil;
}

#pragma mark- CLBLEPacketHandle
-(NSInteger)receivedPacketDataLength
{
    return self.receiveBufferLength;
}
-(NSInteger)totalPacketDataLength
{
    return self.packetDataLength;
}
-(NSData*)singlePacketDataDeviceResponse
{
    return self.singleDeviceResponsePacketData;
}
-(NSData*)singlePacketDataAppResponse
{
    return self.singleAppResponsePacketData;
}
/**
 *  一个完整包的数据内容
 *
 *  @return 完整数据包的内容
 */
-(NSData*)fetchCompletePacketData
{
    return self.packetData;
}

/**
 *  根据需要发送的数据包，做拆分，确定每一个包的数据内容
 *
 *  @return 单数数据包的内容
 */
-(NSData*)fetchSinglePacketData
{
    return self.SinglePacketDataBlock?self.SinglePacketDataBlock():nil;
}

/**
 *  解析收到的蓝牙数据
 *
 *  @param data  收到的数据
 *  @param error error信息
 *
 *  @return 如果解析完成，返回解析之后的值，如果解析失败返回空，error有值
 *  如果解析没有完成，返回空，error也是空
 */
-(NSData*)receiveAndParseData:(NSData*)data error:(NSError**)error
{
    return self.receiveAndParseDataBlock?self.receiveAndParseDataBlock(data,error):nil;
}
@end
