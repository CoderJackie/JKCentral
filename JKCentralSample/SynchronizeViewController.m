//
//  SynchronizeViewController.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/17.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "SynchronizeViewController.h"
#import "BabyBluetooth.h"
#import "BluetoothUUIDHeader.h"
#import "SVProgressHUD.h"

struct NewType {
    Byte value[3];
};

typedef struct {
    struct NewType main_firmware_version;//主firmware版本
    struct NewType backup_firmware_version;//备firmware版本
    uint32_t upgrade_rom_size;  // 当前可用于FW升级的ROM大小
    uint16_t error_log_size;  // 未上报的Error log量
} __attribute__((packed)) IGBLEStatus;

@interface SynchronizeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *receivedDataTextView;
@property (weak, nonatomic) IBOutlet UITextView *bleStatusTextView;
@property (weak, nonatomic) IBOutlet UITextView *digitalKeyStatusTextView;
@property (weak, nonatomic) IBOutlet UITextView *mcuStatusTextView;

@end

@implementation SynchronizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"共享状态同步";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addNotify];
}

- (void)addNotify
{
    CBCharacteristic *bleStatusChara = [BabyToy findCharacteristicFormServices:[self.currentPeripheral.services mutableCopy] UUIDString:BLE_Status_Characteristic];
    CBCharacteristic *mcuStatusChara = [BabyToy findCharacteristicFormServices:[self.currentPeripheral.services mutableCopy] UUIDString:Main_MCU_Status_Characteristic];
    CBCharacteristic *dkStatusChara = [BabyToy findCharacteristicFormServices:[self.currentPeripheral.services mutableCopy] UUIDString:Digital_Key_Status_Characteristic];
    
    [[BabyBluetooth shareBabyBluetooth] notify:self.currentPeripheral characteristic:bleStatusChara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        GGLog(@"收到通知：%@，error：%@", characteristics, error);
        [self bleStatus:characteristics error:error];
    }];
    
    [[BabyBluetooth shareBabyBluetooth] notify:self.currentPeripheral characteristic:dkStatusChara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        GGLog(@"收到通知：%@，error：%@", characteristics, error);
        [self digitalKeyStatus:characteristics error:error];
    }];
    
    [[BabyBluetooth shareBabyBluetooth] notify:self.currentPeripheral characteristic:mcuStatusChara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        GGLog(@"收到通知：%@，error：%@", characteristics, error);
        [self mcuStatus:characteristics error:error];
    }];
}

- (void)bleStatus:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"获取BLE状态成功"];
        GGLog(@"获取BLE状态成功\n value:%@", characteristic.value);
        self.receivedDataTextView.text = [NSString stringWithFormat:@"%@", characteristic.value];
        const void *raw = characteristic.value.bytes;
        IGBLEStatus *status = (IGBLEStatus *)raw;
        
        Byte *main_version = status->main_firmware_version.value;
        Byte *backup_version = status->backup_firmware_version.value;
        
        uint32_t main_firmware_version = (main_version[0] << 16) + (main_version[1] << 8) + main_version[2];
        uint32_t backup_firmware_version = (backup_version[0] << 16) + (backup_version[1] << 8) + backup_version[2];
        uint32_t upgrade_rom_size = status->upgrade_rom_size;
        uint16_t error_log_size = status->error_log_size;
        
        self.receivedDataTextView.text = [NSString stringWithFormat:@"%@", characteristic.value];
        self.bleStatusTextView.text = [NSString stringWithFormat:@"<主版本 :%@>\n<备版本 :%@>\n<rom size :%@>\n<error log size :%@>", @(main_firmware_version), @(backup_firmware_version), @(upgrade_rom_size), @(error_log_size)];
        GGLog(@"<主版本 :%@>\n<备版本 :%@>\n<rom size :%@>\n<error log size :%@>", @(main_firmware_version), @(backup_firmware_version), @(upgrade_rom_size), @(error_log_size));
    } else {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取BLE状态失败:%@", error.localizedDescription]];
        GGLog(@"获取BLE状态失败:%@", error.localizedDescription);
    }
}

//0是无效，1是有效，2是待校验
- (void)digitalKeyStatus:(CBCharacteristic *)characteristic error:(NSError *)error  {
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"获取钥匙鉴权结果成功"];
        GGLog(@"获取钥匙鉴权结果成功\n value:%@", characteristic.value);
        self.receivedDataTextView.text = [NSString stringWithFormat:@"%@", characteristic.value];
        int result = [BabyToy ConvertDataToInt:characteristic.value];
        NSString *value = nil;
        switch (result) {
            case 0:
                value = @"无效";
                break;
            case 1:
                value = @"有效";
                break;
            case 2:
                value = @"待校验";
                break;
            default:
                break;
        }
        self.digitalKeyStatusTextView.text = [NSString stringWithFormat:@"钥匙鉴权结果:%@ => %@", @(result), value];
        GGLog(@"钥匙鉴权结果:%@ => %@", @(result), value);
    } else {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取钥匙鉴权结果失败:%@", error.localizedDescription]];
        
        GGLog(@"获取钥匙鉴权结果失败:%@", error.localizedDescription);
    }
}

//0：工作态 1：standby 2：sleep
- (void)mcuStatus:(CBCharacteristic *)characteristic error:(NSError *)error  {
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"获取MCU状态成功"];
        self.receivedDataTextView.text = [NSString stringWithFormat:@"%@", characteristic.value];
        int result = [BabyToy ConvertDataToInt:characteristic.value];
        NSString *value = nil;
        switch (result) {
            case 0:
                value = @"working";
                break;
            case 1:
                value = @"standby";
                break;
            case 2:
                value = @"sleep";
                break;
            default:
                break;
        }
        self.mcuStatusTextView.text = [NSString stringWithFormat:@"MCU状态：%@ => %@", @(result), value];
        GGLog(@"MCU状态：%@ => %@", @(result), value);
    } else {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取MCU状态失败:%@", error.localizedDescription]];
        GGLog(@"获取MCU状态失败:%@", error.localizedDescription);
    }
}

@end
