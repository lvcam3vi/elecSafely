//
//  ESDeviceBasicInfoView.h
//  ElecSafely
//
//  Created by lhb on 2018/3/4.
//  Copyright © 2018年 Tianfu. All rights reserved.
//  设备详情基本数据

#import <UIKit/UIKit.h>

@class ESDeviceData;

@interface ESDeviceBasicInfoView : UIView

- (void)updateBasicData:(ESDeviceData *)deviceData
         clickDetailBtn:(void(^)(void))clickDetailBtn
         clickServerBtn:(void(^)(void))clickServerBtn;

@end
