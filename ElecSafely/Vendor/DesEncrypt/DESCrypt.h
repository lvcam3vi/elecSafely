//
//  DESCrypt.h
//  EncryptTest
//
//  Created by duziqing on 12-11-6.
//  Copyright (c) 2012年 duziqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

@interface DESCrypt : NSObject

+ (NSString *)encryptUseDES:(NSString *)plainText key:(NSString *)key;
+ (NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;

+ (NSString *)encryptHEX:(NSString *)message password:(NSString *)password;
+ (NSString *)decryptHEX:(NSString *)base64EncodedString password:(NSString *)password;

+ (NSString *)encryptUTF8:(NSString *)message password:(NSString *)password;
+ (NSString *)decryptUTF8:(NSString *)base64EncodedString password:(NSString *)password;

+ (NSString*)buqi:(NSString*)a;
//+ (NSString *)encrypt:(NSString *)message password:(NSString *)password;
//+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password;

@end
