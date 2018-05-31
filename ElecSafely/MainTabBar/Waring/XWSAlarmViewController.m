//
//  XWSAlarmViewController.m
//  ElecSafely
//
//  Created by lhb on 2018/4/4.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSAlarmViewController.h"
#import "XWSAlarmDeviceListModel.h"
#import "ESDeviceViewController.h"
#import "XWSFliterView.h"
#import "MJRefresh.h"
#import "XWSFliterResultView.h"

static const CGFloat SectionHeight = 40.f;

#define CURRENT_VC_BACKCOLOR [UIColor colorWithRed:0.12 green:0.14 blue:0.20 alpha:1.00]

@interface XWSAlarmViewController ()<UITableViewDelegate, UITableViewDataSource, XWSFliterViewDelegate>
{
    NSMutableArray *_dataSource;
    ElecHTTPManager *_httpManager;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) XWSFliterView *fliterView;
@property (nonatomic, strong) ElecProgressHUD *progressHUD;
@property (nonatomic, strong) XWSFliterResultView *headView;
@end

@implementation XWSAlarmViewController

- (void)dealloc
{
    
}

- (ElecProgressHUD *)progressHUD{
    if (!_progressHUD) {
        _progressHUD = [[ElecProgressHUD alloc] init];
    }
    return _progressHUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
    _httpManager = [ElecHTTPManager manager];
    self.title = @"警报";
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
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_icon_filter"] style:0 target:self action:@selector(showFliterView)];
    self.navigationItem.rightBarButtonItems = @[rightItem1];
}

- (void)setUpFliterView{
    if (!_fliterView) {
        _fliterView = [[XWSFliterView alloc] initWithFrame:CGRectZero type:AlarmLog];
        _fliterView.delegate = self;
    }
}

- (void)showFliterView{
    [_fliterView show];
}

#pragma mark - XWSFliterViewDelegate
- (void)clickFliterView:(XWSFliterView *)fliterView dataSource:(NSDictionary *)dataSource{
    if (_dataSource.count == 0) [self.tableView reloadData];
    [self.headView adjustHeight:self.tableView dataSource:fliterView.dataAdapter.leftArr type:fliterView.dataAdapter.fliterType];//顶部筛选
    [self processData:dataSource];
}
- (void)showHudView{
    [self.progressHUD dismiss];
    [self.progressHUD showHUD:self.view Offset:- NavibarHeight animation:18];
}

- (void)processData:(NSDictionary *)result{
    if (![result isKindOfClass:[NSDictionary class]]) return;
    
    [_dataSource removeAllObjects];
    [self.tableView.mj_footer resetNoMoreData];
    
    NSArray *rows = result[@"rows"];
    [self addObject:rows];
    if (rows.count == 0) {
        [XWSTipsView showTipViewWithType:XWSShowViewTypeNoData inSuperView:self.view];
    }
    else {
        [XWSTipsView dismissTipViewWithSuperView:self.view];
    }
}

- (void)addObject:(NSArray *)rows{
    
    [rows enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XWSAlarmDeviceListModel *model = [[XWSAlarmDeviceListModel alloc] init];
        [model setValuesForKeysWithDictionary:obj];
        
        [_dataSource addObject:model];
    }];
    
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
    [self.progressHUD dismiss];
}

- (void)pullUpLoadMore{
    
    NSMutableDictionary *paramDic = [_fliterView.dataAdapter.requestAlarmParam mutableCopy];
    int page = [paramDic[@"page"] intValue] + 1;
    paramDic[@"page"] = [NSString stringWithFormat:@"%d",page];
    [_httpManager GET:_fliterView.dataAdapter.requestAlarmUrl parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        
        _fliterView.dataAdapter.requestAlarmParam = [paramDic copy];
        if ([resultDic isKindOfClass:NSDictionary.class]) {
            NSArray *rows = resultDic[@"rows"];
            if (rows.count == 0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [self addObject:rows];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_footer endRefreshing];
    }];
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
        self.headView = [[XWSFliterResultView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width_ES, 0)];
        _tableView.tableHeaderView = self.headView;
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
        UILabel *label = [UILabel createWithFrame:CGRectMake(0, 0, 120, 20) text:@"" textColor:[UIColor whiteColor] textAlignment:2 fontNumber:15];
        cell.accessoryView = label;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        [cell addSubview:line];
        line.backgroundColor = [UIColor colorWithRed:0.06 green:0.07 blue:0.09 alpha:1.00];
    }
    XWSAlarmDeviceListModel *model = _dataSource[indexPath.row];
    cell.textLabel.text = model.Name;
    cell.detailTextLabel.text = model.Date;
    UILabel *la = (UILabel *)cell.accessoryView;
    if ([la isKindOfClass:UILabel.class]) {
        la.text = model.AlarmType;
    }
    NSString *imageName = [self imageNameWith:model.AlarmType];
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    return cell;
}

- (NSString *)imageNameWith:(NSString *)alarmType{
    NSString *imageName = @"";
   // NSArray *names = @[@"dianliu",@"wendu",@"diaodian",@"dianya",@"loudian"];
    
    //烟雾，漏电，掉电，欠压，过压，过载，短路，温度,缺相
    if (alarmType.length > 1) {
        alarmType = [alarmType substringWithRange:NSMakeRange(0, 2)];
    }
    
    if ([alarmType containsString:@"烟雾"] || [alarmType containsString:@"温度"]) {
        imageName = @"wendu";
    }else if ([alarmType containsString:@"漏电"] || [alarmType containsString:@"掉电"]) {
        imageName = @"diaodian";
    }else if ([alarmType containsString:@"欠压"] || [alarmType containsString:@"过压"] || [alarmType containsString:@"缺相"]) {
        imageName = @"dianya";
    }else if ([alarmType containsString:@"过载"] || [alarmType containsString:@"短路"]) {
        imageName = @"loudian";
    }else{
        imageName = @"dianliu";
    }
    
    return imageName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XWSAlarmDeviceListModel *model = _dataSource[indexPath.row];
    ESDeviceViewController *deviceVC = [[ESDeviceViewController alloc] init];
    deviceVC.deviceID = model.DID;
    [self.navigationController pushViewController:deviceVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SectionHeight)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 100, SectionHeight)];
    [view addSubview:label];
    label.text = @"设备名称";
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];

    UILabel *labelType = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 16 - 100, 0, 100, SectionHeight)];
    [view addSubview:labelType];
    labelType.text = @"报警类型";
    labelType.textColor = [UIColor grayColor];
    labelType.backgroundColor = [UIColor clearColor];
    labelType.textAlignment = NSTextAlignmentRight;
    labelType.font = [UIFont systemFontOfSize:16];
    view.backgroundColor = [UIColor colorWithRed:0.08 green:0.09 blue:0.14 alpha:1.00];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return SectionHeight;
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
