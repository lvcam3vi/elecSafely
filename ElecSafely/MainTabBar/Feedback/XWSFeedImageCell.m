//
//  XWSFeedImageCell.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/26.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSFeedImageCell.h"

@interface XWSFeedImageCell()


@end

@implementation XWSFeedImageCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [_imageView removeFromSuperview];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 56) * 0.5, (frame.size.height - 56) * 0.5, 56, 56)];
        [self addSubview:_imageView];

        [_close removeFromSuperview];
        _close = [UIButton buttonWithType:UIButtonTypeCustom];
        _close.frame = CGRectMake(CGRectGetWidth(self.bounds)-20, 0, 20, 20);
        [_close setBackgroundImage:[UIImage imageNamed:@"left_scan"] forState:UIControlStateNormal];
         [self addSubview:_close];
    }
    return self;
}



@end
