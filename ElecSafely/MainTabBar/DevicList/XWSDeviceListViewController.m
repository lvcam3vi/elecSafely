//
//  XWSDeviceListViewController.m
//  ElecSafely
//
//  Created by lhb on 2018/4/4.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSDeviceListViewController.h"
#import "XWSDeviceListModel.h"
#import "ESDeviceViewController.h"
#import "XWSFliterView.h"
#import "MJRefresh.h"

static const CGFloat SectionHeight = 50.f;

#define CURRENT_VC_BACKCOLOR [UIColor colorWithRed:0.12 green:0.14 blue:0.20 alpha:1.00]

@interface XWSDeviceListViewController ()<UITableViewDelegate, UITableViewDataSource, XWSFliterViewDelegate>
{
    NSMutableArray *_dataSource;
}
    
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) XWSFliterView *fliterView;
@property (nonatomic, strong) ElecProgressHUD *progressHUD;

@end

@implementation XWSDeviceListViewController

- (ElecProgressHUD *)progressHUD{
    if (!_progressHUD) {
        _progressHUD = [[ElecProgressHUD alloc] init];
    }
    return _progressHUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设备列表";
    self.view.backgroundColor = CURRENT_VC_BACKCOLOR;
    _dataSource = [NSMutableArray array];
    
    [self setUpFliterView];
    [self setUpNav];
    [self.progressHUD showHUD:self.view Offset:- NavibarHeight animation:18];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.progressHUD dismiss];
}
#pragma mark - 设置导航、右边侧边栏
- (void)setUpNav{
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_setting"] style:0 target:self action:@selector(showFliterView)];
    self.navigationItem.rightBarButtonItems = @[rightItem1];
}

- (void)setUpFliterView{
    if (!_fliterView) {
        _fliterView = [[XWSFliterView alloc] initWithFrame:CGRectZero type:DevicesMonitoring];
        _fliterView.delegate = self;
    }
}

- (void)showFliterView{
    [_fliterView show];
}

#pragma mark - XWSFliterViewDelegate
- (void)clickFliterView:(XWSFliterView *)fliterView dataSource:(NSDictionary *)dataSource{
    [self processData:dataSource];
}

- (void)processData:(NSDictionary *)result{
    if (![result isKindOfClass:[NSDictionary class]]) return;
    
    [_dataSource removeAllObjects];
    [self.tableView.mj_footer resetNoMoreData];
    [self.progressHUD dismiss];

    NSArray *rows = result[@"rows"];
    [rows enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XWSDeviceListModel *model = [[XWSDeviceListModel alloc] init];
        [model setValuesForKeysWithDictionary:obj];
        
        [_dataSource addObject:model];
    }];
    
    [self.tableView reloadData];
}

- (void)pullUpLoadMore{
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

#pragma mark - tableView
- (UITableView *)tableView{
    
    if (_tableView == nil){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.rowHeight = 75.f;
        _tableView.backgroundColor = CURRENT_VC_BACKCOLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullUpLoadMore)];
    }
    
    return _tableView;
}
    

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        cell.backgroundColor = CURRENT_VC_BACKCOLOR;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = FONT(17);
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = FONT(13);
        UILabel *label = [UILabel createWithFrame:CGRectMake(0, 0, 40, 20) text:@"" textColor:[UIColor grayColor] textAlignment:1 fontNumber:14];
        cell.accessoryView = label;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        [cell addSubview:line];
        line.backgroundColor = [UIColor colorWithRed:0.06 green:0.07 blue:0.09 alpha:1.00];
    }
    XWSDeviceListModel *model = _dataSource[indexPath.row];
    cell.textLabel.text = model.Name;
    cell.detailTextLabel.text = model.AlarmText;
    if ([model.Alarm isEqualToString:@"1"]){
        cell.imageView.image = [UIImage imageNamed:@"loudian"];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"dianliu"];
    }
    UILabel *la = (UILabel *)cell.accessoryView;
    if ([la isKindOfClass:UILabel.class]) {
        la.text = [self showDate:model.UpdataDate];
    }
    return cell;
}

- (NSString *)showDate:(NSString *)date{
    NSArray *arr1 = [date componentsSeparatedByString:@" "];
    NSString *time = arr1.lastObject;
    NSArray *arr2 = [time componentsSeparatedByString:@":"];
    NSString *result = @"";
    if (arr2.count > 1) {
        result = [arr2[0] stringByAppendingFormat:@":%@",arr2[1]];
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XWSDeviceListModel *model = _dataSource[indexPath.row];
    ESDeviceViewController *deviceVC = [[ESDeviceViewController alloc] init];
    deviceVC.deviceID = model.ID;
    [self.navigationController pushViewController:deviceVC animated:YES];
}
    
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SectionHeight)];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.view.bounds.size.width, SectionHeight)];
//    [view addSubview:label];
//    label.text = @"设备列表";
//    label.textColor = [UIColor whiteColor];
//    view.backgroundColor = CURRENT_VC_BACKCOLOR;
    return nil;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return SectionHeight;
    return 0.0;
}
    
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
