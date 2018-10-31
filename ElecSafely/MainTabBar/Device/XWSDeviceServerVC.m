//
//  XWSDeviceServerVC.m
//  ElecSafely
//
//  Created by Tianfu on 26/09/2018.
//  Copyright © 2018 Tianfu. All rights reserved.
//

#define CURRENT_BACKCOLOR [UIColor colorWithRed:0.12 green:0.14 blue:0.20 alpha:1.00]

#import "XWSDeviceServerVC.h"
#import "XWSDeviceServerCell.h"
#import "MJRefresh.h"

@interface XWSDeviceServerVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy) NSMutableArray *dataSource;
@property (nonatomic, strong) ElecHTTPManager *httpManager;
@property (nonatomic, strong) ElecProgressHUD *progressHUD;
@property (nonatomic, strong) UITableView *serverTableView;
@end

@implementation XWSDeviceServerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务";
    self.view.backgroundColor = CURRENT_BACKCOLOR;
    _dataSource = [NSMutableArray array];
    _httpManager = [ElecHTTPManager manager];
    [self.progressHUD showHUD:self.view Offset:- NavibarHeight animation:18];
    [self loadData:NO];
    [self createUI];
}

- (void)loadData:(BOOL)aMonth {
    NSString *startDate = @"";
    if (aMonth) {
        startDate = [self loadOneMonthAgo];
    }
    
    NSDictionary *para = @{@"ID":self.baseInfoData.ID?:@"",@"SD":startDate,@"ED":@""};
    [_httpManager GET:FrigateAPI_DeviceServerHistory parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSArray *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        
        
        
        if (_dataSource.count > 0) {
            [_dataSource removeAllObjects];
        }
        else {
//            [self showNoDataView];
        }
        [_dataSource addObjectsFromArray:resultDic];
        [_serverTableView.mj_header endRefreshing];
        [_serverTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_serverTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        if (aMonth) {
            [_serverTableView.mj_header setState:MJRefreshStateNoMoreData];
        }
        [_serverTableView reloadData];
        NSLog(@"123");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)createUI {
    _serverTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.bounds.size.height - NavibarHeight) style:UITableViewStylePlain];
    _serverTableView.dataSource = self;
    _serverTableView.delegate = self;
    _serverTableView.backgroundColor = CURRENT_VC_BACKCOLOR;
    _serverTableView.rowHeight = 130.f;
    _serverTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownLoadMore)];
    [_serverTableView registerClass:[XWSDeviceServerCell class] forCellReuseIdentifier:@"serverCell"];
    [header setTitle:@"查询一个月的服务信息" forState: MJRefreshStateIdle];
    _serverTableView.mj_header = header;
    [self.view addSubview:_serverTableView];
}

//- (void)showNoDataView {
//    UILabel *
//}

- (void)pullDownLoadMore {
    [self loadData:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XWSDeviceServerCell *cell = [_serverTableView dequeueReusableCellWithIdentifier:@"serverCell" forIndexPath:indexPath];
    if (_dataSource.count > indexPath.row) {
        NSDictionary *dic = _dataSource[indexPath.row];
        cell.typeLabel.text = dic[@"Type"]?:@"";
        cell.dateLabel.text = dic[@"ActionDate"]?:@"";
        cell.detailLabel.text = dic[@"Detail"]?:@"";
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (NSString *)loadOneMonthAgo {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval startTime = time - 3*30*24*60*60;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:startDate];
    return str;
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
