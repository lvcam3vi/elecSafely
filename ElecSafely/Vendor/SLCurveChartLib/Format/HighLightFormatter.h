//
//  HighLightFormatter.h
//  SLChartLibDemo
//
//  Created by smart on 2017/6/15.
//  Copyright © 2017年 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLCurveChartLib.h"

@protocol HighLightFormatterDelegate <NSObject>
@optional
- (void)chartCurrentHighLight:(ChartHighlight *) highlight;//当前高亮点

@end


@interface HighLightFormatter : NSObject<ChartHighlightDelegate>

@property (nonatomic, weak) id<HighLightFormatterDelegate>     delegate;          //返回高亮显示点

@end
