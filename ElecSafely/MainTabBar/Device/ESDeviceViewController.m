//
//  ESDeviceViewController.m
//  ElecSafely
//
//  Created by lhb on 2018/1/28.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "ESDeviceViewController.h"
#import "ESDeviceView.h"
#import "ESDeviceData.h"
#import "ESDeviceDataProcessor.h"
#import "XWSDeviceBaseInfoVC.h"

@interface ESDeviceViewController ()<ESDeviceViewDelegate>
{
    ESDeviceView *_deviceView;//内容视图
}

@property (nonatomic,strong)ESDeviceView *deviceView;
@property (nonatomic,strong)ESDeviceDataProcessor *dataProcessor;
@property (nonatomic,strong)ESDeviceData *deviceData;
@property (nonatomic,strong)NSArray *chartData;
@property (nonatomic,strong) ElecProgressHUD *progressHUD;

@property (nonatomic,assign) BOOL isRequesting;

@end

@implementation ESDeviceViewController

- (ElecProgressHUD *)progressHUD{
    if (!_progressHUD) {
        _progressHUD = [[ElecProgressHUD alloc] init];
    }
    return _progressHUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self ready];
    [self requestDeviceDetailData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.progressHUD dismiss];
}

- (void)ready{
    _deviceView = [[ESDeviceView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavibarHeight)];
    _deviceView.deviceViewDele = self;
    self.view.backgroundColor = BackColor;
    [self.view addSubview:_deviceView];
    
    self.dataProcessor = [[ESDeviceDataProcessor alloc] init];
    
    [self createRightBarItem];
}

//request data
- (void)requestDeviceDetailData{
    
    [self.progressHUD showHUD:self.view Offset:- NavibarHeight animation:18];

    dispatch_group_t group = dispatch_group_create();
    
    __weak typeof(self) weakSelf = self;
    //请求设备实时信息
    dispatch_group_enter(group);
    [self.dataProcessor requestDeviceStatusDataWithDeviceID:self.deviceID success:^(ESDeviceData *deviceData) {
        
        weakSelf.deviceData = deviceData;
        weakSelf.title = deviceData.Name;
        
        dispatch_group_leave(group);
    }];
    
    /*获取设备最近7天设备查询数据信息*/
    dispatch_group_enter(group);
    [self.dataProcessor requestDeviceChartHistoryDataWithDeviceID:self.deviceID success:^(NSArray *chartData) {
        
        weakSelf.chartData = chartData;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.progressHUD dismiss];
        [self.deviceView loadDataWith:self.deviceData chartData:self.chartData];
    });
}


//refresh button
- (void)createRightBarItem{
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestDeviceDetailData)];
    self.navigationItem.rightBarButtonItem = rightItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ESDeviceViewDelegate
- (void)clickDeviceViewQueryData:(ESDeviceView *)deviceView{
    [self queryDeviceData];
}

- (void)clickDeviceViewResetData:(ESDeviceView *)deviceView{
    [self resetDeviceData];
}

- (void)resetDeviceData{
    __weak typeof(self) weakSelf = self;
    [self.dataProcessor requestDeviceResetDataWithDeviceID:self.deviceID success:^(BOOL success) {
        [weakSelf requestDeviceDetailData];
    }];
}


- (void)queryDeviceData{
    __weak typeof(self) weakSelf = self;
    [self.dataProcessor requestDeviceQueryDataWithDeviceID:self.deviceID success:^(BOOL success) {
        [weakSelf requestDeviceDetailData];
    }];
}

- (void)clickDeviceViewIntoBaseInfoVC:(ESDeviceView *)deviceView{
    XWSDeviceBaseInfoVC *baseInfoVC = [[XWSDeviceBaseInfoVC alloc] init];
    baseInfoVC.baseInfoData = self.deviceData;
    [self.navigationController pushViewController:baseInfoVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
