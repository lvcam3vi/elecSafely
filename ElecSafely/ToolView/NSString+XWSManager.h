//
//  NSString+XWSManager.h
//  ElecSafely
//
//  Created by TigerNong on 2018/3/29.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XWSManager)
/*MD5加密*/
+ (NSString *)md5:(NSString *)string;

/*根据字符串的字号，获取字符串的尺寸*/
+ (CGSize)getStringSizeWith:(NSString *)goalString withStringFont:(UIFont *)font;
/*判断字符串中是否还有中文*/
+ (BOOL)hasChinese:(NSString *)str;

/*检查是否存在只存在字母、数字和中文的合法字符*/
+ (BOOL)judgeTheillegalCharacter:(NSString *)content;

/*检查是否只存在字母和数字的合法字符*/
+ (BOOL)judgeTheillegalCharacterWithoutChinese:(NSString *)content;
@end
