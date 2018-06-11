//
//  XWSGetAlarmStatuManager.h
//  ElecSafely
//
//  Created by TigerNong on 2018/5/28.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XWSGetAlarmStatuManagerDelegate <NSObject>
- (void)haveDeviceAlarm:(BOOL)hAlarm;
@end

@interface XWSGetAlarmStatuManager : NSObject
@property (nonatomic, weak) id<XWSGetAlarmStatuManagerDelegate> delegate;
@end
