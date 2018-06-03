//
//  CurveChartView.m
//  SLChartLibDemo
//
//  Created by lhb on 2018/1/22.
//  Copyright © 2018年 Hadlinks. All rights reserved.
//

#import "CurveChartView.h"

#import "SLCurveChartLib.h"
#import "XAxisFormtter.h"
#import "YAxisFormtter.h"
#import "YRightAxisFormtter.h"
#import "HighLightFormatter.h"

const CGFloat CurveChartTotalH = 240.0;//CurveChartH + BottomMargin + TopTextHeight + 20

static const CGFloat CurveChartH = 150.0;
static const CGFloat BottomMargin = 20.0;
static const CGFloat TopTextHeight = 50.0;

static const CGFloat LeftMargin = 15.0;

#define TEXT_COLOR [UIColor colorWithRed:0.60 green:0.61 blue:0.62 alpha:1.00]
#define Line_COLOR [UIColor colorWithRed:0.33 green:0.34 blue:0.36 alpha:1.00]

@interface CurveChartView ()
{
    int _yMax;
}
@property (strong, nonatomic) BaseCurveView *curveView;
@property (nonatomic, strong) SLLineChartData* dataSource;
@property (nonatomic, strong) SLGCDTimer timer;
@property (nonatomic, strong) HighLightFormatter *highLightFor;

@end


@implementation CurveChartView

//名称
- (UILabel *)titleLabel {
    
    if (_titleLabel == nil) {
        _titleLabel = [UILabel createWithFrame:CGRectMake(LeftMargin, 0, self.width_ES - 2*LeftMargin, TopTextHeight)
                                          text:@""
                                     textColor:TEXT_COLOR
                                 textAlignment:0
                                    fontNumber:16];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

//单位
- (UILabel *)unitLabel {
    
    if (_unitLabel == nil) {
        _unitLabel = [UILabel createWithFrame:CGRectMake(LeftMargin, self.titleLabel.bottom_ES, 50, 30)
                                          text:@""
                                     textColor:Line_COLOR
                                 textAlignment:0
                                    fontNumber:12];
        [self addSubview:_unitLabel];
    }
    return _unitLabel;
}


- (void)setCurveChartData:(NSDictionary *)curveChartData{
    
    if ([curveChartData isKindOfClass:[NSDictionary class]]) {
        _curveChartData = [curveChartData copy];
        self.unitLabel.text = [NSString stringWithFormat:@"(%@)",_curveChartData[@"Unit"]];
        self.titleLabel.text = [NSString stringWithFormat:@"%@回路曲线",_curveChartData[@"Name"]];
        
        [self setUpChartData:curveChartData];
    }
    else{
        
    }
}


- (instancetype)initWithFrame:(CGRect)frame withCurveChartData:(NSDictionary *)curveChartData{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:1.00];
        _yMax = 0;
        
        self.curveView = [[BaseCurveView alloc] initWithFrame:CGRectMake(LeftMargin, TopTextHeight, self.width_ES - 2*LeftMargin, CurveChartH)];
        [self addSubview:self.curveView];
        [self bringSubviewToFront:self.unitLabel];
        
        ChartAxisBase* xAxis = self.curveView.XAxis;
        xAxis.axisValueFormatter = [[XAxisFormtter alloc] init];
        xAxis.drawLabelsEnabled = YES;
        xAxis.drawAxisLineEnabled = NO;
        xAxis.drawGridLinesEnabled = NO;
        xAxis.labelFont = [UIFont systemFontOfSize:12.0];
        xAxis.labelTextColor = TEXT_COLOR;
        xAxis.maxLongLabelString = @"6";
        xAxis.GridLinesMode = dashModeLine;
        xAxis.enabled = YES;
        
        //显示的日期
        NSArray *dateArr = curveChartData[@"dateArr"];
        if (![dateArr isKindOfClass:NSArray.class]) {
            dateArr = @[];
        }
        xAxis.xAxisShowData = dateArr;
        
        ChartAxisBase* leftYAxis = self.curveView.leftYAxis;
        leftYAxis.axisValueFormatter = [[YAxisFormtter alloc] init];
        leftYAxis.drawLabelsEnabled = YES;
        leftYAxis.drawAxisLineEnabled = NO;
        leftYAxis.drawGridLinesEnabled = YES;
        leftYAxis.labelFont = [UIFont systemFontOfSize:12.0];
        leftYAxis.labelTextColor = TEXT_COLOR;
        leftYAxis.maxLongLabelString = @"100000";
        leftYAxis.GridLinesMode = straightModeLine;
        leftYAxis.gridColor = [UIColor colorWithColor:Line_COLOR andalpha:0.5];
        leftYAxis.enabled = YES;
        
        //    ChartAxisBase* rightYAxis = self.curveView.rightYAxis;
        //    rightYAxis.axisValueFormatter = [[YRightAxisFormtter alloc] init];
        //    rightYAxis.drawLabelsEnabled = YES;
        //    rightYAxis.drawAxisLineEnabled = YES;
        //    rightYAxis.drawGridLinesEnabled = YES;
        //    rightYAxis.labelFont = [UIFont systemFontOfSize:11.0];
        //    rightYAxis.labelTextColor = [UIColor whiteColor];
        //    rightYAxis.maxLongLabelString = @"100.0";
        //    rightYAxis.GridLinesMode = dashModeLine;
        //    rightYAxis.gridColor = [UIColor colorWithColor:[UIColor blueColor] andalpha:0.25];;
        //    rightYAxis.enabled = YES;
        
        //    //默认选择的highlight
        //    ChartHighlight* highLight = [[ChartHighlight alloc] init];
        //    highLight.dataIndex = 5;
        //    highLight.enabled = YES;
        //    self.highLightFor = [[HighLightFormatter alloc] init];
        //    highLight.delegate = self.highLightFor;
        //    self.curveView.hightLight = highLight;
        
        [self setCurveChartData:curveChartData];
    }
    
    return self;
}

/*曲线数据初始化*/
- (void)setUpChartData:(NSDictionary *)chartData{
    
    NSArray *colorArr = @[[UIColor greenColor],[UIColor yellowColor],[UIColor blueColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor purpleColor]];//线路颜色
    NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:1];//表格
    NSMutableArray *bottomLoops = [NSMutableArray arrayWithCapacity:3];//底部回路名称和颜色
    NSArray *CurrLoop = chartData[@"CurrLoop"];
    for (int i = 0; i < CurrLoop.count; i++) {
        
        UIColor *color = colorArr[i % colorArr.count];
        
        NSDictionary *loopNameColor = @{@"color":color,@"name":[NSString stringWithFormat:@"%@%@",chartData[@"Name"], CurrLoop[i]]};
        [bottomLoops addObject:loopNameColor];//底部
        
        NSMutableArray *tempArr = [self tempArray:chartData loopNum:CurrLoop[i]];
        
        SLLineChartDataSet* dataSet = [[SLLineChartDataSet alloc] initWithValues:tempArr label:@"Default"];
        dataSet.lineWidth = 1.0;
        dataSet.mode = brokenLineMode;
        dataSet.color = color;
            //    dataSet.circleRadius = 5.0;
            //    dataSet.circleHoleRadius = 3.0;
            //    dataSet.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        dataSet.drawCircleHoleEnabled = NO;
        dataSet.drawCirclesEnabled = NO;
        dataSet.drawFilledEnabled = NO;
        dataSet.gradientColors = @[color, [UIColor clearColor]];
        
        [valuesArray addObject:dataSet];
    }
    
    /*1、有些Y值全部为0，造成无法显示，故虚构一个补充  2、最大Y值可按此方法设置*/
    if (_yMax == 0) {
        ChartDataEntry* entry = [[ChartDataEntry alloc] initWithX:0 y:4];
        SLLineChartDataSet* dataSet = [[SLLineChartDataSet alloc] initWithValues:[@[entry] mutableCopy] label:@"Default"];
        dataSet.color = [UIColor clearColor];
        dataSet.drawCircleHoleEnabled = NO;
        dataSet.drawCirclesEnabled = NO;
        [valuesArray addObject:dataSet];
    }
    
    SLLineChartData* dataSource = [[SLLineChartData alloc] initWithValues:valuesArray];
    self.dataSource = dataSource;
    dataSource.graphColor = [UIColor clearColor];
    
    [self.curveView setScaleXEnabled:@(NO)];
    [self.curveView setDynamicYAixs:@(NO)];
    [self.curveView setBaseYValueFromZero:@(YES)];
    
//        //设置的时候务必保证  VisibleXRangeDefaultmum 落在 VisibleXRangeMinimum 和 VisibleXRangeMaximum 否则将导致缩放功能不可用
//    [self.curveView setVisibleXRangeMaximum:@(50)];
//    [self.curveView setVisibleXRangeMinimum:@(2)];
//    [self.curveView setVisibleXRangeDefaultmum:@(10)];
    
        //增加选配的基准线
        //        ChartBaseLine* lineMax = [[ChartBaseLine alloc] init];
        //        lineMax.lineWidth = 0.5;
        //        lineMax.lineColor = [UIColor yellowColor];
        //        lineMax.lineMode = ChartBaseLineDashMode;
        //        lineMax.yValue = 50;
        //
        //        ChartBaseLine* lineMin = [[ChartBaseLine alloc] init];
        //        lineMin.lineWidth = 0.5;
        //        lineMin.lineColor = [UIColor purpleColor];
        //        lineMin.lineMode = ChartBaseLineStraightMode;
        //        lineMin.yValue = 10;
        //        [self.curveView addYBaseLineWith:lineMax];
        //        [self.curveView addYBaseLineWith:lineMin];
    
    [self.curveView setPageScrollerEnable:@(NO)];
    
        //直接调用Set方法和refreashDataSourceRestoreContext 和该方法等效
    [self.curveView refreashDataSourceRestoreContext:self.dataSource];
    
    /*底部回路颜色提示和名字*/
    [self createBottomTipView:bottomLoops];
}


- (NSMutableArray*)tempArray:(NSDictionary *)curveData loopNum:(NSString *)loopNum{
    NSMutableArray * tempArray = [NSMutableArray arrayWithCapacity:200];
    NSArray *dateArr = curveData[@"dateArr"];
    
    if (![dateArr isKindOfClass:NSArray.class]) {
        dateArr = @[];
    }
    
    NSArray *yAxisArr = curveData[loopNum];
    
    if (yAxisArr.count != dateArr.count) {
        return [@[] mutableCopy];
    }
    
    for (int i = 0; i < dateArr.count; i++) {
        
        NSNumber *tempY = yAxisArr[i];
        if ([tempY isKindOfClass:NSNull.class]) {
            tempY = @(0);
        }
        int y = [tempY intValue];
        ChartDataEntry* entry = [[ChartDataEntry alloc] initWithX:i y:y];
        [tempArray addObject:entry];
        
        if (y > _yMax) {
            _yMax = y;
        }
    }
    
    return tempArray;
}

/*底部*/
- (void)createBottomTipView:(NSArray *)loops{
    
    CGFloat xOffset = 2*LeftMargin;
    UIView *lastView = nil;
    for (int i = 0; i < loops.count; i++) {
        lastView = [self loopNameAndColor:lastView ? (lastView.right_ES + 10) : xOffset dict:loops[i]];
    }
}

- (UIView *)loopNameAndColor:(CGFloat)xOffset dict:(NSDictionary *)dict{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(xOffset, self.curveView.bottom_ES, 0, BottomMargin)];
    [self addSubview:view];

    UIView *colorV = [[UIView alloc] initWithFrame:CGRectMake(0, (view.height_ES - 10)/2, 10, 10)];
    colorV.backgroundColor = dict[@"color"];
    [view addSubview:colorV];
    
    UILabel *nameLa = [UILabel createWithFrame:CGRectMake(colorV.right_ES + 5, 0, 0, view.height_ES) text:dict[@"name"] textColor:[UIColor colorWithRed:0.67 green:0.69 blue:0.70 alpha:1.00] textAlignment:0 fontNumber:14];
    [view addSubview:nameLa];
    CGFloat nameWidth = [nameLa sizeThatFits:CGSizeMake(MAXFLOAT, nameLa.height_ES)].width;
    nameLa.width_ES = nameWidth;
    
    view.width_ES = nameLa.right_ES;
    return view;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
