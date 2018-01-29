//
//  CLBLEPacketHandle.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLBLEBaseApi;

@protocol CLBLEPacketHandle <NSObject>
-(NSInteger)receivedPacketDataLength;
-(NSInteger)totalPacketDataLength;

-(NSData*)singlePacketDataDeviceResponse;  //设备收到app的数据后，要给app回复一个数据，告诉app我已经收到数据

-(NSData*)singlePacketDataAppResponse;     //同理App也需要回复


-(NSData*)fetchCompletePacketData;        //完整的数据包

/**
 *  根据需要发送的数据包，做拆分，确定每一个包的数据内容
 *
 *  @return 单数数据包的内容
 */
-(NSData*)fetchSinglePacketData;         //拆包后的数据

/**
 *  解析收到的蓝牙数据
 *
 *  @param data  收到的数据
 *  @param error error信息
 *
 *  @return 如果解析完成，返回解析之后的值，如果解析失败返回空，error有值
 *  如果解析没有完成，返回空，error也是空
 */
-(NSData*)receiveAndParseData:(NSData*)data error:(NSError**)error;


-(id)apiManager:(CLBLEBaseApi*)manager reformData:(NSData*)data;

@end
