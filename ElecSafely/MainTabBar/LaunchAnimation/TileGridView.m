//
//  TileGridView.m
//  Uber_Lacunch_OC
//
//  Created by Durand on 3/9/16.
//  Copyright © 2016年 com.Durand. All rights reserved.
//

#define UIColorRGB(rgb) ([[UIColor alloc] initWithRed:(((rgb >> 16) & 0xff) / 255.0f) green:(((rgb >> 8) & 0xff) / 255.0f) blue:(((rgb) & 0xff) / 255.0f) alpha:1.0f])


#import "TileView.h"
#import "TileGridView.h"
#import "Contans.h"
#import "JTSlideShadowAnimation.h"

@interface TileGridView ()
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) TileView *modelTileView;
@property (nonatomic,strong) TileView *centerTileView;
@property (nonatomic,assign) int numberOfRows;
@property (nonatomic,assign) int numberOfColumns;

@property (nonatomic,strong) UILabel *logoLabel;
@property (nonatomic,strong) UILabel *newlogoLabel;
@property (nonatomic,strong) UILabel *companyLabel;
@property (nonatomic,strong) UIImageView *companyImage;
@property (nonatomic,strong) NSMutableArray *tileViewRows;
@property (nonatomic,assign) CFTimeInterval beginTime;
@property (nonatomic,assign) NSTimeInterval kRippleDelayMultiplier;

@property (nonatomic, strong) JTSlideShadowAnimation *shadowCompanyAnimation;

@property (nonatomic, strong) JTSlideShadowAnimation *shadowLogoAnimation;
@end

@implementation TileGridView

-(instancetype)initWithTileFileName:(NSString *)name
{
    _modelTileView = [[TileView alloc] initWithTitleFileName:name];
    self = [super initWithFrame: [UIScreen mainScreen].bounds];
    if (self)
    {
        _numberOfRows = 0;
        _numberOfColumns = 0;
        _beginTime = 0;
        _tileViewRows = [NSMutableArray array];
        _kRippleDelayMultiplier = 0.0006666;
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 630, 990)];
        _containerView.backgroundColor = UberBlue;
        _containerView.clipsToBounds = NO;
        _containerView.layer.masksToBounds = NO;
        [self addSubview:_containerView];
        
        //画格子
        [self renderTileViews];
        
//        _logoLabel = [self generateLogoLabel];
        _newlogoLabel = [self newLogoLabel];
        _companyLabel = [self companyLabel];
//        [_centerTileView addSubview:_logoLabel];
        
        [self addSubview:_companyLabel];
        [self addSubview:_newlogoLabel];
        [self layoutIfNeeded];
        
        [self setUpShadowAnimation];

    }
    return self;
}

- (void)setUpShadowAnimation{
    //company
//    self.shadowCompanyAnimation = [self getShadowAnimationWithView:_companyLabel];

    //newLogoLabel
//    self.shadowLogoAnimation = [self getShadowAnimationWithView:_newlogoLabel];
}

- (JTSlideShadowAnimation *)getShadowAnimationWithView:(UIView *)view{
    JTSlideShadowAnimation *animation = [[JTSlideShadowAnimation alloc] init];
    animation.shadowBackgroundColor = [UIColor colorWithWhite:1. alpha:.7];
    animation.shadowForegroundColor = [UIColor whiteColor];
    animation.animatedView = view;
    animation.duration = 1.5f;
    animation.shadowWidth = 40.;
    return animation;
}

- (void)startAnimating
{
    _beginTime = CACurrentMediaTime();
    [self startAnimatingWithBeginTime:_beginTime];
    [self.shadowCompanyAnimation start];
    [self.shadowLogoAnimation start];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _containerView.center = self.center;
    _modelTileView.center = _containerView.center;
    if (_centerTileView) {
        // Custom offset needed for UILabel font
//        CGPoint center = CGPointMake(CGRectGetMidX(_centerTileView.bounds), CGRectGetMidY(_centerTileView.bounds));
//        _logoLabel.center = center;
    }
}

- (UILabel *)generateLogoLabel
{
    UILabel *label = [UILabel new];
    label.text = @"                        小武松";
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:30];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    return label;
}

- (UILabel *)newLogoLabel
{
    UILabel *label = [UILabel new];
    label.text = @"智慧用电";
    label.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:20];
    label.textColor = UIColorRGB(0xAAAAAA);
    [label sizeToFit];
    label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    return label;
}

- (UILabel *)companyLabel
{
    UILabel *label = [UILabel new];
    label.text = @"中山市福瑞特科技产业有限公司";
    label.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    label.textColor = UIColorRGB(0xAAAAAA);
    [label sizeToFit];
    label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) - 100);
    return label;
}

- (UIImageView *)companyImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_min"]];
    imageView.frame = CGRectMake(100, CGRectGetMidY(self.bounds) - 100, 20, 20);
    return imageView;
}

- (void)renderTileViews
{
    CGFloat width,height,modelImageWidth,modelImageHeight;
    
    width = CGRectGetWidth(_containerView.bounds);
    height = CGRectGetHeight(_containerView.bounds);
    
    modelImageWidth = CGRectGetWidth(_modelTileView.bounds);
    modelImageHeight = CGRectGetHeight(_modelTileView.bounds);
    
    _numberOfColumns = (int)(ceil((width - _modelTileView.bounds.size.width / 2.0) / _modelTileView.bounds.size.width));
    
    _numberOfRows = (int)(ceil((height - _modelTileView.bounds.size.height / 2.0) / _modelTileView.bounds.size.height));
    
    for (int  y = 0; y < _numberOfRows; y++) {
        NSMutableArray<TileView *> *tileRows = [NSMutableArray array];
        for (int x = 0; x < _numberOfColumns; x++) {
            TileView *view = [[TileView alloc] init];
            view.frame = CGRectMake(x * modelImageWidth, y * modelImageHeight, modelImageWidth, modelImageHeight);
            if (CGPointEqualToPoint(view.center, _containerView.center)) {
                _centerTileView = view;
            }
            
            [_containerView addSubview:view];
            [tileRows addObject:view];
            
            if (y && y != _numberOfRows - 1 && x && x != _numberOfColumns) {
                view.shouldEnableRipple = YES;
            }
         }
        
        [_tileViewRows addObject:tileRows];
    }
    
    if (_centerTileView) {
        [_containerView bringSubviewToFront:_centerTileView];
    }
    
}

- (void)startAnimatingWithBeginTime:(NSTimeInterval)beginTime
{
    CAMediaTimingFunction *linearTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAKeyframeAnimation *keyframe = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    keyframe.timingFunctions = @[linearTimingFunction,[[CAMediaTimingFunction alloc] initWithControlPoints:0.6 :0.0 :0.15 :1.0],linearTimingFunction];
    keyframe.repeatCount = 1;
    keyframe.duration = kAnimationDuration;
    keyframe.removedOnCompletion = NO;
    keyframe.keyTimes = @[@0.0, @0.045, @0.0887, @0.09,@1.0];
    keyframe.values = @[@0.75, @0.75, @1.0, @1.0,@1.0];
    keyframe.beginTime = beginTime;
    
    keyframe.timeOffset = kAnimationTimeOffset;
    
    [_containerView.layer addAnimation:keyframe forKey:@"scale"];
    
    for (NSArray *tileRows in _tileViewRows) {
        for (TileView *view in tileRows) {
            CGFloat distance = [self distanceFromCenterViewWithView:view];
            CGPoint vector = [self normalizedVectorFromCenterViewToView:view];
            
            vector = CGPointMake(vector.x * _kRippleDelayMultiplier * distance, vector.y * _kRippleDelayMultiplier * distance);
            
            [view startAnimatingWithDuration:kAnimationDuration beginTime:beginTime rippleDelay:_kRippleDelayMultiplier * (NSTimeInterval)distance rippleOffset:vector];
        }
    }
    
    
    NSValue *zeroPointValue = [NSValue valueWithCGPoint:CGPointZero];
    NSMutableArray *animations = [[NSMutableArray alloc] initWithCapacity:0];
    CAMediaTimingFunction *timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.25 :0 :0.2 :1];
    CAMediaTimingFunction *linearFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    CAMediaTimingFunction *easeOutFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    CAMediaTimingFunction *easeInOutTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    NSNumber *begin123 = @0.075;
    // Opacity
    CAKeyframeAnimation *labelAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    labelAnimation.duration = kAnimationDuration;
    labelAnimation.timingFunctions = @[easeInOutTimingFunction, timingFunction, timingFunction, easeOutFunction, linearFunction];
    labelAnimation.keyTimes = @[@0.0,begin123,@0.13,@1.0];
    labelAnimation.values = @[@0,@0,@1,@1];
    labelAnimation.beginTime = beginTime;
    [_companyLabel.layer addAnimation:labelAnimation forKey:@"opacity"];
    
    // Position
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = kAnimationDuration;
    positionAnimation.timingFunctions = @[linearFunction, timingFunction, timingFunction, linearFunction];
    positionAnimation.keyTimes = @[@0.0,begin123,@0.13];
    positionAnimation.values = @[zeroPointValue, zeroPointValue, [NSValue valueWithCGPoint:CGPointMake(0, -50)]];
    positionAnimation.additive = YES;
    [animations addObject:positionAnimation];

    
    // Opacity
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = kAnimationDuration;
    opacityAnimation.timingFunctions = @[easeInOutTimingFunction, timingFunction, timingFunction, easeOutFunction, linearFunction];
    opacityAnimation.keyTimes = @[@0.0,begin123,@0.13,@1.0];
    opacityAnimation.values = @[@0.0,@0.0,@1,@0];
    [animations addObject:opacityAnimation];
    
    // Group
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.repeatCount = 1;
    groupAnimation.fillMode = kCAFillModeBackwards;
    groupAnimation.duration = 30;
    groupAnimation.beginTime = beginTime + _kRippleDelayMultiplier;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.animations = animations;
    groupAnimation.timeOffset = kAnimationTimeOffset;
    [_newlogoLabel.layer addAnimation:groupAnimation forKey:@"ripple"];
    
    
}

- (CGFloat)distanceFromCenterViewWithView:(UIView *)view
{
    if (!_centerTileView) {
        return 0;
    }
    
    CGFloat normalizedX = view.center.x - _centerTileView.center.x;
    CGFloat normalizedY = view.center.y - _centerTileView.center.y;
    return sqrt(normalizedX * normalizedX + normalizedY * normalizedY);
}

- (CGPoint)normalizedVectorFromCenterViewToView:(UIView *)view
{
    CGFloat length = [self distanceFromCenterViewWithView:view];
    
    if (!_centerTileView || !length) {
        return CGPointZero;
    }
    
    CGFloat deltaX = view.center.x - _centerTileView.center.x;
    CGFloat deltaY = view.center.y - _centerTileView.center.y;
    return CGPointMake(deltaX / length, deltaY / length);
}

- (void)dealloc{
    [self.shadowLogoAnimation stop];
    [self.shadowCompanyAnimation stop];
//    NSLog(@"%s",__func__);
}

@end
