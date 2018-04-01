//
//  XWSSettingViewController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/22.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#define SettingTitleColor RGBA(221, 221, 221, 1)
#define RowHeight  54.0f
#define SettingTitltFont PingFangRegular(17)
#define TableViewBackColor DarkBack
#define CustomSepLineY (RowHeight - 1)

#import "XWSSettingViewController.h"
#import "XGPush.h"
#import "TFLoginViewController.h"
#import "XWSNavigationController.h"
#import "XWSSettingPasswordViewController.h"
#import "XWSAboutViewController.h"


@interface XWSSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation XWSSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置显示的控件
    [self initView];
}

- (void)initView{
    //设置标题
    self.title = @"设置";
    
    //设置表视图
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = RowHeight;
    
    //去掉系统的分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = BackColor;
    
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if(section == 1){
        return 1;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
        line.backgroundColor = DarkBack;
        [cell addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-0.3);
            make.height.mas_equalTo(0.3);
            make.left.mas_equalTo(17);
        }];
        cell.backgroundColor = NavColor;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textColor = SettingTitleColor;
    cell.textLabel.font = SettingTitltFont;
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"账号与安全";
                break;
            case 1:
                cell.textLabel.text = @"关于";
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1){
        cell.textLabel.text = @"设置新消息提醒";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *notiSwith = [[UISwitch alloc] init];
        [notiSwith addTarget:self action:@selector(changeNoti:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = notiSwith;

        //根据本地存储的标识，判断是否打开
        notiSwith.on = IS_OPEN_NOTI ? YES : NO;
    }else{
        cell.textLabel.text = @"退出登录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 17.0f;
    }else if (section == 1){
        return 21.0;
    }else{
        return 85.0;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat he = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.height,he)];
    headView.backgroundColor = BackColor;
    if (section == 2) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [headView addSubview:titleLabel];
        titleLabel.text = @"若关闭，将无法收到消息提醒";
        titleLabel.font = PingFangRegular(13);
        titleLabel.textColor = RGBA(153, 153, 153, 1);
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(18);
            make.top.mas_equalTo(14);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(20);
        }];
        titleLabel.backgroundColor = [UIColor clearColor];
    }
    return headView;
}

//设置点击单元格
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){//进入其他页面
        UIViewController *vc = nil;
        switch (indexPath.row) {
            case 0:
            {
                XWSSettingPasswordViewController *PwdVC = [[XWSSettingPasswordViewController alloc] init];
                vc = PwdVC;
            }
                break;
            case 1:
            {
                XWSAboutViewController *aboutVC = [[XWSAboutViewController alloc] init];
                 vc = aboutVC;
            }
                break;
                
            default:
                break;
        }
        if (vc != nil) {
             [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 2){//退出登录
        [self logout];
    }
}

#pragma mark - 切换开关
/*切换按钮**/
- (void)changeNoti:(UISwitch *)notiSwitch{
    if (notiSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setObject:OPEN_NOTI forKey:NOTI_KEY];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:CLOSE_NOTI forKey:NOTI_KEY];
    }

    //发出通知去切换开启与关闭通知（通知位置在AppDelegate里面）
    [[NSNotificationCenter defaultCenter] postNotificationName:TRUN_ON_OR_OFF_NOTI object:nil];
}

#pragma mark - 退出登录
- (void)logout{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定退出?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        TFLoginViewController *loginVC = [[TFLoginViewController alloc] initWithFrame:CGRectZero];
        XWSNavigationController *navi = [[XWSNavigationController alloc] initWithRootViewController:loginVC];
        
        [UIApplication sharedApplication].keyWindow.rootViewController = navi;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:yesAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)dealloc{
    NSLog(@"setting:%s",__func__);
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
