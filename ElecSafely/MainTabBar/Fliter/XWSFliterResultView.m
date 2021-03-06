//
//  XWSFliterResultView.m
//  ElecSafely
//
//  Created by lhb on 2018/5/27.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSFliterResultView.h"
#import "UILabel+Create.h"

static const CGFloat rowHeight = 40.f;

@implementation XWSFliterResultView

- (void)adjustHeight:(UITableView *)tableView dataSource:(NSArray<XWSFliterConditionModel*> *)conditionModels type:(FliterEnterType)type{
    self.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.24 alpha:1.00];
    CGFloat height = ((conditionModels.count - 1)/2 + 1) * rowHeight;
    self.height_ES = height;
    tableView.tableHeaderView = self;
    
    [self reloadUI:conditionModels type:type];
}


- (void)reloadUI:(NSArray<XWSFliterConditionModel*> *)conditionModels type:(FliterEnterType)type{
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat margin = 10;
    for (int i = 0; i < conditionModels.count; i++) {
        
        CGFloat x = (i%2)*(self.width_ES/2) + margin;
        CGFloat y = (i/2)*rowHeight;
        
        XWSFliterConditionModel *model = conditionModels[i];
        
        UILabel *label = [UILabel createWithFrame:CGRectMake(x, y, 0, rowHeight) text:[NSString stringWithFormat:@"%@:",model.leftKeyName] textColor:[UIColor colorWithRed:0.58 green:0.62 blue:0.64 alpha:1.00] textAlignment:0 fontNumber:14];
        [self addSubview:label];
        CGFloat width = [label sizeThatFits:CGSizeMake(MAXFLOAT, label.height_ES)].width;
        label.width_ES = width;
        
        CGFloat rightWidth = (self.width_ES/2) - margin*3 - label.width_ES;
        if ((i == conditionModels.count - 1) && (conditionModels.count%2 == 1)) {
            rightWidth = self.width_ES - margin*3 - label.width_ES;
        }
        UILabel *tapLabel = [UILabel createWithFrame:CGRectMake(label.right_ES + margin, label.top_ES, rightWidth, label.height_ES) text:[self getNameWithModel:model] textColor:[UIColor colorWithRed:0.84 green:0.85 blue:0.87 alpha:1.00] textAlignment:0 fontNumber:15];
        [self addSubview:tapLabel];
        tapLabel.tag = i;
        tapLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [tapLabel addGestureRecognizer:tapGes];
    }
}

- (NSString *)getNameWithModel:(XWSFliterConditionModel *)model{
    
    /*修改被选中筛选条件的各个id*/
    if ([model.leftKeyName isEqualToString:KeyCustomerName]) {
        
        XWSFliterCustomer *customer = model.rightArr[model.selectRightRow];
        return customer.customerName;
    }else if ([model.leftKeyName isEqualToString:KeyCustomerGroup]) {
        
        XWSFliterGroup *group = model.rightArr[model.selectRightRow];
        return group.groupName;
    }else if ([model.leftKeyName isEqualToString:KeyDeviceStatus]) {
        
        return model.statusArr[model.selectRightRow];
    }else if ([model.leftKeyName isEqualToString:KeyDeviceName]) {
        
        XWSDeviceListModel *device = model.rightArr[model.selectRightRow];
        return device.Name;
    }else if ([model.leftKeyName isEqualToString:KeyAlarmType]) {
        
        return model.alarmArr[model.selectRightRow];
    }else if ([model.leftKeyName isEqualToString:KeyAlarmDateScope]) {
        
        return [NSString stringWithFormat:@"%@ ~ %@",model.startDate,model.endDate];
    }else {
        return @"";
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tapSender{
    
    NSInteger tag = tapSender.view.tag;
    
    if (_delegate && [_delegate respondsToSelector:@selector(fliterResultViewClickWith:)]) {
        [_delegate fliterResultViewClickWith:tag];
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
