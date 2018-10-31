//
//  XWSDeviceServerCell.m
//  ElecSafely
//
//  Created by Tianfu on 2018/10/22.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSDeviceServerCell.h"

@implementation XWSDeviceServerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = leftLeftBackColor;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.textColor = LeftViewTextColor;
    title.font = [UIFont systemFontOfSize:15];
    title.text = @"服务类型:";
    [self addSubview:title];
    
    WEAKSELF
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.top.mas_equalTo(10);
    }];
    
    self.typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.typeLabel.textColor = [UIColor whiteColor];
    self.typeLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.typeLabel];
    
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.leading.mas_equalTo(title.mas_trailing).offset(3);
//        make.width.mas_equalTo(100);
    }];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    timeLabel.textColor = LeftViewTextColor;
    timeLabel.font = [UIFont systemFontOfSize:15];
    timeLabel.text = @"服务时间:";
    [self addSubview:timeLabel];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.typeLabel.mas_bottom).offset(10);
        make.leading.mas_equalTo(15);
    }];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.textColor = LeftViewTextColor;
    self.dateLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.dateLabel];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(timeLabel.mas_trailing).offset(3);
        make.top.mas_equalTo(weakSelf.typeLabel.mas_bottom).offset(10);
    }];
    
    UILabel *detailText = [[UILabel alloc] initWithFrame:CGRectZero];
    detailText.textColor = LeftViewTextColor;
    detailText.font = [UIFont systemFontOfSize:15];
    detailText.text = @"服务详情:";
    [self addSubview:detailText];
    
    [detailText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.top.mas_equalTo(timeLabel.mas_bottom).offset(10);
    }];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.detailLabel.textColor = LeftViewTextColor;
    self.detailLabel.numberOfLines = 3;
    [self addSubview:self.detailLabel];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(detailText.mas_trailing).offset(3);
        make.top.mas_equalTo(timeLabel.mas_bottom).offset(10);
        make.trailing.mas_lessThanOrEqualTo(-20);
    }];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithRed:0.06 green:0.07 blue:0.09 alpha:1.00];
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
