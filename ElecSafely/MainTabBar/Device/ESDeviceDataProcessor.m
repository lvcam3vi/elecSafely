//
//  ESDeviceDataProcessor.m
//  ElecSafely
//
//  Created by lhb on 2018/2/4.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "ESDeviceDataProcessor.h"
#import "ESDeviceData.h"

@interface ESDeviceDataProcessor ()
{
    ElecHTTPManager *_httpManager;
}

@end

@implementation ESDeviceDataProcessor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _httpManager = [ElecHTTPManager manager];
    }
    return self;
}
/*设备实时信息*/
- (void)requestDeviceStatusDataWithDeviceID:(NSString *)deviceID success:(void (^)(ESDeviceData *))success{
    
    [_httpManager GET:FrigateAPI_DeviceStatus parameters:@{@"ID":deviceID?:@""} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        if ([resultDic isKindOfClass:NSDictionary.class]) {
            
            ESDeviceData *deviceData = [[ESDeviceData alloc] initWithDictionary:resultDic];
            if (success) {
                success(deviceData);
            }
        }else{
            if (success) {
                success([[ESDeviceData alloc] init]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (success) {
            success([[ESDeviceData alloc] init]);
        }
    }];
}

/*获取设备最近7天设备查询数据信息*/
- (void)requestDeviceChartHistoryDataWithDeviceID:(NSString *)deviceID success:(void (^)(NSArray *))success{
    
    [_httpManager GET:FrigateAPI_DeviceHistory parameters:@{@"ID":deviceID?:@""} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        if ([resultDic isKindOfClass:NSDictionary.class]) {
            if (success) {
                success(resultDic.allValues);
            }
        }else{
            if (success) {
                success(@[]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (success) {
            success(@[]);
        }
        [ElecTipsView showTips:@"获取数据失败"];
    }];
}

/*设备查询  设备复位*/
- (void)requestDeviceQueryDataWithDeviceID:(NSString *)deviceID success:(void(^)(BOOL))success{
    
    [_httpManager POST:FrigateAPI_Query parameters:@{@"ID":deviceID?:@""} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (success) {
            success(NO);
        }
        [ElecTipsView showTips:@"查询失败"];
    }];
}

- (void)requestDeviceResetDataWithDeviceID:(NSString *)deviceID success:(void(^)(BOOL))success{
    
    [_httpManager POST:FrigateAPI_Reset parameters:@{@"ID":deviceID?:@""} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ElecTipsView showTips:@"复位失败"];
        if (success) {
            success(NO);
        }
    }];
}

@end
