//
//  XWSDeviceInfoCell.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/31.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSDeviceInfoCell.h"
#import "NSString+XWSManager.h"
@interface XWSDeviceInfoCell()

@end

@implementation XWSDeviceInfoCell

+ (id)cellWithTableView:(UITableView *)tableView withTitle:(NSString *)title withPlaceHolder:(NSString *)placeholder{
    XWSDeviceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XWSDeviceInfoCell"];
    if (!cell) {
        cell = [[XWSDeviceInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XWSDeviceInfoCell" withTitle:title withPlaceHolder:placeholder];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *)title withPlaceHolder:(NSString *)placeholder{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = NavColor;
        
        //底部的线
        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:line];
        line.backgroundColor = DarkBack;
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.height.mas_equalTo(0.3);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-0.3);
        }];
        
        //标题
        //获取文字的宽度
        CGSize titleSize = [NSString getStringSizeWith:title withStringFont:PingFangRegular(17)];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = PingFangRegular(17);
        self.titleLabel.textColor = RGBA(153, 153, 153, 1);
        self.titleLabel.text = title;
        
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.bottom.mas_equalTo(line.mas_top).mas_equalTo(-10);
            make.width.mas_equalTo(titleSize.width + 17);
        }];
        
        //输入框
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self addSubview:self.textField];
        self.textField.font = PingFangRegular(17);
        self.textField.textColor = RGBA(255, 255, 255, 1);
        self.textField.placeholder = placeholder;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.textField setValue:RGBA(102, 102, 102, 1) forKeyPath:@"_placeholderLabel.textColor"];
        [self.textField setValue:PingFangRegular(15) forKeyPath:@"_placeholderLabel.font"];
        self.textField.tintColor = self.textField.textColor;
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLabel.mas_right).mas_equalTo(0);
            make.bottom.mas_equalTo(self.titleLabel.mas_bottom).mas_equalTo(0);
            make.right.mas_equalTo(-17);
        }];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
