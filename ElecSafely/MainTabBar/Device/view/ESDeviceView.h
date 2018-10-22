//
//  ESDeviceView.h
//  ElecSafely
//
//  Created by lhb on 2018/2/4.
//  Copyright © 2018年 Tianfu. All rights reserved.
//  设备详情主视图

#import <UIKit/UIKit.h>

@class ESDeviceData;
@class ESDeviceView;

@protocol ESDeviceViewDelegate <NSObject>

/*详情*/
- (void)clickDeviceViewIntoBaseInfoVC:(ESDeviceView *)deviceView;
/*服务*/
- (void)clickDeviceViewServerVC;
/*复位*/
- (void)clickDeviceViewResetData:(ESDeviceView *)deviceView;
/*查询*/
- (void)clickDeviceViewQueryData:(ESDeviceView *)deviceView;

@end

@interface ESDeviceView : UIScrollView

@property (nonatomic, weak) id <ESDeviceViewDelegate> deviceViewDele;

/*
 * @param deviceData: 设备实时状态信息
 * @param chartDatas: 设备图表数据
 * @note
 */
- (void)loadDataWith:(ESDeviceData *)deviceData chartData:(NSArray *)chartDatas;

@end
