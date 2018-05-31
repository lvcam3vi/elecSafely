//
//  XWSFliterDataAdapter.h
//  ElecSafely
//
//  Created by lhb on 2018/4/6.
//  Copyright © 2018年 Tianfu. All rights reserved.
//  筛选数据

#import <Foundation/Foundation.h>
#import "XWSFliterConditionModel.h"

@class XWSFliterDataAdapter;

@protocol XWSFliterDataAdapterDelegate <NSObject>

/*筛选条件*/
- (void)getFliterDataReloadTable:(XWSFliterDataAdapter *)dataAdapter;

/*筛选出来的设备列表*/
- (void)getFliterDeviceList:(NSDictionary *)devices;

/*默认统计第一台设备*/
- (void)getStatisticDeviceFirst;

@end

@interface XWSFliterDataAdapter : NSObject

- (instancetype)initWithType:(FliterEnterType)type;

@property (nonatomic, assign) FliterEnterType fliterType;

/*筛选条件左边数据*/
@property (nonatomic, strong) NSArray<XWSFliterConditionModel*> *leftArr;
@property (nonatomic, weak) id <XWSFliterDataAdapterDelegate> delegate;

/*根据 key 获取left 某一项*/
- (XWSFliterConditionModel *)getModel:(NSString *)leftKeyName;

/*客户名称*/
- (void)requestCustomerList;

/*客户分组*/
- (void)requestGroupList:(NSString *)customerID;

/*设备列表*/
- (void)requestDevicesList;

/*查询警报列表*/
- (void)requestAlarmList;

/*用于警报列表上拉加载更多*/
@property (nonatomic, copy) NSString *requestAlarmUrl; // url
@property (nonatomic, strong) NSDictionary *requestAlarmParam;// 参数

/*用于设备列表上拉加载更多*/
@property (nonatomic, copy) NSString *requestDeviceListUrl; // url
@property (nonatomic, strong) NSDictionary *requestDeviceListParam;// 参数

@end
