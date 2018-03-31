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

#define ScanViewWidth 274.0f
#define ScanViewHeight ScanViewWidth

#define TOP 204.0
#define LEFT (ScreenWidth - ScanViewWidth)/2

#define kScanRect CGRectMake(LEFT, TOP, ScanViewWidth, ScanViewHeight)

#define ScanRepeatInterval 0.01
#define PerChangeHeight 1

@interface XWSScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>{
    CAShapeLayer *cropLayer;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
/*滚动条定时器*/
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIImageView *lineIamgeView;
@property (nonatomic, assign) CGFloat scanTop;
@end

@implementation XWSScanViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configView];
    
    [self setCropRect:kScanRect];
    
    [self setupCamera];
    
    //扫描二维码的出生位置
    self.scanTop = TOP;
    
    //延迟
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:0.3];

}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopTimer];
}


#pragma mark - 设置扫描框和提示语
-(void)configView{
    
    XWSScanView *scanView = [[XWSScanView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:scanView];
    [scanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(TOP);
        make.width.height.mas_equalTo(ScanViewHeight);
    }];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
     [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(164);
        make.top.mas_equalTo(scanView.mas_bottom).mas_equalTo(34);
    }];
    
    label.text = @"放入框内，自动扫描";
    label.font = PingFangMedium(14);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = RGBA(221,221,221,1.0);
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.borderColor = UIColorRGB(0x8a8b90).CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = 15;
    label.layer.masksToBounds = YES;
    
    self.lineIamgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan"]];
    self.lineIamgeView.frame = CGRectMake(LEFT, TOP, ScanViewWidth, 2);
    self.lineIamgeView.hidden = YES;
    [self.view addSubview:self.lineIamgeView];
}

- (void)setCropRect:(CGRect)cropRect{
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
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    CGFloat top = TOP/ScreenHeight;
    CGFloat left = LEFT/ScreenWidth;
    CGFloat width = ScanViewWidth/ScreenWidth;
    CGFloat height = ScanViewHeight/ScreenHeight;
    ///top 与 left 互换  width 与 height 互换
    [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    
    // Session
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
    
    // Preview
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
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        [self stopTimer];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
        
        //判断扫描结果是否符合数据规则，符合则可以进行下一步，反正则弹出提示
        if (![stringValue isEqualToString:@""]) {
            
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"数据不符合规则，请扫描正确的二维码信息" message:@"确定继续扫描二维码？" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (_session != nil) {
                    [_session startRunning];
                    [self startTimer];
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        NSLog(@"无扫描信息");
        return;
    }
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

#pragma mark -
- (void)gotoDetailInfoWithDic:(NSDictionary *)dic{
    XWSScanInfoViewController *scanInfoVC = [[XWSScanInfoViewController alloc] init];
    [self.navigationController pushViewController:scanInfoVC animated:YES];
}

- (void)dealloc{
    NSLog(@"dealloc:%s",__func__);
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
