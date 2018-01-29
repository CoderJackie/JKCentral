//
//  NSString+JKExtension.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/19.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JKExtension)
- (UInt8)do_crc;
- (NSUInteger)dataLength;
@end
