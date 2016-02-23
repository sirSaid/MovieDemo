
#import "videoDownloadManager.h"
#import "MovieModel.h"
#import "DownLoadOperation.h"

@interface videoDownloadManager ()

// 用来保存下载任务的 Operation  方便取出暂停/继续使取出当前下载的operation
@property (nonatomic,strong) NSMutableDictionary *operationDict;

@end

static videoDownloadManager *videoManager = nil;
static NSOperationQueue *downLoadQueue = nil;
@implementation videoDownloadManager

+(instancetype)sharedDownLoadManager
{
    return [[self alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (videoManager == nil) {
            videoManager = [super allocWithZone:zone];
            // 初始化时调用队列
            [videoManager getDownLoadQueue];
            videoManager.downLoadingArray = [NSMutableArray array];
            videoManager.operationDict = [NSMutableDictionary dictionary];
        }
    });
    return videoManager;
}

#pragma mark  ----- 开始下载视频的方法
-(void)startDownLoadVideoWithMovieModel:(MovieModel *)model
{
    // 子线程中进行下载任务 (NSOperation 和 NSOperationQueue)
    
    // 初始化 任务块
    DownLoadOperation *ope = [[DownLoadOperation alloc] initWithMocieModel:model withBelongOperationQueue:downLoadQueue];
    
    // 把下载的operation存储到字典
    [self.operationDict setObject:ope forKey:model.flv];
    
    // 实现 DownLoadOperation中 声明的 更新进度的block
    ope.updateBlock = ^(float progress,MovieModel*currentModel){
//        NSLog(@"收到下载数据:%f",progress);
        // 调用代理方法
         // 判断 代理遵循协议,并且实现协议方法
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoDownloadManagerPassValue:withCurrentMovieModel:)]) {
            // 调用方法
            [self.delegate videoDownloadManagerPassValue:progress withCurrentMovieModel:currentModel];
        }
    };
    // 把任务块添加到队列
    [downLoadQueue addOperation:ope];
    
    // 将下载模型存储到数组
    [self.downLoadingArray addObject:model];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newVideoStartDownload" object:nil];
}

#pragma mark ----- 继续下载方法
-(void)continueDownLoadVideoWithModel:(MovieModel *)model
{
    // 获取 当前下载的 operation
    DownLoadOperation *ope = self.operationDict[model.flv];
    
    // ope 执行继续下载的方法 先判断该operation是否下载完成
    if (!ope.finished) {
        [ope downLoadResume];
    }
    
}

#pragma mark ----- 暂停下载
-(void)suspendDownLoadVideoWithModel:(MovieModel *)model
{
    
    // 获取 当前下载的 operation
    DownLoadOperation *ope = self.operationDict[model.flv];
    
    // ope 执行暂停下载的方法 先判断该operation是否下载完成
    if (!ope.finished) {
        [ope downLoadSuspend];
    }
}

#pragma mark ----- 每次点击下载 都只创建一个队列 (懒加载思想)
-(void)getDownLoadQueue
{
    if (downLoadQueue == nil) {
        // 初始化队列
        downLoadQueue = [[NSOperationQueue alloc] init];
        // 队列最大并发数(最多同时可以下载3个视频)
        downLoadQueue.maxConcurrentOperationCount = 3;
    }
}








@end
