//
//  XWSDeviceBaseInfoVC.m
//  ElecSafely
//
//  Created by lhb on 2018/4/15.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSDeviceBaseInfoVC.h"
#import "ESDeviceData.h"

static const CGFloat MarginLength = 10.f;

@interface XWSDeviceBaseInfoVC ()
{
    
    UIView *_whiteBackV;
}
@end

@implementation XWSDeviceBaseInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情";
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.09 blue:0.13 alpha:1.00];
    
    CGFloat width = ScreenWidth - 2*MarginLength;
    _whiteBackV = [[UIView alloc] initWithFrame:CGRectMake(MarginLength, MarginLength, width, width)];
    [self.view addSubview:_whiteBackV];
    _whiteBackV.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.24 alpha:1.00];
    
    NSArray *sources = @[@"设备ID",@"设备名称",@"所属客户",@"所属分组",@"设备位置"];
    [self setUpSubviews:sources];
}


- (void)setUpSubviews:(NSArray *)sources{
    
    CGFloat leftMargin = 40;
    CGFloat titleWidth = 85;
    CGFloat height = 40;
    UIColor *titleColor = [UIColor colorWithRed:0.70 green:0.71 blue:0.71 alpha:1.00];
    UIColor *contentColor = [UIColor colorWithRed:0.84 green:0.85 blue:0.87 alpha:1.00];
    for (int i = 0; i < sources.count; ++i) {
        
        UILabel *titlela = [UILabel createWithFrame:CGRectMake(leftMargin, leftMargin + i*height, titleWidth, height) text:sources[i] textColor:titleColor textAlignment:0 fontNumber:17];
        [_whiteBackV addSubview:titlela];
        
        UILabel *contentla = [UILabel createWithFrame:CGRectMake(titlela.right_ES, leftMargin + i*height, _whiteBackV.width_ES - titlela.right_ES - leftMargin, height) text:@"" textColor:contentColor textAlignment:0 fontNumber:19];
        [_whiteBackV addSubview:contentla];
        
        switch (i) {
            case 0:
                contentla.text = self.baseInfoData.CRCID;
                break;
            case 1:
                contentla.text = self.baseInfoData.Name;
                break;
            case 2:
                contentla.text = self.baseInfoData.CustomerName;
                break;
            case 3:
                contentla.text = self.baseInfoData.GroupName;
                break;
            case 4:
                contentla.text = self.baseInfoData.GroupName;
                break;
            default:
                break;
        }
    }
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
