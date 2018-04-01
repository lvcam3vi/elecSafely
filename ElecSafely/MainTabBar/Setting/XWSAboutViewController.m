//
//  XWSAboutViewController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/29.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSAboutViewController.h"

@interface XWSAboutViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *scoreBtn;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation XWSAboutViewController

- (UIView *)footerView{
    if (!_footerView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:footerView];
        
        [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(80);
        }];

        UILabel *comLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [footerView addSubview:comLabel];
        [comLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
        comLabel.textAlignment = NSTextAlignmentCenter;
        comLabel.text = @"福瑞特科技产业有限公司";
        comLabel.textColor = UIColorRGB(0xAAAAAA);
        comLabel.font = PingFangRegular(17);
        _footerView = footerView;
    }
    return _footerView;
}

- (UIView *)headView{
    if (!_headView) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 190)];
        [self.view addSubview:headView];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        [headView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(60);
            make.height.mas_equalTo(32);
            make.width.mas_equalTo(146);
        }];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
        NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [dict objectForKey:@"CFBundleShortVersionString"];
        title.text = [NSString stringWithFormat:@"v%@",version];
        title.font = PingFangRegular(17);
        title.textColor = UIColorRGB(0xAAAAAA);
        [headView addSubview:title];
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(imageView.mas_bottom).mas_equalTo(20);
            make.centerX.mas_equalTo(self.view.centerX);
            make.height.mas_equalTo(20);
            
        }];
        
        _headView = headView;
    }
    return _headView;
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = BackColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(_headView.mas_bottom).mas_equalTo(0);
            make.bottom.mas_equalTo(_footerView.mas_top).mas_equalTo(0);
        }];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
}

- (void)setUpView{
    
    self.title = @"关于";
    self.view.backgroundColor = BackColor;
    
    [self headView];
    [self footerView];
    [self tableView];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.backgroundColor = NavColor;
    }
    
    cell.textLabel.text = @"去评分";
    cell.textLabel.textColor = RGBA(221, 221, 221, 1);
    cell.textLabel.font = PingFangRegular(17);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APPID&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                NSLog(@"打开去评分");
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }else{
        NSLog(@"无法打开该URL");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
