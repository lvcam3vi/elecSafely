//
//  XWSSettingPasswordViewController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/29.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSSettingPasswordViewController.h"
#import "NSString+XWSManager.h"
#import "XWSPwdInputCell.h"
#import "PrivateFunction.h"
#import "DESCrypt.h"
#import "TFLoginViewController.h"
#import "XWSNavigationController.h"
#define RowHeight  54.0f

#define OLD_PASSWORD_ERROR_STRING @"原始密码错误"
#define MODIFY_PASSWORD_SUCCESS_STRING @"密码修改成功"
@interface XWSSettingPasswordViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UITextField *oldTextField;
@property (nonatomic, weak) UITextField *neTextField;
@property (nonatomic, weak) UITextField *conTextField;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) ElecProgressHUD *progressHUD;
@end

@implementation XWSSettingPasswordViewController

- (ElecProgressHUD *)progressHUD{
    if (!_progressHUD) {
        _progressHUD = [[ElecProgressHUD alloc] init];
    }
    return _progressHUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavi];
    [self initView];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.oldTextField resignFirstResponder];
    [self.neTextField resignFirstResponder];
    [self.conTextField resignFirstResponder];
    
}

- (void)setUpNavi{
    //设置标题
    self.title = @"账号与安全";
    self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
    [self.sendBtn setTitle:@"提交" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:RGBA(255, 255, 255, 1) forState:UIControlStateNormal];
    self.sendBtn.titleLabel.font = PingFangMedium(15);
    self.sendBtn.enabled = NO;
    [self.sendBtn addTarget:self action:@selector(savePwd) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendBtn];
}

- (void)initView{
    
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

#pragma mark - 修改密码
- (void)savePwd{
    
    if (![self checkParam]) {
        return;
    }

    [self.progressHUD showHUD:self.view Offset:-NavibarHeight animation:18];
    ElecHTTPManager *manager = [ElecHTTPManager manager];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSString *old = [self.oldTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nP = [self.neTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSLog(@"old:%@ %ld",old,old.length);
    
    param[@"OldPW"] = [NSString md5:old];
    param[@"NldPW"] = [NSString md5:nP];
    // password:8ddcff3a80f4189ca1c9d4d902c3c909
    //          8ddcff3a80f4189ca1c9d4d902c3c909
     NSLog(@"[NSString md5:old]:%@",param[@"OldPW"]);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [manager POST:FrigateAPI_ChangePW parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [self.progressHUD dismiss];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSString *resultStr =  [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
        
        [ElecTipsView showTips:resultStr during:2.0];
         NSLog(@"checkId:%@",resultStr);
        // 如果放回的是“密码修改成功”，则退出到登录页面
        if ([resultStr containsString:MODIFY_PASSWORD_SUCCESS_STRING]) {
            [self logOut];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
        [self.progressHUD dismiss];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [ElecTipsView showTips:@"网络错误，请检查网络情况" during:2.0];
    }];
}

- (void)logOut{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            TFLoginViewController *loginVC = [[TFLoginViewController alloc] initWithFrame:CGRectZero];
            XWSNavigationController *navi = [[XWSNavigationController alloc] initWithRootViewController:loginVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = navi;
        });
    });
}

- (BOOL)checkParam{
    [self.oldTextField resignFirstResponder];
    [self.neTextField resignFirstResponder];
    [self.conTextField resignFirstResponder];
    
    if (![self checkPwd:self.oldTextField.text]) {
        [ElecTipsView showTips:@"请输入6~16位的原密码" during:2.0];
        return NO;
    }
    
    if (![self checkPwd:self.neTextField.text]) {
        [ElecTipsView showTips:@"请输入6~16位的新密码" during:2.0];
        return NO;
    }
    
    if (![self checkPwd:self.conTextField.text]) {
        [ElecTipsView showTips:@"请输入6~16位的新密码" during:2.0];
        return NO;
    }
    
    if (![self.neTextField.text isEqualToString:self.conTextField.text]) {
        [ElecTipsView showTips:@"新密码与确认密码不一致" during:2.0];
        return NO;
    }
    
    return YES;
}


- (BOOL)checkPwd:(NSString *)pwd{
    NSString *p = [pwd stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (p.length < 6 || p.length > 16) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XWSPwdInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XWSPwdInputCell"];
    
    if (cell == nil) {
        cell = [[XWSPwdInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XWSPwdInputCell"];
    }
    
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row;
    switch (indexPath.row) {
        case 0:
        {
            cell.titleLabel.text = @"原密码:";
            cell.textField.returnKeyType = UIReturnKeyNext;
            self.oldTextField = cell.textField;
        }
            break;
        case 1:
        {
            cell.titleLabel.text = @"新密码:";
            cell.textField.returnKeyType = UIReturnKeyNext;
            self.neTextField = cell.textField;
        }
            break;
        case 2:
        {
            cell.titleLabel.text = @"确认密码:";
            self.conTextField = cell.textField;
            cell.textField.placeholder = @"请重复输入新密码";
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 17.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat he = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.height,he)];
    headView.backgroundColor = BackColor;
    return headView;
}

#pragma mark - UItextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.oldTextField) {
        [self.neTextField becomeFirstResponder];
    }else if (textField == self.neTextField){
        [self.conTextField becomeFirstResponder];
    }else{
        [self.conTextField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.oldTextField resignFirstResponder];
    [self.neTextField resignFirstResponder];
    [self.conTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
