//
//  XWSLeftView.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/23.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSLeftView.h"
#import "UIView+HGCorner.h"
#import "LMJScrollTextView.h"
#import "NSString+XWSManager.h"
#define marginLeft 32.0f
#define TableViewMarginRightWidth 120.0f


@interface XWSLeftView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) LMJScrollTextView * scrollTextView;
@property (nonatomic, strong) UILabel *accountLabel;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *iconName;
@end

@implementation XWSLeftView

- (instancetype)initWithFrame:(CGRect)frame withUserInfo:(NSDictionary *)userInfo{
    if (self = [super initWithFrame:frame]) {
        _account = userInfo[@"account"];
        _iconName = userInfo[@"icon"];
        [self setUpUI];
    }
    return self;
}
#pragma mark -  设置界面
- (void)setUpUI{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAccountLabel) name:APPUserNameDidUpdateNotification object:nil];
    self.backgroundColor = [UIColor clearColor];
    [self coverView];
    [self tableView];
}

#pragma mark - 内部方法

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_coverView];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0;

        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tableView.mas_right);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(TableViewMarginRightWidth + ScreenWidth);
        }];
        
        _coverView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCover:)];
        [_coverView addGestureRecognizer:tap];
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCover:)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [_coverView addGestureRecognizer:swipe];
        
    }
    return _coverView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 66.0f;
        _tableView.bounces = NO;
       
        _tableView.backgroundColor = leftLeftBackColor;
        [self addSubview:_tableView];
        _tableView.frame = CGRectMake(0, 0, ScreenWidth - TableViewMarginRightWidth, ScreenHeight);

        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 175)];
        [self setUpHeadView:headView];
        headView.userInteractionEnabled = YES;
        _tableView.tableHeaderView = headView;

        UITapGestureRecognizer *icoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIcon:)];
        [headView addGestureRecognizer:icoTap];
    }
    return _tableView;
}

- (void)setUpHeadView:(UIView *)supView{
    //头像
    self.icon = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.icon.userInteractionEnabled = YES;
    [supView addSubview:self.icon];

    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(70);
        make.left.mas_equalTo(32);
        make.width.height.mas_equalTo(69);
    }];
    if (_iconName == nil || [_iconName isEqualToString:@" "]) {
        self.icon.image = [UIImage imageNamed:@"loading_shape_rectangular"];
    }else{
        self.icon.image = [UIImage imageNamed:_iconName];
    }
    
    [self.icon hg_setAllCornerWithCornerRadius:34.5];
    
    //账号
    CGFloat accountStrWidth = [NSString getStringSizeWith:_account withStringFont:PingFangMedium(18)].width;
    CGFloat accountViewWidth = supView.frame.size.width - 32 - 69 - 2 * 17;

    if (accountStrWidth > accountViewWidth) {
        [self setUpScrollTextViewWithSuperView:supView];
    }else{
        [self setUpStaticTextViewWithSuperView:supView];
    }
}

- (void)setUpStaticTextViewWithSuperView:(UIView *)supView{
    if (!_accountLabel) {
        _accountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [supView addSubview:_accountLabel];
        [_accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.icon.mas_centerY);
            make.left.equalTo(self.icon.mas_right).mas_equalTo(17);
            make.right.mas_equalTo(-17);
            make.height.mas_equalTo(30);
        }];
        
        if (_account == nil || [_account isEqualToString:@" "]) {
            _accountLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
        }
        else{
            _accountLabel.text = _account;
        }
        
        _accountLabel.textColor = LeftViewTextColor;
        _accountLabel.font = PingFangMedium(18);
    }
}

- (void)updateAccountLabel {
    if (_accountLabel) {
        _accountLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
    }
}


- (void)setUpScrollTextViewWithSuperView:(UIView *)supView{
    
    if (!_scrollTextView) {
        _scrollTextView = [[LMJScrollTextView alloc] initWithFrame:CGRectZero textScrollModel:LMJTextScrollWandering direction:LMJTextScrollMoveLeft];
        [_scrollTextView setMoveSpeed:0.1];
        [supView addSubview:_scrollTextView];
        [_scrollTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.icon.mas_centerY);
            make.left.equalTo(self.icon.mas_right).mas_equalTo(17);
            make.right.mas_equalTo(-17);
            make.height.mas_equalTo(30);
        }];
        
        NSString *account = _account;
        if (_account == nil || [_account isEqualToString:@" "]) {
            _accountLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
        }
        
        [_scrollTextView startScrollWithText:account textColor:LeftViewTextColor font:PingFangMedium(18)];
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XWSLeftViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"XWSLeftViewCell"];
        
        //设置图片
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        headImageView.tag = indexPath.row + 100;
        [cell.contentView addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(32);
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.width.height.mas_equalTo(29);
        }];
        
        //设置标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [cell.contentView addSubview:titleLabel];
        titleLabel.tag = indexPath.row + 200;
        titleLabel.font = PingFangRegular(17);
        titleLabel.textColor = LeftViewTextColor;
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(headImageView.mas_centerY);
            make.left.mas_equalTo(headImageView.mas_right).mas_equalTo(21);
        }];

        cell.backgroundColor = leftLeftBackColor;
    }
    
    UIImageView *iconImageView = (UIImageView *)[cell.contentView viewWithTag:indexPath.row + 100];
    
    UILabel *titleLab = (UILabel *)[cell.contentView viewWithTag:indexPath.row + 200];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
            iconImageView.image = [UIImage imageNamed:@"left_devices_list"];
            titleLab.text = @"设备列表";
            break;
        case 1:
            iconImageView.image = [UIImage imageNamed:@"left_alarm"];
            titleLab.text = @"报警记录";
            break;
        case 2:
            iconImageView.image = [UIImage imageNamed:@"left_statistics"];
            titleLab.text = @"统计";
            break;
        case 3:
            iconImageView.image = [UIImage imageNamed:@"left_feedback"];
            titleLab.text = @"意见反馈";
            break;
        case 4:
            iconImageView.image = [UIImage imageNamed:@"left_help"];
            titleLab.text = @"帮助";
            break;
        case 5:
            iconImageView.image = [UIImage imageNamed:@"left_scan"];
            titleLab.text = @"扫一扫";
            break;
        case 6:
            iconImageView.image = [UIImage imageNamed:@"left_setting"];
            titleLab.text = @"设置";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XWSTouchItem item = XWSTouchItemUserInfo;
    switch (indexPath.row) {
        case 0:
            item = XWSTouchItemDevicesList;
            break;
        case 1:
            item = XWSTouchItemAlarm;
            break;
        case 2:
            item = XWSTouchItemStatistics;
            break;
        case 3:
            item = XWSTouchItemFeedback;
            break;
        case 4:
            item = XWSTouchItemHelp;
            break;
        case 5:
            item = XWSTouchItemScan;
            break;
        case 6:
            item = XWSTouchItemSetting;
            break;
            
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(touchLeftView:byType:)]) {
        [self.delegate touchLeftView:self byType:item];
    }
}

#pragma mark - 手势操作
//点击蒙版
- (void)clickCover:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(touchLeftView:byType:)]) {
        [self.delegate touchLeftView:self byType:XWSTouchItemCoverView];
    }
}
//向左滑动蒙版
- (void)swipeCover:(UISwipeGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(touchLeftView:byType:)]) {
        [self.delegate touchLeftView:self byType:XWSTouchItemCoverView];
    }
}

//点击头像或者账号
- (void)tapIcon:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(touchLeftView:byType:)]) {
        [self.delegate touchLeftView:self byType:XWSTouchItemUserInfo];
    }
}

#pragma mark - 动画
- (void)startCoverViewOpacityWithAlpha:(CGFloat)alpha withDuration:(CGFloat)duration{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:alpha];
    opacityAnimation.duration = duration;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    [_coverView.layer addAnimation:opacityAnimation forKey:@"opacity"];
    _coverView.alpha = alpha;
}

- (void)cancelCoverViewOpacity{
    [_coverView.layer removeAllAnimations];
    _coverView.alpha = 0;
}

@end
