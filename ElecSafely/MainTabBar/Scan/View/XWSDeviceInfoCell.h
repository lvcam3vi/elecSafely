//
//  XWSDeviceInfoCell.h
//  ElecSafely
//
//  Created by TigerNong on 2018/3/31.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XWSDeviceInfoCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;

+ (id)cellWithTableView:(UITableView *)tableView withTitle:(NSString *)title withPlaceHolder:(NSString *)placeholder;
@end
