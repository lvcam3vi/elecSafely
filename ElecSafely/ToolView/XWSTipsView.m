//
//  XWSTipsView.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/26.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSTipsView.h"

@interface XWSTipsView()

@end

@implementation XWSTipsView

+ (void)showTipViewWithType:(XWSShowViewType)type inSuperView:(UIView *)superView{
    if (superView.subviews.count > 0) {
        for (id obj in superView.subviews) {
            if ([obj isKindOfClass:[XWSTipsView class]]) {
                XWSTipsView *view = (XWSTipsView *)obj;
                [view removeFromSuperview];
            }
        }
    }
    XWSTipsView *contentView = [[XWSTipsView alloc] init];
    [superView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    contentView.backgroundColor = BackColor;
    
    //清除所有在View上的控件
    for (UIView *obj in contentView.subviews) {
        [obj removeFromSuperview];
    }
    
    //添加标题
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [contentView addSubview:tipLabel];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = PingFangRegular(16);
    tipLabel.textColor = RGBA(170, 170, 170, 1);
    
    
    if (type == XWSShowViewTypeError) {
        //添加图片视图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(contentView.mas_centerX);
            make.top.mas_equalTo(182);
            make.width.mas_equalTo(103);
            make.height.mas_equalTo(87);
        }];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(contentView.mas_centerX);
            make.top.mas_equalTo(imageView.mas_bottom).mas_equalTo(28);
            
        }];
        imageView.image = [UIImage imageNamed:@"net_error"];
        tipLabel.text = @"网络错误，请检查网络";
    }else{
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(contentView.mas_centerX);
            make.top.mas_equalTo(297);
            
        }];
        tipLabel.text = @"暂时无数据";
    }
}

+ (void)hideTipViewWithSuperView:(UIView *)superView{
    if (superView.subviews.count > 0) {
        for (id obj in superView.subviews) {
            if ([obj isKindOfClass:[XWSTipsView class]]) {
                XWSTipsView *view = (XWSTipsView *)obj;
                
                for (UIView *sub in view.subviews) {
                    [sub removeFromSuperview];
                }
                [view removeFromSuperview];
            }
        }
    }
}


- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
