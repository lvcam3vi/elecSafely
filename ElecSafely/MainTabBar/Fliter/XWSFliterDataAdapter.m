//
//  XWSFliterDataAdapter.m
//  ElecSafely
//
//  Created by lhb on 2018/4/6.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSFliterDataAdapter.h"

@interface XWSFliterDataAdapter (){
    
    ElecHTTPManager *_httpManager;
    
}
@end

@implementation XWSFliterDataAdapter

- (instancetype)initWithType:(FliterEnterType)type{
    
    self = [super init];
    if (self) {
        
        _httpManager = [ElecHTTPManager manager];
        _fliterType = type;
        
        switch (type) {
            case DevicesMonitoring:
            {
                //左边名字做key
                NSArray *keyNames = @[KeyCustomerName,KeyCustomerGroup,KeyDeviceStatus];
                [self createLeftArr:keyNames];
            }
                break;
            case AlarmLog:
            {
                //左边名字做key
                NSArray *keyNames = @[KeyCustomerName,KeyCustomerGroup,KeyDeviceName,KeyAlarmType,KeyAlarmDateScope];
                [self createLeftArr:keyNames];
            }
                break;
            case Statistic:
            {
                //左边名字做key
                NSArray *keyNames = @[KeyCustomerName,KeyCustomerGroup,KeyDeviceName];
                [self createLeftArr:keyNames];
            }
                break;
            default:
                break;
        }
    }
    return self;
}
/*left列表数据*/
- (void)createLeftArr:(NSArray<NSString *> *)keyNames{
    
    NSMutableArray *leftArr = [NSMutableArray array];
    [keyNames enumerateObjectsUsingBlock:^(NSString  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XWSFliterConditionModel *model = [[XWSFliterConditionModel alloc] init];
        model.leftKeyName = obj;
        [leftArr addObject:model];
    }];
    self.leftArr = [leftArr copy];
}

/*客户列表*/
- (void)requestCustomerList{
    
    [_httpManager GET:FrigateAPI_CustomerList parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSArray *resultArr = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if ([resultArr isKindOfClass:NSArray.class]) {
            /*找客户名称model*/
            XWSFliterConditionModel *model = [self getModel:KeyCustomerName];
            
            NSMutableArray *tempArr = [NSMutableArray array];
            [resultArr enumerateObjectsUsingBlock:^(NSDictionary  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XWSFliterCustomer *customer = [[XWSFliterCustomer alloc] init];
                customer.customerID = [NSString stringWithFormat:@"%@",obj[@"id"]];
                customer.customerName = obj[@"text"];
                [tempArr addObject:customer];
                
                if (idx == 0) {//默认选中第一个id
                    model.customerID = customer.customerID;
                    model.selectRightRow = idx;
                    [self requestGroupList:model.customerID];
                }
            }];
            model.rightArr = [tempArr copy];
        }else{
            [ElecTipsView showTips:@"获取数据失败"];
        }
        
        if ([_delegate respondsToSelector:@selector(getFliterDataReloadTable:)]) {
            [_delegate getFliterDataReloadTable:self];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error.code == -1009) {
            
        }else if (error.code == -1001) {
            
        }else{
        
        }
        
        [ElecTipsView showTips:@"获取数据失败"];
    }];
}

/*客户分组*/
- (void)requestGroupList:(NSString *)customerID{
    
    [_httpManager GET:[NSString stringWithFormat:FrigateAPI_CustomerGroup,customerID] parameters:@"" progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSArray *resultArr = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if ([resultArr isKindOfClass:NSArray.class]) {
            /*找客户分组model*/
            XWSFliterConditionModel *model = [self getModel:KeyCustomerGroup];
            
            NSMutableArray *tempArr = [NSMutableArray array];
            [resultArr enumerateObjectsUsingBlock:^(NSDictionary  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XWSFliterGroup *group = [[XWSFliterGroup alloc] init];
                group.groupID = [NSString stringWithFormat:@"%@",obj[@"id"]];
                group.groupName = obj[@"text"];
                [tempArr addObject:group];
                
                if (idx == 0) {//默认选中第一个id
                    model.groupID = group.groupID;
                    model.selectRightRow = idx;
                }
            }];
            model.rightArr = [tempArr copy];
        }
        
        if ([_delegate respondsToSelector:@selector(getFliterDataReloadTable:)]) {
            [_delegate getFliterDataReloadTable:self];
            [self requestDevicesList]; //默认展示选中第一项的筛选结果
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/*设备列表*/
- (void)requestDevicesList{
    XWSFliterConditionModel *customer = [self getModel:KeyCustomerName];
    XWSFliterConditionModel *group = [self getModel:KeyCustomerGroup];
    XWSFliterConditionModel *deviceStatus = [self getModel:KeyDeviceStatus];

    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic[@"CustomerID"] = customer.customerID?:@"";
    paramDic[@"GroupID"] = group.groupID?:@"0";
    paramDic[@"Status"] = deviceStatus.status?:@"0";
    paramDic[@"page"] = @"1";
    paramDic[@"rows"] = @"15";
    
    self.requestDeviceListUrl = FrigateAPI_DeviceList;
    self.requestDeviceListParam = paramDic;
    
    [_httpManager GET:FrigateAPI_DeviceList parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if ([resultDic isKindOfClass:NSDictionary.class]) {
            
            if (_fliterType == DevicesMonitoring) {
                if ([self.delegate respondsToSelector:@selector(getFliterDeviceList:)]) {
                    [self.delegate getFliterDeviceList:resultDic];
                }
            }else if (_fliterType == AlarmLog || _fliterType == Statistic){
                
                /*找设备名称model*/
                XWSFliterConditionModel *model = [self getModel:KeyDeviceName];
                NSArray *rows = resultDic[@"rows"];
                NSMutableArray *tempArr = [NSMutableArray array];
                NSMutableArray *devices = [NSMutableArray array];
                if (_fliterType == AlarmLog) {
                    [devices addObject:@{@"Name":@"所有设备"}];//插入一个“所有设备”类型
                }
                [devices addObjectsFromArray:rows];
                [devices enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    XWSDeviceListModel *deviceModel = [[XWSDeviceListModel alloc] init];
                    [deviceModel setValuesForKeysWithDictionary:obj];
                    
                    [tempArr addObject:deviceModel];
                    
                    if (idx == 0) {//默认选中第一个id
                        model.deviceID = deviceModel.ID;
                        model.selectRightRow = idx;
                    }
                }];
                
                model.rightArr = [tempArr copy];
                
                if ([_delegate respondsToSelector:@selector(getFliterDataReloadTable:)]) {
                    [_delegate getFliterDataReloadTable:self];

                    //默认展示选中第一项的筛选结果
                    if (_fliterType == AlarmLog) {
                        [self requestAlarmList];
                    }
                    //默认展示第一台设备的统计数据
                    if (_fliterType == Statistic) {
                        if ([_delegate respondsToSelector:@selector(getStatisticDeviceFirst)]) {
                            [_delegate getStatisticDeviceFirst];
                        }
                    }
                }
            }else{
                
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"_____________:%@",error);
    }];
}

/*查询警报列表*/
- (void)requestAlarmList{
    
    XWSFliterConditionModel *customer = [self getModel:KeyCustomerName];
    XWSFliterConditionModel *group = [self getModel:KeyCustomerGroup];
    XWSFliterConditionModel *device = [self getModel:KeyDeviceName];
    XWSFliterConditionModel *alarmType = [self getModel:KeyAlarmType];
    XWSFliterConditionModel *dateScope = [self getModel:KeyAlarmDateScope];

    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic[@"CustomerID"] = customer.customerID?:@"";
    paramDic[@"GroupID"] = group.groupID?:@"0";
    paramDic[@"DetectorID"] = device.deviceID?:@"0";
    paramDic[@"AT"] = alarmType.alarmType?:@"";
    paramDic[@"SD"] = [dateScope startDate]?:@"";
    paramDic[@"ED"] = [dateScope endDate]?:@"";
    paramDic[@"page"] = @"1";
    paramDic[@"rows"] = @"15";

    self.requestAlarmUrl = FrigateAPI_AlarmList;
    self.requestAlarmParam = paramDic;
    
    [_httpManager GET:FrigateAPI_AlarmList parameters:paramDic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        if ([resultDic isKindOfClass:NSDictionary.class]) {
            if ([self.delegate respondsToSelector:@selector(getFliterDeviceList:)]) {
                [self.delegate getFliterDeviceList:resultDic];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/*根据 key 获取left 某一项*/
- (XWSFliterConditionModel *)getModel:(NSString *)leftKeyName{
    
    __block XWSFliterConditionModel *model = nil;
    [self.leftArr enumerateObjectsUsingBlock:^(XWSFliterConditionModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.leftKeyName isEqualToString:leftKeyName]) {
            model = obj;
            
            *stop = YES;
        }
    }];
    
    return model;
}


@end
