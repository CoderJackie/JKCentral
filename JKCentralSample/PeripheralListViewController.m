//
//  PeripheralListViewController.m
//  BabyBluetoothAppDemo
//
//  Created by xujiaqi on 2018/1/17.
//  Copyright © 2018年 CoderJackie. All rights reserved.
//

#import "PeripheralListViewController.h"
#import "BabyBluetooth.h"
#import "SVProgressHUD.h"
#import "PeripheralDetailViewController.h"
#import "BluetoothUUIDHeader.h"
#import "PassThroughViewController.h"

@interface PeripheralListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *peripheralDataArray;
    BabyBluetooth *baby;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *indicatorContainerView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@end

@implementation PeripheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    peripheralDataArray = [[NSMutableArray alloc]init];
    
    self.navigationItem.titleView = self.indicatorContainerView;
    
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    
//    CFByteOrder byteOrder = CFByteOrderGetCurrent();
//    if (byteOrder == CFByteOrderBigEndian) {
//        GGLog(@"大端模式");
//    } else if (byteOrder == CFByteOrderLittleEndian) {
//        GGLog(@"小端模式");
//    }
}

- (u_int8_t *)htonRand:(void *)byte length:(NSUInteger)length
{
    u_int8_t *result = malloc(length);
    for ( int i = 0; i < length; i ++) {
        *(result + i) = *((u_int8_t *)(byte + length - i - 1));
    }
    
    NSString *key = @"";
    for ( int i = 0; i < length ; i ++) {
        key = [NSString stringWithFormat:@"%@%02hhX",key,*((u_int8_t *)byte + i)];
    }
    NSLog(@"Byte: %@",key);
    
    key = @"";
    for ( int i = 0; i < length ; i ++) {
        key = [NSString stringWithFormat:@"%@%02hhX",key,*(result + i)];
    }
    NSLog(@"Result: %@",key);
    return  result;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startScan:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopScan:nil];
}

- (IBAction)startScan:(id)sender {
    baby.channel(@"T-BOX").scanForPeripherals().begin();
    [self.indicatorView startAnimating];
    self.indicatorContainerView.hidden = NO;
}

- (IBAction)stopScan:(id)sender {
    [baby cancelScan];
    [self.indicatorView stopAnimating];
    self.indicatorContainerView.hidden = YES;
    
//    PassThroughViewController *vc = [[PassThroughViewController alloc] init];
//
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -蓝牙配置和操作

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateStateAtChannel:@"T-BOX" block:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"蓝牙打开成功，开始扫描设备"];
        } else {
            [SVProgressHUD showInfoWithStatus:@"请打开蓝牙"];
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripheralsAtChannel:@"T-BOX" block:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        GGLog(@"搜索到了设备:%@",peripheral.name);
        [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI];
    }];
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripheralsAtChannel:@"T-BOX" filter:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (peripheralName.length >0) {
            return YES;
        }
        return NO;
    }];
    
    //    CBConnectPeripheralOptionNotifyOnConnectionKey    默认为NO，APP被挂起时，这时如果连接到peripheral时，是否要给APP一个提示框。
    //    CBConnectPeripheralOptionNotifyOnDisconnectionKey 默认为NO，APP被挂起时，恰好在这个时候断开连接，要不要给APP一个断开提示。
    //    CBConnectPeripheralOptionNotifyOnNotificationKey  默认为NO，APP被挂起时，是否接受到所有的来自peripheral的包都要弹出提示框。
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@NO};
    NSDictionary *connectPeripheralWithOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES, CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES, CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    NSArray *serviceUUIDs = @[[CBUUID UUIDWithString:Pass_Through_Service], [CBUUID UUIDWithString:Share_State_Synchronize_Service]];
    
    [baby setBabyOptionsAtChannel:@"T-BOX" scanForPeripheralsWithOptions:nil connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSArray *peripherals = [peripheralDataArray valueForKey:@"peripheral"];
    if(![peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        [peripheralDataArray addObject:item];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark -table委托 table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return peripheralDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
    NSNumber *RSSI = [item objectForKey:@"RSSI"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
    NSString *peripheralName;
    if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
        peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
    }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
        peripheralName = peripheral.name;
    }else{
        peripheralName = [peripheral.identifier UUIDString];
    }
    
    cell.textLabel.text = peripheralName;
    //信号和服务
    cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%@",RSSI];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //停止扫描
    [baby cancelScan];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PeripheralDetailViewController *vc = [[PeripheralDetailViewController alloc] init];
    NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    vc.currentPeripheral = peripheral;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)indicatorContainerView
{
    if (!_indicatorContainerView) {
        _indicatorContainerView = [[UIView alloc] init];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        label.text = @"正在搜索中";
        [label adjustsFontSizeToFitWidth];
        [_indicatorContainerView addSubview:label];
        [_indicatorContainerView addSubview:self.indicatorView];
        
        _indicatorContainerView.frame = CGRectMake(0, 0, label.frame.size.width+40, 40);
    }
    return _indicatorContainerView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.frame = CGRectMake(80, 0, 40, 40);
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}
@end
