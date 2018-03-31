//
//  XWSPwdInputCell.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/29.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSPwdInputCell.h"

@interface XWSPwdInputCell()

@property (nonatomic, strong) UIView *line;
@end

@implementation XWSPwdInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = NavColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
         CGFloat y = (self.frame.size.height - 30) * 0.5;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, y, 100, 30)];
        [self addSubview:self.titleLabel];
       
        self.titleLabel.font = PingFangRegular(17);
        self.titleLabel.textColor = RGBA(153, 153, 153, 1);
        self.titleLabel.text = @"密码";
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 10, y, self.frame.size.width - CGRectGetMaxX(self.titleLabel.frame) - 46, 30)];
        [self addSubview:self.textField];
        
        self.textField.textColor = RGBA(255, 255, 255, 1);
        self.textField.font = PingFangRegular(17);
        self.textField.secureTextEntry = YES;
        self.textField.placeholder = @"请输入6~16位的密码";
        [self.textField setValue:RGBA(102, 102, 102, 1) forKeyPath:@"_placeholderLabel.textColor"];
        [self.textField setValue:PingFangRegular(15) forKeyPath:@"_placeholderLabel.font"];
        self.textField.tintColor = self.textField.textColor;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        self.line = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.line];
        self.line.backgroundColor = DarkBack;
        
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(18);
            make.bottom.mas_equalTo(-0.3);
            make.height.mas_equalTo(0.3);
            make.right.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat y = (self.frame.size.height - 30) * 0.5;
    self.titleLabel.frame = CGRectMake(18, y, 100, 30);
    self.textField.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 10, y, self.frame.size.width - CGRectGetMaxX(self.titleLabel.frame) - 36, 30);
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(18);
        make.bottom.mas_equalTo(-0.3);
        make.height.mas_equalTo(0.3);
        make.right.mas_equalTo(0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
