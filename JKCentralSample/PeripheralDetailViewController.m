//
//  PeripheralDetailViewController.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/17.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "PeripheralDetailViewController.h"
#import "BabyBluetooth.h"
#import "SVProgressHUD.h"
#import "BluetoothUUIDHeader.h"
#import "PassThroughViewController.h"
#import "SynchronizeViewController.h"

@interface PeripheralDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *serviceAndCharacteristicTextView;
@property (strong, nonatomic) BabyBluetooth *bluetoothHelper;
@property (strong, nonatomic) NSMutableDictionary *servicesDic;
@end

@implementation PeripheralDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.bluetoothHelper = [BabyBluetooth shareBabyBluetooth];
    self.servicesDic = [NSMutableDictionary new];
    
    [self babyDelegate];
    [self connectPeripheral];
}

- (void)connectPeripheral
{
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    self.bluetoothHelper.channel(@"T-BOX").having(self.currentPeripheral).connectToPeripherals().discoverServices().discoverCharacteristics().begin();
}

- (void)babyDelegate
{
    __weak typeof(self)weakSelf = self;
    
    [self.bluetoothHelper setBlockOnConnectedAtChannel:@"T-BOX" block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        GGLog(@"设备：%@--连接成功",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
    }];
    
    [self.bluetoothHelper setBlockOnFailToConnectAtChannel:@"T-BOX" block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        GGLog(@"设备：%@--连接失败, 错误:%@",peripheral.name, error);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];
    
    [self.bluetoothHelper setBlockOnDisconnectAtChannel:@"T-BOX" block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        GGLog(@"设备：%@--断开连接， 错误：%@",peripheral.name, error);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开连接",peripheral.name]];
        [weakSelf.bluetoothHelper AutoReconnect:weakSelf.currentPeripheral];
    }];
    
    //设置发现设备的Services的委托
    [self.bluetoothHelper setBlockOnDiscoverServicesAtChannel:@"T-BOX" block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSMutableDictionary *characteristics = [NSMutableDictionary dictionaryWithCapacity:0];
            [weakSelf.servicesDic setObject:characteristics forKey:service.UUID.UUIDString];
        }
    }];
    //设置发现设service的Characteristics的委托
    [self.bluetoothHelper setBlockOnDiscoverCharacteristicsAtChannel:@"T-BOX" block:^(CBPeripheral *peripheral, CBService *service, NSError *eror) {
        
        NSMutableDictionary *charachDic = [weakSelf.servicesDic objectForKey:service.UUID.UUIDString];
        for (CBCharacteristic *characteristic in service.characteristics) {
            [charachDic setObject:characteristic forKey:characteristic.UUID.UUIDString];
        }
        
        weakSelf.serviceAndCharacteristicTextView.text = [NSString stringWithFormat:@"%@", weakSelf.servicesDic];
    }];
}

- (IBAction)PassThroughAction:(id)sender {
    PassThroughViewController *vc = [[PassThroughViewController alloc] init];
    vc.currentPeripheral = self.currentPeripheral;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)stateSynchronizeAction:(id)sender {
    SynchronizeViewController *vc = [[SynchronizeViewController alloc] init];
    vc.currentPeripheral = self.currentPeripheral;
    [self.navigationController pushViewController:vc animated:YES]; 
}
@end
