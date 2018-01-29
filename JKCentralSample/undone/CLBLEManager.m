//
//  CLBLEManager.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/22.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "CLBLEManager.h"

@interface CLBLEManager()
@property (strong, nonatomic) NSArray *scanServiceArray;
@property (copy, nonatomic) NSString *readServiceUUID;
@property (copy, nonatomic) NSString *readCharacteristic;
@property (copy, nonatomic) NSString *writeServiceUUID;
@property (copy, nonatomic) NSString *writeCharacteristic;
@end
@implementation CLBLEManager
#if 0
-(void)scanbleWithObject:(id<CLBLEDataSource>)child
         withScanTimeOut:(NSInteger)timeOut
{
    
    self.broadName=nil;
    if ([child respondsToSelector:@selector(broadName)]) {
        self.broadName=[child broadName];
    }
    if ([child connectedPeripheral].name) {
        self.broadName=child.connectedPeripheral.name;
    }
    self.scanServiceArray=child.scanServiceArray;
    self.readServiceUUID=child.readSeriveID;
    self.readCharacteristic=child.readCharacteristicID;
    self.writeServiceUUID=child.writeSeriveID;
    self.writeCharacteristic=child.writeCharacteristicID;
    if(self.readServiceUUID.length==0||self.readCharacteristic.length==0||self.writeServiceUUID.length==0||self.writeCharacteristic.length==0)
    {
        [self.multicasetDelegate scanAllPeripherals:nil];
        return;
    }
    __weak CLBLEManager *weakself=self;
    if([LGCentralManager sharedInstance].centralReady)
    {
        [weakself scanWithTimeout:timeOut scanFinishBlock:^(NSArray *peripherals)
         {
             [weakself.multicasetDelegate scanAllPeripherals:peripherals];
         }];
        
    }
    self.hasConnectedPeripherals=[[NSMutableArray alloc]init];
    self.retrievePeripheralsWithIdentifiers=[[NSMutableArray alloc]init];
    self.scanPeripheralsCallback=nil;
    // Custom initialization
    
    [LGCentralManager sharedInstance].updateStateBlock =^(CBCentralManagerState state)
    {
        if (state == CBCentralManagerStatePoweredOn)
        {
            if (![LGCentralManager sharedInstance].isScanning)
            {
                [weakself scanWithTimeout:timeOut scanFinishBlock:^(NSArray *peripherals)
                 {
                     
                     [weakself.multicasetDelegate scanAllPeripherals:peripherals];
                 }];
            }
        }
    };
}
#endif
@end
