//
//  ESDeviceBasicInfoView.m
//  ElecSafely
//
//  Created by lhb on 2018/3/4.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "ESDeviceBasicInfoView.h"
#import "ESDeviceData.h"

static const CGFloat leftMargin = 15.f;
static const CGFloat updateTimeH = 25.f;

#define TextColor [UIColor colorWithRed:0.58 green:0.62 blue:0.64 alpha:1.00]

#define FontSize_16 [UIFont systemFontOfSize:16]

#define StatusBackColor_Normal [UIColor colorWithRed:0.21 green:0.76 blue:0.38 alpha:1.00]

typedef void(^DeviceBasicInfoClickDetailBtn)(void);

@interface ESDeviceBasicInfoView ()
{
    UIView *_backgroudView;
    
    UILabel *_nameLabel;
    UILabel *_statusLabel;
    UILabel *_updateLabel;
    UILabel *_onlineLabel;
    UILabel *_detailLabel;
    UILabel *_servceLabel;
    DeviceBasicInfoClickDetailBtn _clickDetailBtn;
    DeviceBasicInfoClickDetailBtn _clickServerBtn;
}
@end

@implementation ESDeviceBasicInfoView


- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:1.00];
        
        _backgroudView = [[UIView alloc] initWithFrame:CGRectMake(12, 20, self.width_ES - 12*2, 120)];
        [self addSubview:_backgroudView];
        _backgroudView.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.24 alpha:1.00];
        _backgroudView.layer.cornerRadius = 6;
        
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews{
    
    _nameLabel = [self labelWith:@"设备00000000" font:[UIFont boldSystemFontOfSize:18] textColor:[UIColor colorWithRed:0.84 green:0.85 blue:0.87 alpha:1.00] textAlignment:0];
    _nameLabel.x_ES = leftMargin;
    _nameLabel.y_ES = 0;
    _nameLabel.height_ES = 50;
    CGFloat nameWidth = [_nameLabel sizeThatFits:CGSizeMake(MAXFLOAT, _nameLabel.height_ES)].width;
    _nameLabel.width_ES = nameWidth;
    
    
    _statusLabel = [self labelWith:@"正常" font:[UIFont systemFontOfSize:11] textColor:[UIColor whiteColor] textAlignment:1];
    _statusLabel.backgroundColor = [UIColor colorWithRed:0.21 green:0.76 blue:0.38 alpha:1.00];
    _statusLabel.layer.cornerRadius = 2;
    _statusLabel.layer.masksToBounds = YES;
    _statusLabel.x_ES = _nameLabel.right_ES + 3;
    _statusLabel.width_ES = 36;
    _statusLabel.height_ES = 16;
    _statusLabel.centerY_ES = _nameLabel.centerY_ES;

    
    _updateLabel = [self labelWith:@"更新时间: " font:FontSize_16 textColor:TextColor textAlignment:0];
    _updateLabel.x_ES = _nameLabel.x_ES;
    _updateLabel.y_ES = _nameLabel.bottom_ES;
    _updateLabel.width_ES = _backgroudView.width_ES - 2*leftMargin;
    _updateLabel.height_ES = updateTimeH;
    
    
    _onlineLabel = [self labelWith:@"连接状态: " font:FontSize_16 textColor:TextColor textAlignment:0];
    _onlineLabel.x_ES = _nameLabel.x_ES;
    _onlineLabel.y_ES = _updateLabel.bottom_ES;
    _onlineLabel.width_ES = _backgroudView.width_ES - 2*leftMargin;
    _onlineLabel.height_ES = updateTimeH;
    
    
    _detailLabel = [self labelWith:@"详情" font:[UIFont systemFontOfSize:13] textColor:TextColor textAlignment:1];
    _detailLabel.width_ES = 40.f;
    _detailLabel.height_ES = 20.f;
    _detailLabel.centerY_ES = _nameLabel.centerY_ES;
    _detailLabel.right_ES = _backgroudView.width_ES - leftMargin;
    _detailLabel.layer.borderWidth = 0.2;
    _detailLabel.layer.borderColor = TextColor.CGColor;
    _detailLabel.layer.cornerRadius = 3.f;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterIntoDetailVC)];
    [_detailLabel addGestureRecognizer:tapGes];
    _detailLabel.userInteractionEnabled = YES;
    
    _servceLabel = [self labelWith:@"服务" font:[UIFont systemFontOfSize:13] textColor:TextColor textAlignment:1];
    _servceLabel.width_ES = 40.f;
    _servceLabel.height_ES = 20.f;
    _servceLabel.y_ES = _nameLabel.bottom_ES;
    _servceLabel.right_ES = _backgroudView.width_ES - leftMargin;
    _servceLabel.layer.borderWidth = 0.2;
    _servceLabel.layer.borderColor = TextColor.CGColor;
    _servceLabel.layer.cornerRadius = 3.f;
    
    UITapGestureRecognizer *tapGes2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterServceDetailVC)];
    [_servceLabel addGestureRecognizer:tapGes2];
    _servceLabel.userInteractionEnabled = YES;
}

- (UILabel *)labelWith:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment{
    
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.text = text;
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    
    [_backgroudView addSubview:label];
    return label;
}

- (void)enterIntoDetailVC{
    
    if (_clickDetailBtn) {
        _clickDetailBtn();
    }
}

- (void)enterServceDetailVC {
    if (_clickServerBtn) {
        _clickServerBtn();
    }
}

- (void)updateBasicData:(ESDeviceData *)deviceData clickDetailBtn:(void (^)(void))clickDetailBtn  clickServerBtn:(void (^)(void))clickServerBtn {
    
    _clickDetailBtn = clickDetailBtn;
    _clickServerBtn = clickServerBtn;
    
    _nameLabel.text = deviceData.CRCID;
    CGFloat nameWidth = [_nameLabel sizeThatFits:CGSizeMake(MAXFLOAT, _nameLabel.height_ES)].width;
    _nameLabel.width_ES = nameWidth;
    
    _statusLabel.text = deviceData.Alarm;
    _statusLabel.x_ES = _nameLabel.right_ES + 3;
    if ([deviceData.Alarm isEqualToString:@"正常"]) {
        _statusLabel.backgroundColor = StatusBackColor_Normal;
    }else{
        _statusLabel.backgroundColor = [UIColor redColor];
    }
    
    NSString *updateTime = [NSString stringWithFormat:@"更新时间: %@",deviceData.UpdataDate];
    _updateLabel.text = updateTime;
    
    if ([deviceData.Online intValue] == 1) {
        _onlineLabel.text = @"连接状态: 在线";
    }else{
        _onlineLabel.text = @"连接状态: 离线";
    }
}


@end
