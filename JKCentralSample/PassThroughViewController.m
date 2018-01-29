//
//  PassThroughViewController.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/17.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "PassThroughViewController.h"
#import "BluetoothUUIDHeader.h"
#import "BabyBluetooth.h"
#import "NSString+JKExtension.h"
#import "SVProgressHUD.h"

#define kBLE_Max_Send_length 20
@interface PassThroughViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *passThroughTextView;
@property (weak, nonatomic) IBOutlet UITextView *dataStateTextView;
@property (weak, nonatomic) IBOutlet UITextView *passThroughDataTextView;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (weak, nonatomic) IBOutlet UILabel *passThroughLengthLabel;

@property (strong, nonatomic) NSMutableData *statusData;
@property (strong, nonatomic) NSMutableData *totalData;
@end

@implementation PassThroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"数据透传服务";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    
    [self addNotify];
    
}

- (void)addNotify
{
    __weak typeof(self) weakSelf = self;
    NSMutableArray *services = [self.currentPeripheral.services mutableCopy];
    CBCharacteristic *dataStatusCharacter = [BabyToy findCharacteristicFormServices:services UUIDString:Receive_Data_Status_Characteristic];
    CBCharacteristic *dataCharacter = [BabyToy findCharacteristicFormServices:services UUIDString:Receive_Data_Characteristic];

    if (!dataStatusCharacter || !dataCharacter) {
        return;
    }

    [[BabyBluetooth shareBabyBluetooth] notify:self.currentPeripheral characteristic:dataStatusCharacter block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//        weakSelf.statusData = [NSMutableData data];
//        [weakSelf.statusData appendData:characteristics.value];
        [weakSelf didReadReceiveData:characteristics.value characteristic:characteristics];
    }];
    
    [[BabyBluetooth shareBabyBluetooth] notify:self.currentPeripheral characteristic:dataCharacter block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        [weakSelf didReadReceiveData:characteristics.value characteristic:characteristics];
    }];
}

- (void)didReadReceiveData:(NSData *)data characteristic:(CBCharacteristic *)characteristic
{
    GGLog(@"接收到透传数据：uuid : %@, data: %@", characteristic.UUID, data);
    if ([characteristic.UUID.UUIDString isEqualToString:Receive_Data_Status_Characteristic]) {
        self.statusData = [NSMutableData data];
        [self.statusData appendData:data];
    } else if ([characteristic.UUID.UUIDString isEqualToString:Receive_Data_Characteristic]) {
        
        NSData *lengthData = [self.statusData subdataWithRange:NSMakeRange(0, 1)];
        int length = [BabyToy ConvertDataToInt:lengthData];
        
        if (self.totalData.length <= length) {
            [self.totalData appendData:data];
            
            if (self.totalData.length == length) {
                
                NSString *transmitString = [[NSString alloc] initWithData:self.totalData encoding:NSUTF8StringEncoding];
                [self clearAction:nil];
                self.responseTextView.text = transmitString;
                
            }
        } else {
            [self clearAction:nil];
        }
    }
}

- (IBAction)clearAction:(id)sender {
    self.responseTextView.text = nil;
    
    //NSMutableData 清空
    [self.totalData resetBytesInRange:NSMakeRange(0, [self.totalData length])];
    [self.totalData setLength:0];
}

- (void)textViewTextDidChange:(NSNotification *)noti
{
    if ([self.passThroughTextView isFirstResponder]) {
        NSUInteger length = [self.passThroughTextView.text dataLength];
        self.passThroughLengthLabel.text = [NSString stringWithFormat:@"%@", @(length)];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.passThroughTextView) {
        self.dataStateTextView.text = [NSString stringWithFormat:@"%@", [self dataStatus]];
        
        NSString *passThroughText = self.passThroughTextView.text;
        NSData *passThroughData = [passThroughText dataUsingEncoding:NSUTF8StringEncoding];
        
        self.passThroughDataTextView.text = [NSString stringWithFormat:@"%@", passThroughData];
    }
}

- (IBAction)sendAction:(id)sender {
    
    NSUInteger dataLength = [self.passThroughTextView.text dataLength];
    [self.passThroughTextView resignFirstResponder];
    
    if (dataLength > 0xFF) {
        [SVProgressHUD showErrorWithStatus:@"发送字节长度不能大于255"];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"发送中"];
    //发送数据状态特征
    CBCharacteristic *sendDataStatusChara = [BabyToy findCharacteristicFormServices:[self.currentPeripheral.services mutableCopy] UUIDString:Transmit_Data_Status_Characteristic];
    //发送数据特征
    CBCharacteristic *sendDataChara = [BabyToy findCharacteristicFormServices:[self.currentPeripheral.services mutableCopy] UUIDString:Transmit_Data_Characteristic];
    
    if (!sendDataStatusChara || !sendDataChara) {
        [SVProgressHUD showErrorWithStatus:@"发送失败，请重新连接"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"发送数据状态..."];
    NSData *data = [self dataStatus];
    GGLog(@"发送数据状态:%@", data);
    [self.currentPeripheral writeValue:data forCharacteristic:sendDataStatusChara type:CBCharacteristicWriteWithResponse];
    
    NSString *passThroughText = self.passThroughTextView.text;
    NSData *passThroughData = [passThroughText dataUsingEncoding:NSUTF8StringEncoding];
    
    NSUInteger totalPacketNumber = passThroughData.length%kBLE_Max_Send_length == 0?passThroughData.length/kBLE_Max_Send_length:passThroughData.length/kBLE_Max_Send_length+1;
    NSUInteger serialNumber = 0;
    
    [SVProgressHUD showWithStatus:@"发送数据.."];
    for (NSUInteger i = 0; i < passThroughData.length; i+=kBLE_Max_Send_length) {
        serialNumber += 1;
        NSRange subDataRange = serialNumber < totalPacketNumber ? NSMakeRange(i, kBLE_Max_Send_length) : NSMakeRange(i, passThroughData.length - i);

        //body
        NSData *subData = [passThroughData subdataWithRange:subDataRange];
        
        NSMutableData *pillowData = [[passThroughData subdataWithRange:subDataRange] mutableCopy];
        uint32_t *bytes = pillowData.mutableBytes;
        *bytes = CFSwapInt32(*bytes);
        NSLog(@"%@", pillowData);
        
        GGLog(@"发送数据-序列号：%@, 数据：%@", @(serialNumber), subData);
        [self.currentPeripheral writeValue:subData forCharacteristic:sendDataChara type:CBCharacteristicWriteWithResponse];
        
    }
    GGLog(@"发送完成");
    [SVProgressHUD showSuccessWithStatus:@"发送完成"];
}

- (NSData *)dataStatus
{
//    uint16_t crc16 = [self.passThroughTextView.text do_crc];

    Byte status[1] = {0};
    status[0] = [self.passThroughTextView.text dataLength];
//    status[1] = ((crc16 >> 8) & 0xff);
//    status[1] = ((crc16) & 0xff);
//    status[2] = 0x1;

    NSData *data = [NSData dataWithBytes:status length:1];
    return data;
}

- (NSMutableData *)totalData
{
    if (!_totalData) {
        _totalData = [NSMutableData data];
    }
    return _totalData;
}
@end
