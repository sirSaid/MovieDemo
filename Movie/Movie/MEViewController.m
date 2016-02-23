

#import "MEViewController.h"
#import "METableViewCell.h"
#import "videoDownloadManager.h"
#import "MovieModel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MEViewController ()<UITableViewDataSource,UITableViewDelegate,videoDownloadManagerDelegate,METableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *METableView;


@end

@implementation MEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的";
    
    // 设置代理
    self.METableView.dataSource = self;
    self.METableView.delegate = self;
    
    // 注册标记
    [self.METableView registerNib:[UINib nibWithNibName:@"METableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"METableViewCell"];
    
    // 注册 下载新电影的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newVideoDidStartNeedUpdate:) name:@"newVideoStartDownload" object:nil];
    
    // 设置videoDownloadManagerDelegate代理
    [videoDownloadManager sharedDownLoadManager].delegate = self;
    
    
}
#pragma mark ----- 通知方法的实现
-(void)newVideoDidStartNeedUpdate:(NSNotification *)sender
{
    NSLog(@"收到电影下载的通知");
    [self.METableView reloadData];
}
#pragma mark ----- videoDownloadManagerDelegate代理方法实现 (进度条赋值)
-(void)videoDownloadManagerPassValue:(float)progress withCurrentMovieModel:(MovieModel *)currentModel
{
    // 根据传过来的模型获取所在数组的位置
    NSInteger index = [[videoDownloadManager sharedDownLoadManager].downLoadingArray indexOfObject:currentModel];
    
    // 根据模型下标获取cell的indexPath
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    // 根据indexPath拿出cell
    METableViewCell *cell = [self.METableView cellForRowAtIndexPath:indexPath];
    
    // 赋值
    cell.movieProgressLabel.text = [NSString stringWithFormat:@"%0.2f%%",progress*100];
    cell.moviePlaygressView.progress = progress;
}

#pragma mark ----- UITableViewDataSource
// row
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videoDownloadManager sharedDownLoadManager].downLoadingArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    METableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"METableViewCell"];
    
    // 设置METableViewCellDelegate代理
    cell.delegate = self;
    

    self.METableView.rowHeight = 120;
    MovieModel *model = [videoDownloadManager sharedDownLoadManager].downLoadingArray[indexPath.row];
    [cell setCellDataWithMovieModel:model];
    
    return cell;
}

#pragma mark ----- METableViewCellDelegate  点击 按钮方法方法实现
-(void)METableViewCellPlayButtonDidClicked:(METableViewCell *)cell
{
    // 根据cell 获取模型 首先看cell 是第几行
    NSIndexPath *indexPath = [self.METableView indexPathForCell:cell];
    
    // 取出点击模型
    MovieModel *model = [videoDownloadManager sharedDownLoadManager].downLoadingArray[indexPath.row];
    
    if (cell.moviePlayButton.selected == NO) {
        // 执行暂停下载方法
        [[videoDownloadManager sharedDownLoadManager] suspendDownLoadVideoWithModel:model];
        // 更改前景图片
        [cell.moviePlayButton setImage:[UIImage imageNamed:@"播放.png"] forState:UIControlStateNormal];
    }else{
        // 执行继续下载方法
        [[videoDownloadManager sharedDownLoadManager] continueDownLoadVideoWithModel:model];
        // 更改前景图片
        [cell.moviePlayButton setImage:[UIImage imageNamed:@"暂停.png"] forState:UIControlStateNormal];
    }
    // 更改选中状态
    cell.moviePlayButton.selected = !cell.moviePlayButton.selected;
}

#pragma mark ----- tableView 的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取出模型
    MovieModel *model = [videoDownloadManager sharedDownLoadManager].downLoadingArray[indexPath.row];
    // 判断标示
    if (model.isFinishDownLoad) {
        // 找到播放的路径
        NSString *urlString = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *movieName = [NSString stringWithFormat:@"%@.mp4",model.title];
        urlString = [urlString stringByAppendingPathComponent:movieName];
        // 获取本地URL
        NSURL *url = [NSURL fileURLWithPath:urlString];
        // 播放视频 MPMoviePlayerViewController(iOS9.0以前) (iOS9.0)以后使用 AVPlayer 播放
        // 创建播放控制器
        MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        
        // 准备播放状态(默认是YES)
        [playerVC.moviePlayer prepareToPlay];
        
        // 设置不自动播放
        playerVC.moviePlayer.shouldAutoplay = NO;
        
        // 模态除控制器
        [self presentViewController:playerVC animated:YES completion:nil];
    }
}



#pragma mark ----- 移除通知
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
