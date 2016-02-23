
#import "HomeViewController.h"
#import "MovieDataManager.h"
#import "HomeTableViewCell.h"
#import "MovieModel.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#import "videoDownloadManager.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"电影列表";
    // 设置代理
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    
    // 网络请求
    [self getDataFromNetWork];
    
    // xib注册标记
    [self.mainTableView registerNib:[UINib nibWithNibName:@"HomeTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HomeTableViewCell"];
}
#pragma mark ----- 网络请求
-(void)getDataFromNetWork
{
    // 网络请求前转圈
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.mainTableView animated:YES];
    HUD.labelText = @"别着急💃";
    
    // 网络请求
    [[MovieDataManager sharedMovieDataManage] getMovieDataFromNet:^(BOOL isFinished) {
        // 网络请求结束后,隐藏转圈
        [MBProgressHUD hideHUDForView:self.mainTableView animated:YES];
        if (isFinished) {
            [self.mainTableView reloadData];
        }else{
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"网络请求失败💔,是否重新加载" preferredStyle:UIAlertControllerStyleAlert];
            // 确认 重新加载
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"加载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self getDataFromNetWork];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertVC addAction:action2];
            [alertVC addAction:action1];
            // 模态 弹框
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        
    }];
}

#pragma mark ----- UITableViewDataSource 
// row
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [MovieDataManager sharedMovieDataManage].movieDataArray.count;
}

// cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
//    if (nil == cell) {
//        // 加载可视化文件
//        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:self options:nil] firstObject];
//    }
    
    MovieModel *model = [MovieDataManager sharedMovieDataManage].movieDataArray[indexPath.row];
    
    [cell setCellDataWithMovieModel:model];
    self.mainTableView.rowHeight = 120;
    return cell;
}

#pragma mark ----- UITableViewDelegate
// 点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取出当前需要播放或者下载的模型
    MovieModel *model = [MovieDataManager sharedMovieDataManage].movieDataArray[indexPath.row];
    
    // 取消选择
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 提示控制器
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 播放
    UIAlertAction *playAction = [UIAlertAction actionWithTitle:@"播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 实现播放方法 把model类型给方法体传过去
        [self playMovieWithMovieModel:model];
    }];
    
    // 下载
    UIAlertAction *downLoadAction = [UIAlertAction actionWithTitle:@"下载" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 判断是否下载
        if ([[videoDownloadManager sharedDownLoadManager].downLoadingArray containsObject:model]) {
            // 提示已经下载
            [self alertDownLoadingMessage];
            return ;
        }
        
        [[videoDownloadManager sharedDownLoadManager] startDownLoadVideoWithMovieModel:model];
    }];
    
    // 取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:playAction];
    [alertVC addAction:downLoadAction];
    [alertVC addAction:cancelAction];
    
    // 模态推出
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}

#pragma mark ----- 提示 已经下载弹框
-(void)alertDownLoadingMessage
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"视频已经下载" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertVC animated:YES completion:nil];
    
    // 延迟两秒 提醒 自动消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark ----- 播放视频的方法
-(void)playMovieWithMovieModel:(MovieModel *)model
{
    // 播放视频 MPMoviePlayerViewController(iOS9.0以前) (iOS9.0)以后使用 AVPlayer 播放
    // 创建播放控制器
    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:model.flv]];
    
    // 准备播放状态(默认是YES)
    [playerVC.moviePlayer prepareToPlay];
    
    // 设置不自动播放
    playerVC.moviePlayer.shouldAutoplay = NO;
    
    // 模态除控制器
    [self presentViewController:playerVC animated:YES completion:nil];
}


#pragma mark ----- 内存警告
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
