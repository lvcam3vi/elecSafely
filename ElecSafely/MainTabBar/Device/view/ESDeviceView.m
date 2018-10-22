//
//  ESDeviceDetailView.m
//  ElecSafely
//
//  Created by lhb on 2018/2/4.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "ESDeviceView.h"
#import "CurveChartView.h"
#import "ESDeviceData.h"
#import "ESDeviceBasicInfoView.h"
#import "ESDeviceLoopTypeValueView.h"

static const CGFloat ChartGap = 8;

@interface ESDeviceView ()
{
    ESDeviceData *_deviceData;
    
    ESDeviceBasicInfoView *_basicInfoView;
    ESDeviceLoopTypeValueView *_loopValueView;
    
}
@end

@implementation ESDeviceView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.09 alpha:1.00];
    }
    return self;
}


- (void)loadDataWith:(ESDeviceData *)deviceData chartData:(NSArray *)chartDatas{
    
    _deviceData = deviceData;
    
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [self showBasicInfoView];
    [self showLoopTypeValueView];
    
    /*回路曲线*/
    __block UIView *lastView = _loopValueView;
    [chartDatas enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CurveChartView *curveView = [[CurveChartView alloc]
                                     initWithFrame:CGRectMake(0, lastView.bottom_ES + ChartGap, self.width_ES, CurveChartTotalH)
                                     withCurveChartData:obj];
        [self addSubview:curveView];
        
        lastView = curveView;
    }];
    
    self.contentSize = CGSizeMake(self.width_ES, lastView.bottom_ES + ChartGap);
}


///基本
- (void)showBasicInfoView {
    
    _basicInfoView = [[ESDeviceBasicInfoView alloc] initWithFrame:CGRectMake(0, 0, self.width_ES, 140)];
    [self addSubview:_basicInfoView];
    
    __weak typeof(self) weakSelf = self;
    [_basicInfoView updateBasicData:_deviceData clickDetailBtn:^{
        if ([weakSelf.deviceViewDele respondsToSelector:@selector(clickDeviceViewIntoBaseInfoVC:)]) {
            [weakSelf.deviceViewDele clickDeviceViewIntoBaseInfoVC:self];
        }
    } clickServerBtn:^{
        if ([weakSelf.deviceViewDele respondsToSelector:@selector(clickDeviceViewServerVC)]) {
            [weakSelf.deviceViewDele clickDeviceViewServerVC];
        }
    }];
}


///回路列表
- (void)showLoopTypeValueView{
    
    _loopValueView = [[ESDeviceLoopTypeValueView alloc] initWithFrame:CGRectMake(0, _basicInfoView.bottom_ES, self.width_ES, 0)];
    [self addSubview:_loopValueView];
    
    __weak typeof(self) weakSelf = self;
    [_loopValueView loadLoopDatas:_deviceData.loopDatas clickQuery:^{
        if ([weakSelf.deviceViewDele respondsToSelector:@selector(clickDeviceViewQueryData:)]) {
            [weakSelf.deviceViewDele clickDeviceViewQueryData:self];
        }
    } clickReset:^{
        if ([weakSelf.deviceViewDele respondsToSelector:@selector(clickDeviceViewResetData:)]) {
            [weakSelf.deviceViewDele clickDeviceViewResetData:self];
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
