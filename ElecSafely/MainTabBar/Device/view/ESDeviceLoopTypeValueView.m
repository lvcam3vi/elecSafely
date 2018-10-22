//
//  ESDeviceLoopTypeValueView.m
//  ElecSafely
//
//  Created by lhb on 2018/3/6.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "ESDeviceLoopTypeValueView.h"
#import "ESDeviceData.h"
#import "UILabel+Create.h"

static const CGFloat TopHeight = 55.0;
static const CGFloat BottomHeight = 80.0;
static const CGFloat RowHeight = 35.0;

static const CGFloat ButtonWidth = 70.0;
static const CGFloat ButtonHeight = 30.0;

static const CGFloat Margin = 15.0;

#define TEXT_COLOR [UIColor colorWithRed:0.63 green:0.64 blue:0.64 alpha:1.00]

typedef void(^ClickResetBtn)(void);
typedef void(^ClickQueryBtn)(void);

@interface ESDeviceLoopTypeValueView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UIView *_topView;
    UIView *_bottomView;
    
    NSArray *_loopDatas;
    
    ClickQueryBtn _queryBlock;
    ClickResetBtn _resetBlock;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ESDeviceLoopTypeValueView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:1.00];
        self.clipsToBounds = YES;
        
        [self setUpBothEndsView];
    }
    return self;
}

///创建头尾视图
- (void)setUpBothEndsView{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width_ES, TopHeight)];
    [self addSubview:_topView];
    
    CGFloat width = self.width_ES/3;
    for (int i = 0; i < 3; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width * i, 15, width, TopHeight - 15)];
        [_topView addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = TEXT_COLOR;
    
        if (i == 0) {
            label.text = @"回路类型";
        }
        if (i == 1) {
            label.text = @"探测值";
        }
        if (i == 2) {
            label.text = @"报警值";
        }
    }
    
    [self setUpEndView];
}

///创建复位、查询按钮
- (void)setUpEndView{
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, TopHeight, self.width_ES, BottomHeight)];
    [self addSubview:_bottomView];
    
    __unused UIButton *resetB = [self buttonWithFrame:CGRectMake(self.width_ES - 2*Margin - 2*ButtonWidth, 20, ButtonWidth, ButtonHeight) title:@"复位" selector:@selector(resetDeviceData:)];
    
    __unused UIButton *queryB = [self buttonWithFrame:CGRectMake(self.width_ES - Margin - ButtonWidth, 20, ButtonWidth, ButtonHeight) title:@"查询" selector:@selector(queryDeviceData:)];
}

- (UIButton *)buttonWithFrame:(CGRect)rect title:(NSString *)title selector:(SEL)selector{
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    [_bottomView addSubview:button];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = FONT(16);
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = TEXT_COLOR.CGColor;
    button.layer.cornerRadius = ButtonHeight/2;
    return button;
}

///复位
- (void)resetDeviceData:(UIButton *)sender{
    if (_resetBlock) {
        _resetBlock();
    }
}

///查询
- (void)queryDeviceData:(UIButton *)sender{
    if (_queryBlock) {
        _queryBlock();
    }
}


///列表
- (UICollectionView *)collectionView{
    
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, TopHeight, self.width_ES, 0) collectionViewLayout:layout];
        [self addSubview:_collectionView];
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:ESDeviceValueCell.class forCellWithReuseIdentifier:NSStringFromClass(ESDeviceValueCell.class)];
    }
    return _collectionView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.width_ES/3.0, RowHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _loopDatas.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ESDeviceValueCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ESDeviceValueCell.class) forIndexPath:indexPath];
    
    XWSDeviceLoopData *data = _loopDatas[indexPath.section];
    if (indexPath.item == 0) {
        cell.textLabel.text = data.showLoopName;
    }else if (indexPath.item == 1){
        cell.textLabel.text = [NSString stringWithFormat:@"%@",data.showDetectValue];
    }else{
        cell.textLabel.text = data.showScopeValue;
    }
    
    return cell;
}

///加载数据
- (void)loadLoopDatas:(NSArray<XWSDeviceLoopData *> *)loopDatas clickQuery:(void (^)(void))queryBlock clickReset:(void (^)(void))resetBlock{
    
    if (loopDatas.count == 0) return;
    
    _loopDatas = loopDatas;
    
    _queryBlock = queryBlock;
    _resetBlock = resetBlock;
    
    //自己的高度
    self.height_ES = TopHeight + loopDatas.count * RowHeight + BottomHeight;
    
    self.collectionView.height_ES = loopDatas.count * RowHeight;
    _bottomView.top_ES = self.collectionView.bottom_ES;
    
    [self.collectionView reloadData];
}


@end


/*
 * cell
 */
@implementation ESDeviceValueCell

- (UILabel *)textLabel{
    
    if (_textLabel == nil) {
        _textLabel = [UILabel createWithFrame:self.bounds
                                         text:@""
                                    textColor:TEXT_COLOR
                                textAlignment:NSTextAlignmentCenter
                                   fontNumber:17];
        [self addSubview:_textLabel];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return _textLabel;
}



@end

