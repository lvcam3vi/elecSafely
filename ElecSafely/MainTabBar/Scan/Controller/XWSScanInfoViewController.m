//
//  XWSScanInfoViewController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/29.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSScanInfoViewController.h"
#import "XWSDeviceInfoCell.h"
#import "NSString+XWSManager.h"

#define DEVICE_REGISTER_SUCCESS_CODE @"1"

#define RowHeight 66.0f

@interface XWSScanInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSInteger option;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UITextField *textField;
/*标题数组*/
@property (nonatomic, strong) NSMutableArray *titles;

/*键盘的高度*/
@property (nonatomic, assign) CGFloat keyBoardHeight;
/*对应的参数*/
//设备注册码
@property (nonatomic, copy) NSString *CRCID;
//设备注册码
@property (nonatomic, copy) NSString *SimCard;
//设备名称
@property (nonatomic, copy) NSString *DevName;
//设备分组
@property (nonatomic, copy) NSString *GroupName;
//客户名称
@property (nonatomic, copy) NSString *CustName;
//登录账号
@property (nonatomic, copy) NSString *LoginName;
//登录客户密码
@property (nonatomic, copy) NSString *Password;
//上级客户名称
@property (nonatomic, copy) NSString *ParentName;

@property (nonatomic, strong) ElecProgressHUD *progressHUD;
@end

@implementation XWSScanInfoViewController

- (UIButton *)sendBtn{
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        [_sendBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:RGBA(153, 153, 153, 1) forState:UIControlStateNormal];
        _sendBtn.enabled = NO;
        _sendBtn.userInteractionEnabled = NO;
        _sendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _sendBtn.titleLabel.font = PingFangMedium(15);
        [_sendBtn addTarget:self action:@selector(sendRegister) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (ElecProgressHUD *)progressHUD{
    if (!_progressHUD) {
        _progressHUD = [[ElecProgressHUD alloc] init];
    }
    return _progressHUD;
}

- (NSMutableArray *)titles{
    if (!_titles) {
        _titles = [NSMutableArray arrayWithObjects:@"设备注册码",@"物联网卡号",@"设备名称",@"设备分组",@"客户名称",@"登录账号",@"客户登录密码",@"上级客户名称", nil];
    }
    return _titles;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor = BackColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.rowHeight = RowHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0.3);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self registerNoti];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
    [self.progressHUD dismiss];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initView{
    self.title = @"设备注册";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendBtn];
    
    [self tableView];
}

- (void)sendRegister{
    [self.textField resignFirstResponder];

    if (![self checkParam]) {
        return;
    }
    
    [self.progressHUD showHUD:self.view Offset:- NavibarHeight animation:18];
    
    NSLog(@"CRCID:%@ SimCard:%@ DevName:%@ GroupName:%@ CustName:%@ LoginName:%@ Password:%@ ParentName:%@",self.CRCID,self.SimCard,self.DevName,self.GroupName,self.CustName,self.LoginName,self.Password,self.ParentName);
    
    ElecHTTPManager *manager = [ElecHTTPManager manager];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"CRCID"] = self.CRCID;
    param[@"SimCard"] = self.SimCard;
    param[@"DevName"] = self.DevName;
    param[@"GroupName"] = self.GroupName;
    param[@"CustName"] = self.CustName;
    param[@"LoginName"] = self.LoginName;
    param[@"Password"] = [NSString md5:self.Password];
    param[@"ParentName"] = self.ParentName;
    param[@"AppendFlag"] = @"1";
    
    NSLog(@"param:%@",param);
    
    [manager POST:FrigateAPI_Register parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         NSString *resultStr =  [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
        if ([resultStr isEqualToString:DEVICE_REGISTER_SUCCESS_CODE]) {
             [self showNotiView];
        }else{
            
        }

        NSLog(@"resultStr:%@",resultStr);
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
        [ElecTipsView showTips:@"网络错误，请检查网络连接情况" during:2.0];
    }];
}

- (BOOL)checkParam{
    if (![self checkStr:self.CRCID] || [self.CRCID stringByReplacingOccurrencesOfString:@" " withString:@""].length != 16) {
        [ElecTipsView showTips:@"请输入正确格式的16位设备注册码!" during:2.0];
        return NO;
    }
    
    if ([NSString judgeTheillegalCharacterWithoutChinese:self.CRCID]) {
        [ElecTipsView showTips:@"设备注册码只能输入英文和数字" during:2.0];
        return NO;
    }
    
    if (![self checkStr:self.SimCard]) {
        [ElecTipsView showTips:@"请输入物联网卡号!" during:2.0];
        return NO;
    }
    
    if ([NSString judgeTheillegalCharacterWithoutChinese:self.SimCard]) {
        [ElecTipsView showTips:@"物联网卡号只能输入英文和数字" during:2.0];
        return NO;
    }
    
    if (![self checkStr:self.DevName]) {
        [ElecTipsView showTips:@"请输入设备名称!" during:2.0];
        return NO;
    }
    
    if (![self checkStr:self.GroupName]) {
        [ElecTipsView showTips:@"请输入设备分组!" during:2.0];
        return NO;
    }
    
    if (![self checkStr:self.CustName]) {
        [ElecTipsView showTips:@"请输入客户名称!" during:2.0];
        return NO;
    }
    
    if (![self checkStr:self.LoginName]) {
        [ElecTipsView showTips:@"请输入登录账号!" during:2.0];
        return NO;
    }
    
    if (![self checkStr:self.Password]) {
        [ElecTipsView showTips:@"请输入6~16位客户登录密码!" during:2.0];
        return NO;
    }
    
    
    if (![self checkStr:self.ParentName]) {
        [ElecTipsView showTips:@"请输入上级客户名称!" during:2.0];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkStr:(NSString *)str{
    if ([str isEqualToString:@""] || str == nil || str.length == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - 表视图
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *title = self.titles[indexPath.row];
    XWSDeviceInfoCell *cell = [XWSDeviceInfoCell cellWithTableView:tableView withTitle:title withPlaceHolder:@"请输入..."];
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row + 100;
    
    if (indexPath.row == 0) {
        if (self.type == XWSDeviceInputTypeAuto) {
            cell.textField.text = self.deviceId;
            cell.textField.textColor = RGBA(102, 102, 102, 1);
            self.CRCID = self.deviceId;
            cell.textField.enabled = NO;
        }else{
            [cell.textField becomeFirstResponder];
        }
    }
    
    if (self.type == XWSDeviceInputTypeAuto && indexPath.row == 1) {
        [cell.textField becomeFirstResponder];
    }
    
    if (indexPath.row == 6) {
        cell.textField.secureTextEntry = YES;
        cell.textField.placeholder = @"6-16位英文字母、数据和下划线";
    }
    
    if (indexPath.row != 7) {
        cell.textField.returnKeyType = UIReturnKeyNext;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSArray *cells = [self.tableView visibleCells];
    NSInteger tag = textField.tag - 100 + 1;
    if (tag > 7) {
        tag = 7;
    }
    XWSDeviceInfoCell *cell = cells[tag];
    UITextField *cellTextfield = cell.textField;
    switch (textField.tag - 100) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
            [cellTextfield becomeFirstResponder];
            break;
        case 7:
            [textField resignFirstResponder];
            break;
            
        default:
            break;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.textField = textField;
    NSInteger tag = textField.tag - 100;
    CGFloat h = (tag + 1) * RowHeight;
    
    //在这里+45的意思是因为前一个输入框因为是密码输入，所以他的键盘高度比其他的小45，所以在tag为7的时候为了在点击“NEXT”时不遮挡住输入框必须的+45
    if (tag == 7) {
        self.keyBoardHeight = self.keyBoardHeight + 45;
    }
    
    //获取是否需要滚动来避免输入框被键盘挡住
    CGFloat offSet = ScreenHeight - NavibarHeight - (self.keyBoardHeight + h) - 10;

    if (offSet < 0) {
        [UIView animateWithDuration:self.duration delay:0 options:self.option animations:^{
            self.tableView.transform = CGAffineTransformMakeTranslation(0, offSet);
        } completion:^(BOOL finished) {
            
        }];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    switch (textField.tag - 100) {
        case 0:
            self.CRCID = text;
            break;
        case 1:
            self.SimCard = text;
            break;
        case 2:
            self.DevName = text;
            break;
        case 3:
            self.GroupName = text;
            break;
        case 4:
            self.CustName = text;
            break;
        case 5:
            self.LoginName = text;
            break;
        case 6:
            self.Password = text;
            break;
        case 7:
            self.ParentName = textField.text;
            break;
        default:
            break;
    }
    
    if ([self checkStr:self.CRCID] && [self checkStr:self.SimCard] && [self checkStr:self.DevName] && [self checkStr:self.GroupName] && [self checkStr:self.CustName] && [self checkStr:self.LoginName] && [self checkStr:self.Password] && [self checkStr:self.ParentName]) {
        [_sendBtn setTitleColor:RGBA(255, 255, 255, 1) forState:UIControlStateNormal];
        _sendBtn.enabled = YES;
        _sendBtn.userInteractionEnabled = YES;
    } else {
        [_sendBtn setTitleColor:RGBA(153, 153, 153, 1) forState:UIControlStateNormal];
        _sendBtn.enabled = NO;
        _sendBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - 键盘弹出与退出
- (void)registerNoti{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //键盘高度
    CGFloat height = keyboardRect.size.height;
    //动画时间
    self.duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //动画类型
    self.option = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    self.keyBoardHeight = height;
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:self.duration delay:0 options:self.option animations:^{
        self.tableView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__func__);
}

- (void)showNotiView{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"注册成功！" message:@"用户可以访问平台（www.frigate-iot.com）进行修改密码、客户地址、报警联系人等信息，并可通过关注“福瑞特”公众号设置接收报警信息。" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定，并退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取导航控制中子控制器的个数
        NSArray *naviChilds = self.navigationController.childViewControllers;
        NSMutableArray *arr = [NSMutableArray array];
        //只获取第一个
        if (naviChilds.count >= 3) {
             [arr addObject:naviChilds[0]];
        }
        [self.navigationController setViewControllers:arr animated:YES];
        
    }]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
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
