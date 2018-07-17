
//  TFLoginViewController.m
//  ElecSafely
//
//  Created by Tianfu on 23/12/2017.
//  Copyright © 2017 Tianfu. All rights reserved.
//

#define SquareWith 320

#import "TFLoginViewController.h"
#import "ElecProgressHUD.h"
#import "XWSMainViewController.h"
#import "XWSNavigationController.h"
#import "XWSSettingPasswordViewController.h"

@interface TFLoginViewController ()<UITextFieldDelegate,TFLoginProgramDelegate>

@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UITextField *passWordTF;
@property (nonatomic, strong) UIView *loginSquare;
@property (nonatomic, strong) ElecProgressHUD *progressHUD;
@property (nonatomic, strong) UIButton *registerBtn;

@end

@implementation TFLoginViewController

- (ElecProgressHUD *)progressHUD{
    if (!_progressHUD) {
         _progressHUD = [[ElecProgressHUD alloc] init];
    }
    return _progressHUD;
}

- (instancetype)initWithFrame:(CGRect)frame {
    [self initUI];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
// 18 4 24
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self FieldDidChange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)initUI {
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backImage.image = [UIImage imageNamed:@"bg"];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    logoView.image = [UIImage imageNamed:@"logo"];
    
    [self.view addSubview:backImage];
    [self.view addSubview:logoView];

    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(101);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(146);
    }];
    
    [self.view addSubview:self.loginSquare];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            
            _loginSquare.center = CGPointMake(_loginSquare.center.x, 133+_loginSquare.frame.size.height/2);
        } completion:^(BOOL finished) {
            
            [_loginSquare mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(133);
            }];
            _userNameTF.userInteractionEnabled = YES;
            _passWordTF.userInteractionEnabled = YES;

            if (_userNameTF.text.length == 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_userNameTF becomeFirstResponder];
                });
            }
            else if (_passWordTF.text.length == 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_passWordTF becomeFirstResponder];;
                });
            }
        }];
    });
}



- (void)FieldDidChange {
    if (_userNameTF.text.length > 0 && _passWordTF.text.length > 0) {
        
        if (_passWordTF.text.length < 6 || _passWordTF.text.length > 16) {
            _loginBtn.backgroundColor = UIColorRGB(0xacacac);
            _loginBtn.userInteractionEnabled = NO;
        }else{
            _loginBtn.backgroundColor = UIColorRGB(0x2061f6);
            _loginBtn.userInteractionEnabled = YES;
        }
    }
    else if (_userNameTF.text.length == 0 || _passWordTF.text.length == 0) {
        
        _loginBtn.backgroundColor = UIColorRGB(0xacacac);
        _loginBtn.userInteractionEnabled = NO;
    }
}

#pragma make 控件
- (UIView *)loginSquare {
    if (!_loginSquare) {
        
        UIView *loginSquare = [[UIView alloc] initWithFrame:CGRectZero];
        loginSquare.backgroundColor = [UIColor clearColor];
        [self.view addSubview:loginSquare];
        
        [loginSquare mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).equalTo(168);
            make.centerX.mas_equalTo(self.view.centerX);
            make.height.mas_equalTo(276);
            make.width.mas_equalTo(SquareWith);
        }];
        
        // 登陆按钮
        [loginSquare addSubview:self.loginBtn];

        [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SquareWith);
            make.height.mas_equalTo(40);
            make.centerX.mas_equalTo(loginSquare.centerX);
            make.bottom.mas_equalTo(loginSquare.bottom);
        }];
        
        [self.view addSubview:self.registerBtn];
        //注册按钮
        [_registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.trailing.mas_equalTo(-20);
            make.bottom.mas_equalTo(-20);
            make.width.mas_equalTo(50);
        }];
        
        // 密码行
        UIView *passWordLine = [[UIView alloc] initWithFrame:CGRectZero];
        passWordLine.backgroundColor = UIColorRGB(0x525252);
        [loginSquare addSubview:passWordLine];
        [passWordLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SquareWith);
            make.centerX.mas_equalTo(loginSquare.centerX);
            make.bottom.mas_equalTo(_loginBtn.mas_top).offset(-67);
            make.height.mas_equalTo(0.8f);
        }];

        // 密码输入框
        [loginSquare addSubview:self.passWordTF];
        [_passWordTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SquareWith);
            make.bottom.mas_equalTo(passWordLine.mas_top).offset(-14);
            make.centerX.mas_equalTo(loginSquare.mas_centerX);
        }];

        // 账号行
        UIView *userNameLine = [[UIView alloc] initWithFrame:CGRectZero];
        userNameLine.backgroundColor = UIColorRGB(0x525252);
        [loginSquare addSubview:userNameLine];
        [userNameLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SquareWith);
            make.centerX.mas_equalTo(loginSquare.centerX);
            make.bottom.mas_equalTo(passWordLine.mas_top).offset(-67);
            make.height.mas_equalTo(0.5f);

        }];

        // 用户名输入框
        [loginSquare addSubview:self.userNameTF];
        [_userNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SquareWith);
            make.centerX.mas_equalTo(loginSquare.mas_centerX);
            make.bottom.mas_equalTo(userNameLine.mas_top).offset(-14);
        }];

        _loginSquare = loginSquare;

    }
    return _loginSquare;
}

- (UIButton *)registerBtn {
    if (_registerBtn == nil){
        UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
        registerBtn.backgroundColor = [UIColor clearColor];
        registerBtn.userInteractionEnabled = YES;
        [registerBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
        registerBtn.titleLabel.font = PingFangRegular(15);
        [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registerBtn setTitleColor:UIColorRGB(0xacacac) forState:UIControlStateHighlighted];
        registerBtn.layer.cornerRadius = 20;
        registerBtn.layer.masksToBounds= YES;
        _registerBtn = registerBtn;
    }
    return _registerBtn;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
        loginBtn.backgroundColor = UIColorRGB(0xacacac);
        loginBtn.userInteractionEnabled = YES;
        [loginBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
        loginBtn.titleLabel.font = PingFangRegular(17);
//        loginBtn.titleLabel.textColor = RGBA(85, 85, 85, 1);
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn setTitleColor:UIColorRGB(0xacacac) forState:UIControlStateHighlighted];
        loginBtn.layer.cornerRadius = 20;
        loginBtn.layer.masksToBounds= YES;
        _loginBtn = loginBtn;
    }
    return _loginBtn;
}

- (UITextField *)userNameTF {
    if (!_userNameTF) {
        UITextField *userNameTF = [[UITextField alloc] initWithFrame:CGRectZero];
        userNameTF.keyboardType = UIKeyboardTypeASCIICapable;
        userNameTF.userInteractionEnabled = NO;
        NSString *userTips =  @"请输入用户账号";
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:userTips];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:RGBA(102, 102, 102, 1)
                            range:NSMakeRange(0, userTips.length)];
        [placeholder addAttribute:NSFontAttributeName
                            value:PingFangRegular(16)
                            range:NSMakeRange(0, userTips.length)];
        userNameTF.attributedPlaceholder = placeholder;
        userNameTF.font = PingFangRegular(16);
        userNameTF.delegate = self;
        userNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        userNameTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        userNameTF.backgroundColor = [UIColor clearColor];
        userNameTF.textColor = RGBA(221, 221, 221, 1);
        _userNameTF = userNameTF;
        NSString *userAccount = [[NSUserDefaults standardUserDefaults] objectForKey:UserAccount];
        if (userAccount.length > 0) {
            _userNameTF.text = userAccount;
        }
    }
    return _userNameTF;
}

- (UITextField *)passWordTF {
    if (!_passWordTF) {
        UITextField *passWordTF = [[UITextField alloc] initWithFrame:CGRectZero];
        passWordTF.secureTextEntry = YES;
        passWordTF.keyboardType = UIKeyboardTypeASCIICapable;
        passWordTF.userInteractionEnabled = NO;
        NSString *passTips = @"请输入密码";
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:passTips];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:RGBA(102, 102, 102, 1)
                            range:NSMakeRange(0, passTips.length)];
        [placeholder addAttribute:NSFontAttributeName
                            value:PingFangRegular(16)
                            range:NSMakeRange(0, passTips.length)];
        passWordTF.attributedPlaceholder = placeholder;
        passWordTF.delegate = self;
        passWordTF.font = PingFangRegular(16);
        passWordTF.backgroundColor = [UIColor clearColor];
        passWordTF.textColor = RGBA(221, 221, 221, 1);
        _passWordTF = passWordTF;
        if ([TFLoginProgram getPassword].length > 0) {
            _passWordTF.text = [TFLoginProgram getPassword];
        }
    }
    return _passWordTF;
}

- (void)registerAction {
    XWSSettingPasswordViewController *registerVC = [[XWSSettingPasswordViewController alloc] init];
    registerVC.type = XWSShowVCTypeRegister;
    XWSNavigationController *navi = [[XWSNavigationController alloc] initWithRootViewController:registerVC];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)sureAction {
    _loginBtn.userInteractionEnabled = NO;
    [_userNameTF resignFirstResponder];
    [_passWordTF resignFirstResponder];
    
    NSString *nameStr = [_userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passWordStr = [_passWordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(nameStr && ![nameStr isEqualToString:@""] && ![passWordStr isEqualToString:@""]) {
        

        [_progressHUD showHUD:self.view Offset:0 animation:18];

        [[TFLoginProgram sharedInstance] userLoginWithAccount:nameStr passWord:passWordStr];
        [TFLoginProgram sharedInstance].delegate = self;
    }
}

#pragma mark loginProgramDelegate
- (void)loginProgram:(TFLoginProgram *)program DidLoginSuccess:(NSString *)account passWord:(NSString *)password {
    [ElecTipsView showTips:@"登陆成功"];
    [_progressHUD dismiss];
    
    XWSMainViewController *vc = [[XWSMainViewController alloc] init];
    XWSNavigationController *nv = [[XWSNavigationController alloc] initWithRootViewController:vc];

    [UIApplication sharedApplication].keyWindow.rootViewController = nv;
    _loginBtn.userInteractionEnabled = YES;
}

- (void)loginProgram:(TFLoginProgram *)program DidLoginFailed:(NSString *)error {
    [ElecTipsView showTips:error];
    _loginBtn.userInteractionEnabled = YES;
}

- (void)dealloc{
//    NSLog(@"%s",__func__);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _userNameTF) {
        [_passWordTF becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
