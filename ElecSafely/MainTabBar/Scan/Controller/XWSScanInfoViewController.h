//
//  XWSScanInfoViewController.h
//  ElecSafely
//
//  Created by TigerNong on 2018/3/29.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSBasrViewController.h"

typedef NS_ENUM(NSInteger, XWSDeviceInputType) {
    XWSDeviceInputTypeAuto = 0,//二维码扫描
    XWSDeviceInputTypeManual //手动输入
};

@interface XWSScanInfoViewController : XWSBasrViewController
/*扫描出来的数据*/
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, assign) XWSDeviceInputType type;
@end
