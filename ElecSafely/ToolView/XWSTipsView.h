//
//  XWSTipsView.h
//  ElecSafely
//
//  Created by TigerNong on 2018/3/26.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XWSShowViewType) {
    XWSShowViewTypeError = 0,//网络错误
    XWSShowViewTypeNoData //无数据
};


@interface XWSTipsView : UIView
/*
 type  传入的方式，是错误还是没有数据
 superView 当前的视图需要加载到那个父视图上
 */
+ (void)showTipViewWithType:(XWSShowViewType)type inSuperView:(UIView *)superView;
+ (void)dismissTipViewWithSuperView:(UIView *)superView;

@end
