//
//  XAxisFormtter.m
//  SLChartDemo
//
//  Created by smart on 2017/5/20.
//  Copyright © 2017年 Hadlinks. All rights reserved.
//

#import "XAxisFormtter.h"

@implementation XAxisFormtter
-(NSString *) stringForValue:(double) value axis:(ChartAxisBase *) axis{
    
    NSArray *dateArr = axis.xAxisShowData;
    NSString *date = @"";
    
    int index = (int)value;
    if ((index%40==0 && index!=0) || index == 10) {
        date = [NSString stringWithFormat:@"%@", (dateArr.count > index) ? dateArr[index] : @""];
    }
    return date;
}

-(CGFloat) yStepWithaxis:(ChartAxisBase *) axis max:(CGFloat) max  Min:(CGFloat) min{
    return 0.0;
}
@end
