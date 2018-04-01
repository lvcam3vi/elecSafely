//
//  XWSNavigationController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/22.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSNavigationController.h"

@interface XWSNavigationController ()

@end

@implementation XWSNavigationController

+ (void)initialize{
    UINavigationBar *naviBar = [UINavigationBar appearance];
    [naviBar setBarTintColor:NavColor];
    [naviBar setTintColor:[UIColor whiteColor]];
    [naviBar setBarStyle:UIBarStyleBlack];
    [naviBar setShadowImage:[UIImage imageNamed:@""]];
    [naviBar setTranslucent:NO];
    
    //这个设置是把系统中的默认文字去掉
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateSelected];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateHighlighted];
}

- (UIView*)KPGetBackgroundView{
    //iOS10之前为 _UINavigationBarBackground, iOS10为 _UIBarBackground
    //_UINavigationBarBackground实际为UIImageView子类，而_UIBarBackground是UIView子类
    //之前setBackgroundImage直接赋值给_UINavigationBarBackground，现在则是设置后为_UIBarBackground增加一个UIImageView子控件方式去呈现图片
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        UIView *_UIBackground;
        NSString *targetName = @"_UIBarBackground";
        Class _UIBarBackgroundClass = NSClassFromString(targetName);
        
        for (UIView *subview in self.navigationBar.subviews) {
            if ([subview isKindOfClass:_UIBarBackgroundClass.class]) {
                _UIBackground = subview;
                break;
            }
        }
        return _UIBackground;
    }
    else {
        UIView *_UINavigationBarBackground;
        NSString *targetName = @"_UINavigationBarBackground";
        Class _UINavigationBarBackgroundClass = NSClassFromString(targetName);
        
        for (UIView *subview in self.navigationBar.subviews) {
            if ([subview isKindOfClass:_UINavigationBarBackgroundClass.class]) {
                _UINavigationBarBackground = subview;
                break;
            }
        }
        return _UINavigationBarBackground;
    }
}

#pragma mark - shadow view

- (void)KPHideShadowImageOrNot:(BOOL)bHidden{
    UIView *bgView = [self KPGetBackgroundView];
    
    //shadowImage应该是只占一个像素，即1.0/scale
    for (UIView *subview in bgView.subviews) {
        if (CGRectGetHeight(subview.bounds) <= 1.0) {
            subview.hidden = bHidden;
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self KPHideShadowImageOrNot:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
