//
//  XWSFliterView.h
//  ElecSafely
//
//  Created by lhb on 2018/3/23.
//  Copyright © 2018年 Tianfu. All rights reserved.
//  筛选

#import <UIKit/UIKit.h>
#import "XWSFliterDataAdapter.h"

#define AnimationTime 0.35
#define CoverAlphaValue 0.5

@class XWSFliterView;

@protocol XWSFliterViewDelegate <NSObject>
- (void)clickFliterView:(XWSFliterView *)fliterView dataSource:(NSDictionary *)dataSource;
@property (nonatomic, strong) NSArray *arr;
@optional
- (void)showHudView;

@end

@interface XWSFliterView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(FliterEnterType)type;

@property (nonatomic, weak) id<XWSFliterViewDelegate> delegate;

/*数据源*/
@property (nonatomic, strong) XWSFliterDataAdapter *dataAdapter;

- (void)show;
- (void)dismiss;

/*show 扩展方法*/
- (void)showWithLeftRow:(NSInteger)row;

@end
