//
//  ElecHTTPManager.m
//  ElecSafely
//
//  Created by Tianfu on 01/02/2018.
//  Copyright © 2018 Tianfu. All rights reserved.
//

#import "ElecHTTPManager.h"

@implementation ElecHTTPManager

+ (instancetype)manager {
    ElecHTTPManager *manager = [super manager];
    NSMutableSet *newSet = [NSMutableSet set];
    newSet.set = manager.responseSerializer.acceptableContentTypes;
    [newSet addObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = newSet;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    return manager;
}

@end
