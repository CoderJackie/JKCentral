//
//  NSString+JKExtension.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/19.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "NSString+JKExtension.h"
#import "NSData+JKExtension.h"

@implementation NSString (JKExtension)
- (UInt8)do_crc
{
//    Byte b[4];
//    b[0] = 0xa1;
//    b[1] = 0xb2;
//    b[2] = 0xc3;
//    b[3] = 0xd4;
//    NSData *data = [NSData dataWithBytes:&b length:4];
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    UInt8 sum = [data do_crc];;
    return sum;
}

- (NSUInteger)dataLength
{
    return [self dataUsingEncoding:NSUTF8StringEncoding].length;
}
@end
