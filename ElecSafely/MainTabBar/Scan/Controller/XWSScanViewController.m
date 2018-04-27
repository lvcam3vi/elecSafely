//
//  XWSScanViewController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/23.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSScanViewController.h"
#import "XWSScanView.h"
#import "XWSScanInfoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+HGCorner.h"
#import "LCQRCodeUtil.h"

#define FRIGATE @"frigate"
#define FRIGATE_LENGHT FRIGATE.length
#define FRIGATE_CRCID_LENGHT 15

#define ScanViewWidth 274.0f
#define ScanViewHeight ScanViewWidth

#define TOP 140.0
#define LableTopToScanView 34.0f
#define LabelHeight 30.0
#define AutoBtnHeight 40.0
#define LEFT (ScreenWidth - ScanViewWidth)/2

#define kScanRect CGRectMake(LEFT, TOP, ScanViewWidth, ScanViewHeight)

#define ScanRepeatInterval 0.01
#define PerChangeHeight 1

@interface XWSScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    CAShapeLayer *cropLayer;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

/*扫描框*/
@property (nonatomic, strong) XWSScanView *scanView;
/*提示标签*/
@property (nonatomic, strong) UILabel *label;
/*手动按钮*/
@property (nonatomic, strong) UIButton *autoBtn;
/* 扫描条*/
@property (nonatomic, strong) UIImageView *lineIamgeView;

/*滚动条定时器*/
@property (nonatomic, strong) NSTimer *timer;
/*扫描条的y值*/
@property (nonatomic, assign) CGFloat scanTop;

/*选择图片*/
@property (nonatomic, strong) UIImagePickerController *ipc;

@property (nonatomic, strong) ElecProgressHUD *progressHUD;
@end

@implementation XWSScanViewController

- (ElecProgressHUD *)progressHUD{
    if (!_progressHUD) {
        _progressHUD = [[ElecProgressHUD alloc] init];
    }
    return _progressHUD;
}

- (UIButton *)autoBtn{
    if (!_autoBtn) {
        _autoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:_autoBtn];
        [_autoBtn setTitle:@"手动输入" forState:UIControlStateNormal];
        [_autoBtn setTitleColor:RGBA(221, 221, 221, 0.9) forState:UIControlStateNormal];
        _autoBtn.backgroundColor = BackColor;
        _autoBtn.titleLabel.font = PingFangRegular(17);
        
        CGFloat y = (ScreenHeight - (TOP + ScanViewHeight + LableTopToScanView + LabelHeight + NavibarHeight)) * 0.5 - AutoBtnHeight;
        [_autoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.height.mas_equalTo(AutoBtnHeight);
            make.width.mas_equalTo(164);
            make.top.mas_equalTo(_label.mas_bottom).mas_equalTo(y);
        }];
        
        _autoBtn.layer.borderColor = UIColorRGB(0x8a8b90).CGColor;
        _autoBtn.layer.borderWidth = 1;
        _autoBtn.layer.cornerRadius = AutoBtnHeight * 0.5;
        _autoBtn.layer.masksToBounds = YES;
        
        [_autoBtn addTarget:self action:@selector(gotoAutoInput:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _autoBtn;
}

- (XWSScanView *)scanView{
    if (!_scanView) {
        _scanView = [[XWSScanView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_scanView];
        [_scanView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(TOP);
            make.width.height.mas_equalTo(ScanViewHeight);
        }];
    }
    return _scanView;
}

- (UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.height.mas_equalTo(LabelHeight);
            make.width.mas_equalTo(164);
            make.top.mas_equalTo(_scanView.mas_bottom).mas_equalTo(LableTopToScanView);
        }];
        
        _label.text = @"放入框内，自动扫描";
        _label.font = PingFangMedium(14);
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = RGBA(221,221,221,1.0);
        _label.textAlignment = NSTextAlignmentCenter;
//        _label.layer.borderColor = UIColorRGB(0x8a8b90).CGColor;
//        _label.layer.borderWidth = 1;
//        _label.layer.cornerRadius = 15;
//        _label.layer.masksToBounds = YES;
    }
    return _label;
}

- (UIImageView *)lineIamgeView{
    if (!_lineIamgeView) {
        _lineIamgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan"]];
        _lineIamgeView.frame = CGRectMake(LEFT, TOP, ScanViewWidth, 2);
        _lineIamgeView.hidden = YES;
        [self.view addSubview:_lineIamgeView];
    }
    return _lineIamgeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor whiteColor];
    self.scanTop = TOP;
//    [self setUpNavi];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //扫描二维码的出生位置
    [self configView];
    [self setCropRect:kScanRect];
    [self setupCamera];
    //延迟
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:0.3];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopTimer];
}

- (void)setUpNavi{
    
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [sendBtn setTitle:@"相册" forState:UIControlStateNormal];
    [sendBtn setTitleColor:RGBA(255, 255, 255, 1) forState:UIControlStateNormal];
    sendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    sendBtn.titleLabel.font = PingFangMedium(15);
    [sendBtn addTarget:self action:@selector(openPhotoLib) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendBtn];

}

#pragma mark - 打开相册
- (void)openPhotoLib{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) return;
    
    if (!_ipc) {
        _ipc = [[UIImagePickerController alloc] init];
        _ipc.delegate = self;
        _ipc.allowsEditing = YES;
        _ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //停止扫描
    [_session stopRunning];
    [self stopTimer];
    
    [self presentViewController:_ipc animated:YES completion:nil];
}

#pragma mark - uiimagePicke
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //如果是拍照，则拍照后把图片保存在相册
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [self.progressHUD showHUD:self.view Offset:-NavibarHeight animation:18];
    [picker dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *imageStr = [LCQRCodeUtil readQRCodeFromImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_progressHUD dismiss];
                [self showScanResultWithStr:imageStr];
            });
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //继续扫描
        if (_session != nil) {
            [_session startRunning];
            [self startTimer];
        }
    }];
}

#pragma mark - 设置扫描框和提示语
-(void)configView{
    [self scanView];
    [self label];
    [self autoBtn];
    [self lineIamgeView];
    _autoBtn.enabled = YES;
}

- (void)setCropRect:(CGRect)cropRect{
    if (!cropLayer) {
        cropLayer = [[CAShapeLayer alloc] init];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, nil, cropRect);
        CGPathAddRect(path, nil, self.view.bounds);
        
        [cropLayer setFillRule:kCAFillRuleEvenOdd];
        [cropLayer setPath:path];
        [cropLayer setFillColor:UIColorRGB(0x000000).CGColor];
        [cropLayer setOpacity:0.5];
        
        [cropLayer setNeedsDisplay];
        
        [self.view.layer addSublayer:cropLayer];
    }
}

- (void)setupCamera
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    if (!_input) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    
    // Output
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置扫描区域
        CGFloat top = TOP/ScreenHeight;
        CGFloat left = LEFT/ScreenWidth;
        CGFloat width = ScanViewWidth/ScreenWidth;
        CGFloat height = ScanViewHeight/ScreenHeight;
        ///top 与 left 互换  width 与 height 互换
        [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    }

    // Session
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input])
        {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output])
        {
            [_session addOutput:self.output];
        }
        
        // 条码类型 AVMetadataObjectTypeQRCode
        [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    }
    
    // Preview
    [_preview removeFromSuperlayer];
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        [self stopTimer];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        NSString *stringValue = metadataObject.stringValue;
//        NSLog(@"扫描结果：%@",stringValue);
        
        [self showScanResultWithStr:stringValue];
    } else {
//        NSLog(@"无扫描信息");
        return;
    }
}

/*扫描到符合规则的二维码数据*/
- (void)showScanResultWithStr:(NSString *)str{
    //http://www.frigate-iot.com/API/Register.php?code=frigate+ID+SIMCARD

    NSArray *strs = [str componentsSeparatedByString:@"="];
    if (strs.count == 2) {
        NSString *QRstr = strs[1];
        //二维码的规则必须是frigate+id+卡号，其他id的长度是16位
        if (QRstr.length >= FRIGATE_LENGHT + FRIGATE_CRCID_LENGHT) {
            if ([QRstr hasPrefix:FRIGATE]) {
                //截取ID
                NSRange r = {FRIGATE_LENGHT,FRIGATE_CRCID_LENGHT};
                NSString *IdStr = [QRstr substringWithRange:r];
                //截取卡号
                
                NSString *simCardStr = [QRstr substringFromIndex:FRIGATE_LENGHT + FRIGATE_CRCID_LENGHT];
                simCardStr = [simCardStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                simCardStr = [simCardStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                
                [self gotoDeviceInfoVCWithType:XWSDeviceInputTypeAuto withDeviceId:IdStr withSimCardId:simCardStr];
            }else{
                [self showErrorNoti];
            }
        }else{
            [self showErrorNoti];
        }
    }
}

- (void)gotoDeviceInfoVCWithType:(XWSDeviceInputType)type withDeviceId:(NSString *)deviceId withSimCardId:(NSString *)simCardId{

    XWSScanInfoViewController *vc = [[XWSScanInfoViewController alloc] init];
    vc.deviceId = deviceId;
    vc.simCardId = simCardId;
    vc.type = type;
    
    [self.navigationController pushViewController:vc animated:YES];
}

/*二维码数据不符合要求*/
- (void)showErrorNoti{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"数据不符合规则，请扫描正确的二维码信息" message:@"继续扫描二维码？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_session != nil) {
            [_session startRunning];
            [self startTimer];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 点击手动输入
- (void)gotoAutoInput:(UIButton *)sender{
    sender.enabled = NO;
    [_session stopRunning];
    [self stopTimer];
    [self gotoDeviceInfoVCWithType:XWSDeviceInputTypeManual withDeviceId:nil withSimCardId:nil];
}

#pragma mark 横线的动画
- (void)stopTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        CGRect frame = self.lineIamgeView.frame;
        frame.origin.y = self.scanTop;
        self.lineIamgeView.frame = frame;
        _lineIamgeView.hidden = YES;
        self.scanTop = TOP;
    }
}

- (void)startTimer{
    _lineIamgeView.hidden = NO;
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:ScanRepeatInterval target:self selector:@selector(scanQR) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}
- (void)scanQR{
    self.scanTop += PerChangeHeight;
    if (self.scanTop / (TOP + ScanViewWidth) >= 1.0) {
        self.scanTop = TOP;
    }
    CGRect frame = self.lineIamgeView.frame;
    frame.origin.y = self.scanTop;
    self.lineIamgeView.frame = frame;
}


- (void)dealloc{
//    NSLog(@"dealloc:%s",__func__);
    [self stopTimer];
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
