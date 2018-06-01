//
//  XWSFliterResultView.h
//  ElecSafely
//
//  Created by lhb on 2018/5/27.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWSFliterConditionModel.h"

@protocol XWSFliterResultViewDelegate <NSObject>

- (void)fliterResultViewClickWith:(NSInteger)tag;

@end;

@interface XWSFliterResultView : UIView

- (void)adjustHeight:(UITableView *)tableView dataSource:(NSArray<XWSFliterConditionModel*> *)conditionModels type:(FliterEnterType)type;


@property (nonatomic, weak) id<XWSFliterResultViewDelegate> delegate;


@end
