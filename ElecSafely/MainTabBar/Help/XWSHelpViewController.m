//
//  XWSHelpViewController.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/26.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSHelpViewController.h"
#import "XWSDetailHelpViewController.h"

#define TableViewRowHeight 54.0f
#define TableViewHeaderHeight 41.0f

@interface XWSHelpViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
/*返回的热点问题数组*/
@property (nonatomic, strong) NSMutableArray *quetions;
@end

@implementation XWSHelpViewController

- (NSMutableArray *)quetions{
    if (!_quetions) {
        _quetions = [NSMutableArray array];
    }
    return _quetions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"帮助";
    [self initView];
    [self loadHelpData];
}
#pragma mark - 加载网络数据
- (void)loadHelpData{
    ElecHTTPManager *manager = [ElecHTTPManager manager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"ask"] = @"";
    [manager POST:FrigateAPI_Help_AnswerForAsk parameters:@"" progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"responseObject:%@",responseObject);
        [XWSTipsView hideTipViewWithSuperView:self.view];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [XWSTipsView showTipViewWithType:XWSShowViewTypeError inSuperView:self.view];
        [ElecTipsView showTips:@"网络错误，请检查网络连接情况"];
    }];
}

#pragma mark - 设置UI
- (void)initView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = TableViewRowHeight;
        _tableView.backgroundColor = BackColor;
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.left.bottom.mas_equalTo(0);
            
        }];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *ID = @"helpCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = NavColor;
        
        //label
        UILabel *titleLabel = [[UILabel alloc]init];
        [cell addSubview:titleLabel];
        titleLabel.tag = 100 + indexPath.row;
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(18);
            make.right.mas_equalTo(-38);
            make.height.mas_equalTo(30);
            make.top.mas_equalTo((TableViewRowHeight - 30) * 0.5);
        }];
        
        //线条
        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
        line.backgroundColor = DarkBack;
        [cell addSubview:line];
        /*在这里使用masonry控制，会爆出约束冲突，但是不影响使用，所以就不管了*/
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(17);
            make.bottom.mas_equalTo(-0.3);
            make.height.mas_equalTo(0.3);
        }];
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100 + indexPath.row];
    
    titleLabel.text = [NSString stringWithFormat:@"热点问题热点问题热点问题热点问题热点问题热点问题热点问题热点问题%ld",indexPath.row];
    titleLabel.font = PingFangMedium(17);
    titleLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return TableViewHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    headView.backgroundColor = BackColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [headView addSubview:titleLabel];
    titleLabel.frame = CGRectMake(18, 11, headView.frame.size.width - 18 * 2, headView.frame.size.height - 11 * 2);
    titleLabel.text = @"热点问题";
    titleLabel.font = PingFangMedium(13);
    titleLabel.textColor = RGBA(153, 153, 153, 1);
    
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100 + indexPath.row];
    XWSDetailHelpViewController *vc = [[XWSDetailHelpViewController alloc] init];
    vc.title = titleLabel.text;
    vc.url = @"http://www.baidu.com";
    [self.navigationController pushViewController:vc animated:YES];
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
