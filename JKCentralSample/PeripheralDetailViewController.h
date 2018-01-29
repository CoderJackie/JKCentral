//
//  PeripheralDetailViewController.h
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/17.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;

@interface PeripheralDetailViewController : UIViewController
@property (strong, nonatomic) CBPeripheral *currentPeripheral;
@end
