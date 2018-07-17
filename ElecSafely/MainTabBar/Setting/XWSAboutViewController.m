//
//  XWSAboutViewController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/29.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSAboutViewController.h"
#import "JTSlideShadowAnimation.h"
#import "ElecTipsView.h"

@interface XWSAboutViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *scoreBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *comLabel;
@property (nonatomic, strong) JTSlideShadowAnimation *shadowAnimation;
@end

@implementation XWSAboutViewController

- (UILabel *)comLabel{
    if (!_comLabel) {
        _comLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_footerView addSubview:_comLabel];
        [_comLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
        _comLabel.textAlignment = NSTextAlignmentCenter;
        _comLabel.text = @"中山市福瑞特科技产业有限公司";
        _comLabel.textColor = UIColorRGB(0xAAAAAA);
        _comLabel.font = PingFangRegular(17);
    }
    return _comLabel;
}

- (UIView *)footerView{
    if (!_footerView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:footerView];
        
        [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(80);
        }];
        _footerView = footerView;
    }
    return _footerView;
}

- (UIView *)headView{
    if (!_headView) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 263)];
        [self.view addSubview:headView];

        UIImageView *heImageView = [[UIImageView alloc] init];
        heImageView.image = [UIImage imageNamed:@"loading_shape_rectangular"];
        [headView addSubview:heImageView];
        [heImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(20);
            make.width.height.mas_equalTo(121);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        [headView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(heImageView.mas_bottom).mas_equalTo(20);
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.shadowAnimation start];
}

- (void)setUpView{
    
    self.title = @"关于";
    self.view.backgroundColor = BackColor;
    
    [self headView];
    [self footerView];
    [self comLabel];
    [self tableView];
    
    [self setCompanyAnimotion];
}

- (void)setCompanyAnimotion{
    self.shadowAnimation = [JTSlideShadowAnimation new];
    self.shadowAnimation.shadowForegroundColor = [UIColor whiteColor];
    self.shadowAnimation.shadowBackgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.7];
    self.shadowAnimation.animatedView = self.comLabel;
    self.shadowAnimation.shadowWidth = 40.;
    self.shadowAnimation.duration = 3.0;
    
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
        cell.textLabel.textColor = RGBA(221, 221, 221, 1);
        cell.textLabel.font = PingFangRegular(17);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = @"去评分";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/id1375551874"];

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
//                NSLog(@"打开去评分");
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }else{
        [ElecTipsView showTips:@"无法跳转到appStore" during:2.0];

    }
}

- (void)dealloc{
    [self.shadowAnimation stop];
    self.shadowAnimation = nil;
    
//    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
