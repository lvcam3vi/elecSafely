//
//  NSString+XWSManager.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/29.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "NSString+XWSManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (XWSManager)
+ (NSString *)md5:(NSString *)string
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


+ (CGSize)getStringSizeWith:(NSString *)goalString withStringFont:(UIFont *)font{
    CGSize maxSize = CGSizeMake(MAXFLOAT,30);
    CGSize sizeFileName = [goalString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return sizeFileName;
}

+ (BOOL)hasChinese:(NSString *)str{
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)judgeTheillegalCharacter:(NSString *)content{
    //提示 标签不能输入特殊字符
    NSString *str =@"^[A-Za-z0-9\\u4e00-\u9fa5]+$";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (![emailTest evaluateWithObject:content]) {
        return YES;
    }
    return NO;
}

+ (BOOL)judgeTheillegalCharacterWithoutChinese:(NSString *)content{
    //提示 标签不能输入特殊字符
    NSString *str =@"^[A-Za-z0-9]+$";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (![emailTest evaluateWithObject:content]) {
        return YES;
    }
    return NO;
}

@end
