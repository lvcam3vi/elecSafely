//
//  ModuleDef.h
//  ElecSafely
//
//  Created by Tianfu on 11/12/2017.
//  Copyright © 2017 Tianfu. All rights reserved.
//

#ifndef ModuleDef_h
#define ModuleDef_h

#define FONT9  [UIFont systemFontOfSize:9]
#define FONT10 [UIFont systemFontOfSize:10]
#define FONT11 [UIFont systemFontOfSize:11]
#define FONT12 [UIFont systemFontOfSize:12]
#define FONT13 [UIFont systemFontOfSize:13]
#define FONT14 [UIFont systemFontOfSize:14]
#define FONT15 [UIFont systemFontOfSize:15]
#define FONT16 [UIFont systemFontOfSize:16]
#define FONT17 [UIFont systemFontOfSize:17]

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define UIColorRGB(rgb) ([[UIColor alloc] initWithRed:(((rgb >> 16) & 0xff) / 255.0f) green:(((rgb >> 8) & 0xff) / 255.0f) blue:(((rgb) & 0xff) / 255.0f) alpha:1.0f])

#define IS_IOS7 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ? YES : NO)
#define IS_IOS8 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) ? YES : NO)
#define IS_IOS9 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) ? YES : NO)
#define IS_IOS10 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) ? YES : NO)
#define IS_IOS11 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) ? YES : NO)

#define IPHONE_X_WIDTH 375
#define IPHONE_X_HEIGHT 812
#define IS_IPHINE_X (ScreenWidth == IPHONE_X_WIDTH && ScreenHeight == IPHONE_X_HEIGHT)


#define WEAKSELF        typeof(self) __weak weakSelf = self;
#define STRONGSELF(x)   typeof(x) __strong strongSelf = x;

#define DarkBack UIColorRGB(0x0e0f12)
#define NavColor UIColorRGB(0x191b27)
#define BackColor UIColorRGB(0x11121b)
#define PingFangRegular(x) [UIFont fontWithName:@"PingFangSC-Regular" size:x]
#define PingFangLight(x) [UIFont fontWithName:@"PingFangSC-Light" size:x]
#define PingFangMedium(x) [UIFont fontWithName:@"PingFangSC-Medium" size:x]
#define MAS_SHORTHAND //use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND_GLOBALS //enable auto-boxing for default syntax

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define NavibarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)


#define UserAccount @"userAccount"
#define UserPassword @"userPassword"

#define XWSTipViewClickTipViewNotification @"XWSTipViewClickTipViewNotification"

#endif /* ModuleDef_h */
