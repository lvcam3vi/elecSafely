//
//  TFLoginProgram.m
//  ElecSafely
//
//  Created by Tianfu on 01/02/2018.
//  Copyright © 2018 Tianfu. All rights reserved.
//

#import "TFLoginProgram.h"
#import <CommonCrypto/CommonDigest.h>
#import "XGPush.h"
#import "NSString+XWSManager.h"

@interface TFLoginProgram ()<XGPushTokenManagerDelegate>

@property (nonatomic, strong) ElecHTTPManager *requestManager;

@end

@implementation TFLoginProgram

static TFLoginProgram *loginProgram = nil;
+ (TFLoginProgram *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginProgram = [[TFLoginProgram alloc] init];
        loginProgram.requestManager = [ElecHTTPManager manager];
    });
    return loginProgram;
}

- (void)userLoginWithAccount:(NSString *)account passWord:(NSString *)password {
//    account = @"demo";
//    password = @"88888888";
    password = [NSString md5:password];
    
    NSLog(@"password:%@",password);
    if (account.length > 0 && password.length > 0) {

        [_requestManager POST:FrigateAPI_Login_Check parameters:@{@"name":account,@"pwd":password} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *checkId =  [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];

            if ([checkId isEqualToString:@"-1"]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(loginProgram: DidLoginSuccess: passWord:)]) {
                    [self.delegate loginProgram:loginProgram DidLoginSuccess:account passWord:password];
                }
            }
            else if ([checkId isEqualToString:@"1"]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(loginProgram: DidLoginFailed:)]) {
                    [self.delegate loginProgram:loginProgram DidLoginFailed:@"密码错误"];
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error:%@",error);
            if (self.delegate && [self.delegate respondsToSelector:@selector(loginProgram: DidLoginFailed:)]) {
                [self.delegate loginProgram:loginProgram DidLoginFailed:@"登陆失败"];
            }
        }];
    }
}

//绑定信鸽推送
- (void)bindWithAccount:(NSString *)account {
    [XGPushTokenManager defaultTokenManager].delegatge = self;
    [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:account type:XGPushTokenBindTypeAccount];
}

#pragma mark - XGPushTokenManagerDelegate
- (void)xgPushDidBindWithIdentifier:(NSString *)identifier type:(XGPushTokenBindType)type error:(NSError *)error {
    NSLog(@"%s, id is %@, error %@", __FUNCTION__, identifier, error);
}

- (void)xgPushDidUnbindWithIdentifier:(NSString *)identifier type:(XGPushTokenBindType)type error:(NSError *)error {
    NSLog(@"%s, id is %@, error %@", __FUNCTION__, identifier, error);
}


//md5加密
- (NSString *)md5:(NSString *)string
{
    const char *str = [string UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

@end
