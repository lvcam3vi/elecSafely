//
//  XWSFliterResultView.m
//  ElecSafely
//
//  Created by lhb on 2018/5/27.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSFliterResultView.h"
#import "XWSFliterConditionModel.h"
#import "UILabel+Create.h"

static const CGFloat rowHeight = 40.f;

@implementation XWSFliterResultView

- (void)adjustHeight:(UITableView *)tableView dataSource:(NSArray<XWSFliterConditionModel*> *)conditionModels{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat height = ((conditionModels.count - 1)/2 + 1) * rowHeight;
    self.height_ES = height;
    tableView.tableHeaderView = self;
    
    [self reloadUI:conditionModels];
}


- (void)reloadUI:(NSArray<XWSFliterConditionModel*> *)conditionModels{
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat margin = 10;
    for (int i = 0; i < conditionModels.count; i++) {
        
        CGFloat x = (i%2)*(self.width_ES/2) + margin;
        CGFloat y = (i/2)*rowHeight;
        
        XWSFliterConditionModel *model = conditionModels[i];
        
        UILabel *label = [UILabel createWithFrame:CGRectMake(x, y, (self.width_ES/2) - margin, rowHeight) text:model.leftKeyName textColor:[UIColor blackColor] textAlignment:0 fontNumber:17];
        [self addSubview:label];
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
