//
//  XWSFliterConditionModel.m
//  ElecSafely
//
//  Created by lhb on 2018/4/6.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSFliterConditionModel.h"

NSString *const KeyCustomerName = @"客户名称";
NSString *const KeyCustomerGroup = @"客户分组";
NSString *const KeyDeviceStatus = @"设备状态";

NSString *const KeyDeviceName = @"设备名称";
NSString *const KeyAlarmType = @"报警类型";
NSString *const KeyAlarmDateScope = @"日期范围";

@interface XWSFliterConditionModel(){
    
}
@end

@implementation XWSFliterConditionModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}


- (void)setLeftKeyName:(NSString *)leftKeyName{
    
    _leftKeyName = leftKeyName;
    
    if ([leftKeyName isEqualToString:KeyDeviceStatus]) {
        self.statusArr = @[@"全部",@"正常",@"报警",@"离线"];//0 1 2 3
        self.status = @"0";
        self.selectRightRow = 0;
    }
    
    if ([leftKeyName isEqualToString:KeyAlarmType]) {
        self.alarmArr = @[@"报警",@"离线"];
        self.alarmArrEn = @[@"alarm",@"offline"];
        self.alarmType = @"alarm";
        self.selectRightRow = 0;
    }
    
    if ([leftKeyName isEqualToString:KeyAlarmDateScope]) {
        self.startDate = [self aWeekAgo];
        self.endDate = [self endDateMax];
    }
}

//最大结束日期 今天
- (NSString *)endDateMax{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    return str;
}

//最早开始日期
- (NSString *)startDateMin{
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval startTime = time - 3*30*24*60*60;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:startDate];
    return str;
}

//默认7天前
- (NSString *)aWeekAgo{
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval startTime = time - 7*24*60*60;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:startDate];
    return str;
}

@end


/*
 客户名称
 */
@implementation XWSFliterCustomer


@end


/*
 客户分组
 */
@implementation XWSFliterGroup



@end

