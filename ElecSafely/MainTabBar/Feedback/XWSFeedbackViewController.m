//
//  XWSFeedbackViewController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/26.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSFeedbackViewController.h"
#import "XWSFeedImageCell.h"
#define TableViewRowHeight 150.0
#define MAX_LIMIT_NUMS 300
#define MIN_LIMIT_NUMS 9

#define SIDE_MARGIN 18
#define IMAGE_MARGIN 10

#define ITEM_SIZE_WIDTH ((ScreenWidth - 2 * SIDE_MARGIN - 5 * IMAGE_MARGIN)/ 4)
#define ITEM_SIZE_HEIGHT ITEM_SIZE_WIDTH

@interface XWSFeedbackViewController ()<UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
/*站位字符标签*/
@property (nonatomic, strong) UILabel *place;
/*字数提示标签*/
@property (nonatomic, strong) UILabel *numLabel;
/*提交按钮*/
@property (nonatomic, strong) UIButton *sendBtn;
/*输入框*/
@property (nonatomic, strong) UITextView *textView;
/*显示图片的view*/
@property (nonatomic, strong) UICollectionView *collectionView;
/*添加的图片数组*/
@property (nonatomic, strong) NSMutableArray *images;
/*显示当前添加的图片个数*/
@property (nonatomic, strong) UILabel *imageCountLabel;
/*标题1*/
@property (nonatomic, strong) UILabel *titleLabel;
/*输入框容器*/
@property (nonatomic, strong) UIView *textContentView;
/*存放图片内容的勇气*/
@property (nonatomic, strong) UIView *imageContentView;
/*图片内容标题*/
@property (nonatomic, strong) UILabel *imageTitleLabel;

@property (nonatomic, strong) ElecProgressHUD *progressHUD;
@end

@implementation XWSFeedbackViewController
- (ElecProgressHUD *)progressHUD{
    if (!_progressHUD) {
        _progressHUD = [[ElecProgressHUD alloc] init];
    }
    return _progressHUD;
}
#pragma mark - 懒加载
- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(18);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(-18);
            make.height.mas_equalTo(40);
        }];
        
        _titleLabel.font = PingFangMedium(13);
        _titleLabel.textColor = RGBA(102, 102, 102, 1);
        _titleLabel.text = @"请补充详细问题和意见";
    }
    return _titleLabel;
}

- (UIView *)textContentView{
    if (!_textContentView) {
        _textContentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_textContentView];
        _textContentView.backgroundColor = NavColor;
        [_textContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_titleLabel.mas_bottom).mas_equalTo(0);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(138);
        }];
    }
    return _textContentView;
}

- (UILabel *)place{
    if (!_place) {
        _place = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [_textContentView addSubview:_place];
        [_place mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(17);
            make.left.mas_equalTo(18);
            make.height.mas_equalTo(30);
        }];
        _place.text = @"请输入不少于10个字的描述";
        _place.textColor = RGBA(102, 102, 102, 1);
        _place.font = PingFangRegular(17);
    }
    return _place;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.font = PingFangRegular(17);
        _textView.delegate = self;
        _textView.textColor = RGBA(221, 221, 221, 1);
        _textView.backgroundColor = [UIColor clearColor];
        [_textContentView addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(12);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-12);
        }];
    }
    return _textView;
}

- (UILabel *)numLabel{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_textContentView addSubview:_numLabel];
        _numLabel.textColor = RGBA(102, 102, 102, 1);
        _numLabel.font = PingFangMedium(13);
        _numLabel.text = @"300/300";
        _numLabel.textAlignment = NSTextAlignmentRight;
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-12);
            make.right.mas_equalTo(-15);
        }];
    }
    return _numLabel;
}

- (UIView *)imageContentView{
    if (!_imageContentView) {
        _imageContentView = [[UIView alloc] initWithFrame:CGRectZero];
        
        CGFloat ch = (ScreenWidth - 84) / 4.0 + 67 + 17;
        
        [self.view addSubview:_imageContentView];
        _imageContentView.backgroundColor = NavColor;
        [_imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_textContentView.mas_bottom).mas_equalTo(20);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(ch);
        }];
    }
    return _imageContentView;
}

- (UILabel *)imageTitleLabel{
    if (!_imageTitleLabel) {
        _imageTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_imageContentView addSubview:_imageTitleLabel];
        [_imageTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(18);
            make.height.mas_equalTo(57);
            
        }];
        _imageTitleLabel.text = @"请提供相关问题的截图或相片";
        _imageTitleLabel.textColor = RGBA(221, 221, 221, 1);
        _imageTitleLabel.font = PingFangRegular(17);
    }
    return _imageTitleLabel;
}

- (UILabel *)imageCountLabel{
    if (!_imageCountLabel) {
        _imageCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        [_imageContentView addSubview:_imageCountLabel];
        _imageCountLabel.font = PingFangMedium(12);
        _imageCountLabel.textColor = RGBA(102, 102, 102, 1);
        _imageCountLabel.text = @"0/4";
        _imageCountLabel.textAlignment = NSTextAlignmentRight;
        [_imageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_imageTitleLabel.mas_centerY);
            make.right.mas_equalTo(-17);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(50);
        }];
    }
    return _imageCountLabel;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        flowLayout.itemSize = CGSizeMake(ITEM_SIZE_WIDTH, ITEM_SIZE_HEIGHT);
        
        //设置CollectionView的属性
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(SIDE_MARGIN, 63, ScreenWidth - 2 * SIDE_MARGIN, ITEM_SIZE_WIDTH) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        _collectionView.backgroundColor = NavColor;
        //注册Cell
        [_collectionView registerClass:[XWSFeedImageCell class] forCellWithReuseIdentifier:@"XWSFeedImageCell"];
        [_imageContentView addSubview:_collectionView];
    }
    return _collectionView;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavi];
    [self initView];
    self.view.backgroundColor = BackColor;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.progressHUD dismiss];
}

#pragma mark - 设置导航栏
- (void)setUpNavi{
    self.title = @"意见反馈";
    
    self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
    [self.sendBtn setTitle:@"提交" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendBtn.titleLabel.font = PingFangMedium(15);
    self.sendBtn.enabled = NO;
    [self.sendBtn addTarget:self action:@selector(sendFeedBack) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendBtn];
}

#pragma mark - 设置UI
- (void)initView{
    
    //文字部分
    [self titleLabel];
    [self textContentView];
    [self place];
    [self numLabel];
    [self textView];
    
    //图片部分
//    [self imageContentView];
//    [self imageTitleLabel];
//    [self imageCountLabel];
//    [self collectionView];
   
}

#pragma mark - 发送数据
- (void)sendFeedBack{
    [self.textView resignFirstResponder];
    NSString *t = [self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (t.length < 10) {
        [ElecTipsView showTips:@"请输入不小于10个字的描述字符"];
        return;
    }
    
    [self.progressHUD showHUD:self.view Offset:-NavibarHeight animation:18];
    
    ElecHTTPManager *manager = [ElecHTTPManager manager];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"ask"] = self.textView.text;
    [manager POST:FrigateAPI_SubmitAsk parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.progressHUD dismiss];
        [ElecTipsView showTips:@"提交成功，谢谢您的反馈"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
        [self.progressHUD dismiss];
        [ElecTipsView showTips:@"网络错误，请检查网络连接情况"];
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 0) {
        self.place.hidden = YES;
    }else{
        self.place.hidden = NO;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS)
    {
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
    }
    
    //不让显示负数
    self.numLabel.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,MAX_LIMIT_NUMS - existTextNum),MAX_LIMIT_NUMS];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = [text substringWithRange:rg];
            
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.images.count == 4){
        return self.images.count;
    }
    return self.images.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    XWSFeedImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XWSFeedImageCell" forIndexPath:indexPath];
    
    if (indexPath.row == self.images.count) {
        cell.imageView.image = [UIImage imageNamed:@"left_setting"];
        cell.close.hidden = YES;
    }else{
        cell.imageView.image = self.images[indexPath.row];
        cell.close.hidden = NO;
    }
    
    cell.close.tag = 100 + indexPath.row;
    [cell.close addTarget:self action:@selector(deletePhotos:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.textView resignFirstResponder];
    
    XWSFeedImageCell *cell = (XWSFeedImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.images.count == indexPath.item && cell.close.hidden == YES) {
        [self addFeedImage];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(ITEM_SIZE_WIDTH, ITEM_SIZE_HEIGHT);
}

#pragma mark -  删除图片
- (void)deletePhotos:(UIButton *)sender{
    [self.images removeObjectAtIndex:sender.tag - 100];
    self.imageCountLabel.text = [NSString stringWithFormat:@"%ld/4",(unsigned long)self.images.count];
    [_collectionView reloadData];
}

#pragma mark - 添加图片
//点击头像获取图片
- (void)addFeedImage{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //图片选自控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    
    //相机
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
        
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            ipc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        
        [self presentViewController:ipc animated:YES completion:nil];
        
    }];
    
    //相册
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) return;
        
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:ipc animated:YES completion:nil];
    }];
    
    //取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - uiimagePicke
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //如果是拍照，则拍照后把图片保存在相册
    UIImage *image;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    }else{
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    [self.images addObject:image];
    
    self.imageCountLabel.text = [NSString stringWithFormat:@"%ld/4",(unsigned long)self.images.count];
    [picker dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
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
