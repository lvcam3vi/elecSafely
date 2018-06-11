//
//  XWSGetAlarmStatuManager.m
//  ElecSafely
//
//  Created by TigerNong on 2018/5/28.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSGetAlarmStatuManager.h"
#import "XWSFliterDataAdapter.h"

typedef void(^IsAlarmBlock)(BOOL isAlarm);

@interface XWSGetAlarmStatuManager()
@property (nonatomic, assign) NSInteger total;
@end

@implementation XWSGetAlarmStatuManager

-(instancetype)init{
    if (self= [super init]) {
        [self loadDeviceAlarms];
    }
    return self;
}

- (void)loadDeviceAlarms{
    //获取客户列表
    ElecHTTPManager *noticeMgr = [ElecHTTPManager manager];
    [noticeMgr GET:FrigateAPI_CustomerList parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSArray *resultArr = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        
        if ([resultArr isKindOfClass:NSArray.class]) {
            [resultArr enumerateObjectsUsingBlock:^(NSDictionary  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XWSFliterCustomer *customer = [[XWSFliterCustomer alloc] init];
                customer.customerID = [NSString stringWithFormat:@"%@",obj[@"id"]];
                [self requestGroupList:customer.customerID compaletion:^(BOOL isAlarm) {
                    if (isAlarm) {
                        *stop = YES;
                    }
                }];
            }];
        }else{
            [ElecTipsView showTips:@"获取数据失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error___:%@",error);
        [ElecTipsView showTips:@"获取数据失败,请检查网络情况"];
    }];
}

/*客户分组*/
- (void)requestGroupList:(NSString *)customerID compaletion:(IsAlarmBlock)block{
    ElecHTTPManager *noticeMgr = [ElecHTTPManager manager];
    [noticeMgr GET:[NSString stringWithFormat:FrigateAPI_CustomerGroup,customerID] parameters:@"" progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSArray *resultArr = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        
        if ([resultArr isKindOfClass:NSArray.class]) {
            /*找客户分组model*/
            [resultArr enumerateObjectsUsingBlock:^(NSDictionary  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XWSFliterGroup *group = [[XWSFliterGroup alloc] init];
                group.groupID = [NSString stringWithFormat:@"%@",obj[@"id"]];
                
                [self requestDevicesListWithCustomerID:customerID withGroupID:group.groupID compaletion:^(BOOL isAlarm) {
                    if (isAlarm) {
                        *stop = YES;
                        block(YES);
                    }else{
                        block(NO);
                    }
                }];
            }];
        }else{
            block(YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(YES);
        [ElecTipsView showTips:@"获取数据失败,请检查网络情况"];
    }];
}

/*设备列表*/
- (void)requestDevicesListWithCustomerID:(NSString *)CustomerID withGroupID:(NSString *)GroupID compaletion:(IsAlarmBlock)block{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic[@"CustomerID"] = CustomerID;
    paramDic[@"GroupID"] = GroupID;
    paramDic[@"Status"] = @"2";
    paramDic[@"page"] = @"1";
    paramDic[@"rows"] = @"100";
    
    ElecHTTPManager *noticeMgr = [ElecHTTPManager manager];
    
    [noticeMgr GET:FrigateAPI_DeviceList parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        
        if ([resultDic isKindOfClass:NSDictionary.class]) {
            NSArray *rows = resultDic[@"rows"];
            NSMutableArray *devices = [NSMutableArray array];
            
            [devices addObjectsFromArray:rows];
            [devices enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XWSDeviceListModel *deviceModel = [[XWSDeviceListModel alloc] init];
                [deviceModel setValuesForKeysWithDictionary:obj];
                [self requestAlarmListWithCustomerID:CustomerID withGroupID:GroupID withDetectorID:deviceModel.ID compaletion:^(BOOL isAlarm) {
                    if (isAlarm) {
                        *stop = YES;
                        block(YES);
                    }else{
                        block(NO);
                    }
                }];
            }];
        }else{
            block(YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(YES);
        [ElecTipsView showTips:@"获取数据失败,请检查网络情况"];
    }];
}

/*查询警报列表*/
- (void)requestAlarmListWithCustomerID:(NSString *)CustomerID withGroupID:(NSString *)GroupID withDetectorID:(NSString *)DetectorID compaletion:(IsAlarmBlock)block{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic[@"CustomerID"] = CustomerID;
    paramDic[@"GroupID"] = GroupID;
    paramDic[@"DetectorID"] = DetectorID;
    paramDic[@"AT"] = @"alarm";
    paramDic[@"SD"] = @"2018-01-01";
    paramDic[@"ED"] = [self getNowDate];;
    paramDic[@"page"] = @"1";
    paramDic[@"rows"] = @"100";
    
    ElecHTTPManager *noticeMgr = [ElecHTTPManager manager];
    [noticeMgr GET:FrigateAPI_AlarmList parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];

        if ([resultDic isKindOfClass:NSDictionary.class]) {
            NSString *total = resultDic[@"total"];
            if (total.integerValue > 0) {
                block(YES);
                if ([self.delegate respondsToSelector:@selector(haveDeviceAlarm:)]) {
                    [self.delegate haveDeviceAlarm:YES];
                }
                self.total = total.integerValue;
                
            }else{
                block(NO);
                if (self.total == 0) {
                    if ([self.delegate respondsToSelector:@selector(haveDeviceAlarm:)]) {
                        [self.delegate haveDeviceAlarm:NO];
                    }
                }
            }
        }else{
            block(YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ElecTipsView showTips:@"获取数据失败,请检查网络情况"];
        block(YES);
    }];
}

- (NSString *)getNowDate {
    unsigned unitFlags = NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];

    NSString *year = [NSString stringWithFormat:@"%ld",(long)components.year];
    
    NSString *month = [NSString stringWithFormat:@"%ld",(long)components.month];
    if (components.month < 10) {
        month = [NSString stringWithFormat:@"0%ld",(long)components.month];
    }
    
    NSString *day = [NSString stringWithFormat:@"%ld",(long)components.day];
    if (components.day < 10) {
        day = [NSString stringWithFormat:@"0%ld",(long)components.day];
    }
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];

    return dateStr;
}

- (void)dealloc{
    NSLog(@"dealloc:%s",__func__);
}


@end
