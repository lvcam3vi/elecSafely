//
//  main.m
//  ElecSafely
//
//  Created by Tianfu on 11/12/2017.
//  Copyright © 2017 Tianfu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"%d",argc);
        NSLog(@"%p",argv);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
