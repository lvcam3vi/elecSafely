//
//  XWSFliterView.m
//  ElecSafely
//
//  Created by lhb on 2018/3/23.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSFliterView.h"

//#define rightBackColor RGBA(20, 25, 33, 1)

#define rightBackColor NavColor

#define leftMarginWidth 60.0
#define SureBtnTag 100
#define CloseBtnTag 101
#define LeftTableViewRowHeight 54.0
#define RightTableViewRowHeight LeftTableViewRowHeight

@interface XWSFliterView()<UITableViewDelegate,UITableViewDataSource,XWSFliterDataAdapterDelegate>
{
    FliterEnterType _fliterType;
    
    UIDatePicker *_datePicker;
}
@property (nonatomic, strong) UIView *coverView;
/*左侧的数据表*/
@property (nonatomic, strong) UITableView *leftTableView;
/*右侧的数据表*/
@property (nonatomic, strong) UITableView *rightTableView;
/*自定义的导航栏*/
@property (nonatomic, strong) UIView *navView;
/*导航栏关闭按钮*/
@property (nonatomic, strong) UIButton *closeBtn;
/*导航栏确定按钮*/
@property (nonatomic, strong) UIButton *sureBtn;
/*导航栏标题*/
@property (nonatomic, strong) UILabel *titleLabel;

/*左侧当前选中的model*/
@property (nonatomic, strong) XWSFliterConditionModel *selectLeftModel;
/*左侧当前选中的行*/
@property (nonatomic, assign) NSInteger selectLeftRow;

/*没有功能View*/
@property (nonatomic, strong) UIView *NoDataView;


@end

@implementation XWSFliterView

- (instancetype)initWithFrame:(CGRect)frame type:(FliterEnterType)type{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setUpUI];
        
        _fliterType = type;
        
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(ScreenWidth);
        }];
        self.hidden = YES;
        self.selectLeftRow = 0;
        self.dataAdapter = [[XWSFliterDataAdapter alloc] initWithType:type];
        self.dataAdapter.delegate = self;
        [self.dataAdapter requestCustomerList];
    }
    return self;
}
#pragma mark - 懒加载
- (void)drawRect:(CGRect)rect {
    
}
- (UIView *)NoDataView{
    if (!_NoDataView) {
        _NoDataView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_NoDataView];
        _NoDataView.backgroundColor = NavColor;
        [_NoDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.navView.mas_bottom);
            make.width.mas_equalTo(ScreenWidth - leftMarginWidth);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        //添加标题
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_NoDataView addSubview:tipLabel];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = PingFangRegular(16);
        tipLabel.textColor = RGBA(170, 170, 170, 1);
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_NoDataView.mas_centerX);
            make.top.mas_equalTo(297);
            
        }];
        tipLabel.text = @"暂无数据";
    }
    return _NoDataView;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_coverView];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0;
        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(leftMarginWidth + ScreenWidth);
        }];
        
        _coverView.userInteractionEnabled = YES;
        
        //蒙版添加手势事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCover:)];
        [_coverView addGestureRecognizer:tap];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCover:)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [_coverView addGestureRecognizer:swipe];
        
    }
    return _coverView;
}

- (UITableView *)rightTableView{
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.backgroundColor = rightBackColor;
        _rightTableView.tableFooterView = [[UIView alloc] init];
        _rightTableView.showsVerticalScrollIndicator = NO;
        _rightTableView.showsHorizontalScrollIndicator = NO;
        
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _rightTableView.rowHeight = RightTableViewRowHeight;
        _rightTableView.estimatedRowHeight = RightTableViewRowHeight;
        [self addSubview:_rightTableView];
        
        [_rightTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.navView.mas_bottom);
            make.left.mas_equalTo(_leftTableView.mas_right);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
    }
    return _rightTableView;
}

- (UITableView *)leftTableView{
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.backgroundColor = BackColor;
        _leftTableView.tableFooterView = [[UIView alloc] init];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftTableView.showsVerticalScrollIndicator = NO;
        _leftTableView.showsHorizontalScrollIndicator = NO;
        _leftTableView.rowHeight = LeftTableViewRowHeight;
        _leftTableView.estimatedRowHeight = LeftTableViewRowHeight;
        [self addSubview:_leftTableView];

        [_leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.navView.mas_bottom);
            make.left.mas_equalTo(self.coverView.mas_right).mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(100);
        }];
    }
    return _leftTableView;
}

#pragma Mark- 标题
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"筛选";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = PingFangMedium(17);
    }
    return _titleLabel;
}

#pragma mark - 确定按钮
- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sureBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _sureBtn.titleLabel.font = PingFangMedium(15);
        _sureBtn.tag = SureBtnTag;
        [_sureBtn addTarget:self action:@selector(clickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

#pragma mark - 关闭按钮
- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeBtn.tag = CloseBtnTag;
        [_closeBtn addTarget:self action:@selector(clickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

#pragma mark - 自定义的导航View
- (UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_navView];
        _navView.backgroundColor = rightBackColor;
        
        CGFloat h = NavibarHeight;
        CGFloat t = 0;
        CGFloat t1 = 27;
        //适配iPhoneX
        if (IS_IPHINE_X) {
            t = 44;
            h = 44;
            t1 = 7;
        }
        [_navView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(t);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(h);
            make.width.mas_equalTo(ScreenWidth - leftMarginWidth);
        }];
    
        [_navView addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.top.mas_equalTo(t1);
            make.width.height.mas_equalTo(30);
        }];
        
        [_navView addSubview:self.sureBtn];
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-17);
            make.top.mas_equalTo(_closeBtn.mas_top);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(self.closeBtn.mas_height);
        }];
        
        [_navView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.sureBtn.mas_left);
            make.top.mas_equalTo(self.closeBtn.mas_top);
            make.height.mas_equalTo(30);
            make.left.mas_equalTo(self.closeBtn.mas_right);
        }];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:line];
        line.backgroundColor = DarkBack;
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(0.3);
            make.top.mas_equalTo(_navView.mas_bottom).mas_equalTo(-0.3);
            make.width.mas_equalTo(_navView.mas_width);
        }];
    }
    return _navView;
}

#pragma mark - 设置界面
- (void)setUpUI{
    [self navView];
    [self coverView];
    [self leftTableView];
    [self rightTableView];
    [self NoDataView];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _leftTableView) {
        return self.dataAdapter.leftArr.count;
    }

    //默认第一个
    if (_selectLeftModel == nil) {
        _selectLeftModel = self.dataAdapter.leftArr.firstObject;
    }
    
    if (tableView == _rightTableView) {
        if ([_selectLeftModel.leftKeyName isEqualToString:KeyCustomerName]
            ||[_selectLeftModel.leftKeyName isEqualToString:KeyCustomerGroup]) {
            return _selectLeftModel.rightArr.count;
        }
        if ([_selectLeftModel.leftKeyName isEqualToString:KeyDeviceStatus]) {
            return _selectLeftModel.statusArr.count;
        }
        
        if ([_selectLeftModel.leftKeyName isEqualToString:KeyDeviceName]) {
            return _selectLeftModel.rightArr.count;
        }
        
        if ([_selectLeftModel.leftKeyName isEqualToString:KeyAlarmType]) {
            return _selectLeftModel.alarmArr.count;
        }
        
        if ([_selectLeftModel.leftKeyName isEqualToString:KeyAlarmDateScope]) {
            return 2;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XWSRightCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XWSRightCell"];
        if (tableView == _rightTableView) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
            line.backgroundColor = DarkBack;
            [cell addSubview:line];
            /*在这里使用masonry控制，会爆出约束冲突，但是不影响使用，所以就不管了*/

            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.left.mas_equalTo(17);
                make.bottom.mas_equalTo(-0.3);
                make.height.mas_equalTo(0.3);
            }];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (tableView == _leftTableView) {
        cell = [self setUpLeftCellWithTableViewCell:cell withIndexPath:indexPath];
        return cell;
        
    }else{
        cell = [self setUpRightCellWithTableViewCell:cell withIndexPath:indexPath];
        return cell;
    }
}

- (UITableViewCell *)setUpRightCellWithTableViewCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.text = [self getRightDataWithIndex:indexPath.row];
    
    if (indexPath.row == _selectLeftModel.selectRightRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.tintColor = [UIColor whiteColor];
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = RGBA(153, 153, 153, 1);
    }
    
    cell.textLabel.font = PingFangMedium(17);
    cell.backgroundColor = rightBackColor;
    return cell;
}

- (UITableViewCell *)setUpLeftCellWithTableViewCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    
    NSString *name = [self getLeftDataWithIndex:indexPath.row];
    cell.textLabel.text = name;
    if (indexPath.row == self.selectLeftRow) {
        cell.backgroundColor = rightBackColor;
        cell.textLabel.textColor = [UIColor whiteColor];
    }else{
        cell.backgroundColor = BackColor;
        cell.textLabel.textColor = RGBA(153, 153,153, 1);
    }
    cell.textLabel.font = PingFangMedium(15);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.leftTableView) {
        //设置左侧
        _selectLeftModel = self.dataAdapter.leftArr[indexPath.row];
        self.selectLeftRow = indexPath.row;
        [self.leftTableView reloadData];
        [self clickLeftCell];
    }else{
        _selectLeftModel.selectRightRow = indexPath.row;
        [self clickRightCellIndex:_selectLeftModel.selectRightRow];
    }
    
    [self.rightTableView reloadData];
}

/*点击左边cell*/
- (void)clickLeftCell{
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyCustomerName]) {
        if (_selectLeftModel.rightArr.count == 0) {/*右边为空才去请求*/
            [self.dataAdapter requestCustomerList];
        }
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyCustomerGroup]) {
        if (_selectLeftModel.rightArr.count == 0) {
            XWSFliterConditionModel *model = [self.dataAdapter getModel:KeyCustomerName];
            [self.dataAdapter requestGroupList:model.customerID];
        }
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyDeviceName]) {
        if (_selectLeftModel.rightArr.count == 0) {
            [self.dataAdapter requestDevicesList];
        }
    }
}

/*点击右边cell*/
- (void)clickRightCellIndex:(NSInteger)index{
    
    /*修改被选中筛选条件的各个id*/
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyCustomerName]) {
        XWSFliterCustomer *customer = _selectLeftModel.rightArr[index];
        if (![_selectLeftModel.customerID isEqualToString:customer.customerID]) {
            _selectLeftModel.customerID = customer.customerID;//记录选中了哪个客户
            [self.dataAdapter requestGroupList:customer.customerID];//选中的客户名称发生改变，下属客户分组和客户设备更新
        }
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyCustomerGroup]) {
        XWSFliterGroup *group = _selectLeftModel.rightArr[index];
        if (![_selectLeftModel.groupID isEqualToString:group.groupID]) {
            _selectLeftModel.groupID = group.groupID;//记录选中了哪个客户分组
            if (_fliterType == AlarmLog || _fliterType == Statistic) {
                [self.dataAdapter requestDevicesList];//在警报页面，选中的客户分组发生改变，下属客户设备更新
            }
        }
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyDeviceStatus]) {
        _selectLeftModel.status = [NSString stringWithFormat:@"%@",@(index)];
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyDeviceName]) {
        XWSDeviceListModel *device = _selectLeftModel.rightArr[index];
        _selectLeftModel.deviceID = device.ID;
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyAlarmType]) {
        _selectLeftModel.alarmType = _selectLeftModel.alarmArrEn[index];
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyAlarmDateScope]) {
        [self showDatePicker];
    }
}

#pragma mark - 选择日期
- (void)showDatePicker{
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    if (_datePicker == nil) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, self.height_ES)];
        [self addSubview:backView];
        backView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        backView.hidden = YES;
        backView.alpha = 0;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelectDate)];
        [backView addGestureRecognizer:tapGes];

        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.height_ES - 168, ScreenWidth, 168)];
        [backView addSubview:_datePicker];
        _datePicker.backgroundColor = [UIColor whiteColor];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        [_datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"]];
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        //设置字体颜色
//        [_datePicker setValue:kColor3C3C3C forKeyPath:@"textColor"];
        NSDate *minDate = [fmt dateFromString:[_selectLeftModel startDateMin]];
        NSDate *maxDate = [fmt dateFromString:[_selectLeftModel endDateMax]];
        _datePicker.maximumDate = maxDate;
        _datePicker.minimumDate = minDate;
        
        UIView *barV = [[UIView alloc] initWithFrame:CGRectMake(0, _datePicker.top_ES - 40, ScreenWidth, 40)];
        [backView addSubview:barV];
        barV.backgroundColor = [UIColor whiteColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, barV.height_ES - 0.3, barV.width_ES, 0.3)];
        [barV addSubview:line];
        line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, barV.height_ES)];
        [barV addSubview:cancelBtn];
        UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(barV.width_ES - 80, 0, 80, barV.height_ES)];
        [barV addSubview:sureBtn];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelSelectDate) forControlEvents:UIControlEventTouchUpInside];
        [sureBtn addTarget:self action:@selector(sureSelectDate) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (_selectLeftModel.selectRightRow == 0) {
        [_datePicker setDate:[fmt dateFromString:_selectLeftModel.startDate]];
    }else{
        [_datePicker setDate:[fmt dateFromString:_selectLeftModel.endDate]];
    }

    [self animationDatePicker:YES];
}

/*日期发生改变*/
- (void)dateChanged:(UIDatePicker *)datePicker{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    if (_selectLeftModel.selectRightRow == 0) {
        NSDate *endDate = [formatter dateFromString:_selectLeftModel.endDate];
        NSComparisonResult compare = [datePicker.date compare:endDate];
        if (compare == NSOrderedDescending) {//开始日期不能大于结束日期
            [datePicker setDate:endDate];
        }
    }else{
        NSDate *startDate = [formatter dateFromString:_selectLeftModel.startDate];
        NSComparisonResult compare = [datePicker.date compare:startDate];
        if (compare == NSOrderedAscending) {//结束日期不能小于开始日期
            [datePicker setDate:startDate];
        }
    }
}

- (void)animationDatePicker:(BOOL)show{
    
    if (show) {
        _datePicker.superview.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _datePicker.superview.alpha = 1;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            _datePicker.superview.alpha = 0;
        } completion:^(BOOL finished) {
            _datePicker.superview.hidden = YES;
        }];
    }
}

/*确认选择日期*/
- (void)sureSelectDate{
    
    NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:_selectLeftModel.selectRightRow inSection:0];
    NSInteger rows = [self.rightTableView numberOfRowsInSection:0];
    if (currentIndex.row >= rows) {
        return;
    }
    UITableViewCell *cell = [self.rightTableView cellForRowAtIndexPath:currentIndex];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:[_datePicker date]];
    cell.textLabel.text = str;
    
    if (_selectLeftModel.selectRightRow == 0) {
        _selectLeftModel.startDate = str;
    }else{
        _selectLeftModel.endDate = str;
    }
    
    [self animationDatePicker:NO];
}


/*取消选择日期*/
- (void)cancelSelectDate{
    
    [self animationDatePicker:NO];
}


#pragma mark - 点击以及手势事件
- (void)clickCloseBtn:(UIButton *)btn{
    [self dismiss];
    if (btn.tag == SureBtnTag) {
        if (_fliterType == DevicesMonitoring) {
            
            [self.dataAdapter requestDevicesList];
            if ([self.delegate respondsToSelector:@selector(showHudView)]) {
                [self.delegate showHudView];
            }
        }else if (_fliterType == AlarmLog){
            
            [self.dataAdapter requestAlarmList];
            if ([self.delegate respondsToSelector:@selector(showHudView)]) {
                [self.delegate showHudView];
            }
        }else if (_fliterType == Statistic){
            XWSFliterConditionModel *device = [self.dataAdapter getModel:KeyDeviceName];
            if ([self.delegate respondsToSelector:@selector(clickFliterView:dataSource:)]) {
                [self.delegate clickFliterView:self dataSource:@{@"deviceID":device.deviceID?:@""}];
            }
        }else{
            
        }
    }
}
- (void)swipeCover:(UISwipeGestureRecognizer *)tap{
    [self dismiss];
}
- (void)clickCover:(UITapGestureRecognizer *)tap{
    [self dismiss];
}

#pragma mark - 动画
/*开启蒙版透明度动画*/
/**
 设置alpha值
 动画是时间 duration
 **/
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
/*取消门板透明度动画*/
- (void)cancelCoverViewOpacity{
    [_coverView.layer removeAllAnimations];
    _coverView.alpha = 0;
}

#pragma mark - XWSFliterDataAdapterDelegate
//筛选条件
- (void)getFliterDataReloadTable:(XWSFliterDataAdapter *)dataAdapter{
    
    if (self.dataAdapter.leftArr.count != 0) {
        self.NoDataView.hidden = YES;
        self.leftTableView.hidden = NO;
        self.rightTableView.hidden = NO;
    
        [self.leftTableView reloadData];
        [self.rightTableView reloadData];
    
    }else{
        self.NoDataView.hidden = NO;
        self.leftTableView.hidden = YES;
        self.rightTableView.hidden = YES;
    }
}
- (void)getStatisticDeviceFirst{
    [self clickCloseBtn:self.sureBtn];
}
#pragma mark - 回调筛选结果
- (void)getFliterDeviceList:(NSDictionary *)devices{
    
    if ([self.delegate respondsToSelector:@selector(clickFliterView:dataSource:)]) {
        [self.delegate clickFliterView:self dataSource:devices];
        self.delegate.arr = @[@1];
    }
}

#pragma mark - 根据传入的数据，获取对应cell的值（可以在这里进行修改）
//获取左侧标题
- (NSString *)getLeftDataWithIndex:(NSInteger)index{
    
    XWSFliterConditionModel *model = self.dataAdapter.leftArr[index];
    NSString *title = model.leftKeyName;
    return title;
}
//获取右侧标题
- (NSString *)getRightDataWithIndex:(NSInteger)index{
    
    NSString *title = @"";
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyCustomerName]) {
        XWSFliterCustomer *customer = _selectLeftModel.rightArr[index];
        title = customer.customerName;
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyCustomerGroup]) {
        XWSFliterGroup *group = _selectLeftModel.rightArr[index];
        title = group.groupName;
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyDeviceStatus]) {
        return _selectLeftModel.statusArr[index];
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyDeviceName]) {
        XWSDeviceListModel *device = _selectLeftModel.rightArr[index];
        title = device.Name;
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyAlarmType]) {
        return _selectLeftModel.alarmArr[index];
    }
    
    if ([_selectLeftModel.leftKeyName isEqualToString:KeyAlarmDateScope]) {
        if (index == 0) {
            return _selectLeftModel.startDate;
        }else{
            return _selectLeftModel.endDate;
        }
    }
    
    return title;
}

#pragma mark - Show and Dismiss

- (void)showWithLeftRow:(NSInteger)row{
    
    if ([self.leftTableView numberOfRowsInSection:0] > row) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self tableView:self.leftTableView didSelectRowAtIndexPath:indexPath];
    }
    
    [self show];
}

- (void)show{
    
    self.hidden = NO;
    [UIView animateWithDuration:AnimationTime animations:^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(-ScreenWidth);
        }];
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
        //设置颜色渐变动画
    [self startCoverViewOpacityWithAlpha:CoverAlphaValue withDuration:AnimationTime];
}

- (void)dismiss{
        //把盖板颜色的alpha值至为0
    [self cancelCoverViewOpacity];
    
        //移动侧边栏回到原来的位置
    [UIView animateWithDuration:AnimationTime animations:^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(ScreenWidth);
        }];
        
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
        
    }completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}


@end
