//
//  XWSFliterResultView.h
//  ElecSafely
//
//  Created by lhb on 2018/5/27.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XWSFliterConditionModel;

@interface XWSFliterResultView : UIView

- (void)adjustHeight:(UITableView *)tableView dataSource:(NSArray<XWSFliterConditionModel*> *)conditionModels;

@end
