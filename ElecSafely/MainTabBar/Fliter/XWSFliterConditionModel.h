//
//  XWSFliterConditionModel.h
//  ElecSafely
//
//  Created by lhb on 2018/4/6.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWSDeviceListModel.h"

typedef NS_ENUM(NSUInteger, FliterEnterType) {
    DevicesMonitoring,  ///设备列表
    AlarmLog, ///警报
    Statistic ///统计
};

UIKIT_EXTERN NSString *const KeyCustomerName;
UIKIT_EXTERN NSString *const KeyCustomerGroup;
UIKIT_EXTERN NSString *const KeyDeviceStatus;

UIKIT_EXTERN NSString *const KeyDeviceName;
UIKIT_EXTERN NSString *const KeyAlarmType;
UIKIT_EXTERN NSString *const KeyAlarmDateScope;


/*用于筛选条件的通用model*/
@interface XWSFliterConditionModel : NSObject

/*既是key又是name*/
@property (nonatomic, copy) NSString *leftKeyName;

/* 1、被选中的客户ID（用于当前筛选条件，当前对象是作为客户名称）  */
@property (nonatomic, copy) NSString *customerID;


/* 1、被选中的客户分组ID（用于当前筛选条件，当前对象是作为客户分组）*/
@property (nonatomic, copy) NSString *groupID;


/*记录 右侧当前选中的行*/
@property (nonatomic, assign) NSInteger selectRightRow;

/*所有 客户名称 or 客户分组 or 设备名称*/ //XWSFliterCustomer / XWSFliterGroup / XWSDeviceListModel
@property (nonatomic, strong) NSArray *rightArr;


/*设备状态*/
@property (nonatomic, strong) NSArray *statusArr;
//0 1 2 3 = @[@"全部",@"正常",@"报警",@"离线"] 记录当前选中哪个
@property (nonatomic, strong) NSString *status;


/*报警类型*/
@property (nonatomic, strong) NSArray *alarmArr;
@property (nonatomic, strong) NSArray *alarmArrEn;
//alarm offline = @[@"报警",@"离线"] 记录当前选中哪个类型
@property (nonatomic, strong) NSString *alarmType;


/*被选中的设备ID (当前对象是作为设备类型）*/
@property (nonatomic, copy) NSString *deviceID;

/*被选中的日期 (当前对象是作为日期范围）*/
@property (nonatomic, copy) NSString *startDate;/// yyyy-MM-dd
@property (nonatomic, copy) NSString *endDate;

/// yyyy-MM-dd
- (NSString *)startDateMin;
- (NSString *)endDateMax;

@end


/*
 客户名称
 */
@interface XWSFliterCustomer : NSObject
/*id*/
@property (nonatomic, copy) NSString *customerID;
/*名称*/
@property (nonatomic, copy) NSString *customerName;

@end

/*
 客户分组
 */
@interface XWSFliterGroup : NSObject

/*id*/
@property (nonatomic, copy) NSString *groupID;
/*名称*/
@property (nonatomic, copy) NSString *groupName;

@end


