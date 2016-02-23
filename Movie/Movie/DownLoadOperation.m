
#import "DownLoadOperation.h"
#import "MovieModel.h"
#import "SqliteHandle.h"

@interface DownLoadOperation ()<NSURLSessionDataDelegate>
/// 实力变量 和 属性同时写, 实力变量在上
{
    BOOL isDownLoading;
}
/// 记录下载的模型
@property (nonatomic,strong) MovieModel *downLoadModel;

/// 记录队列
@property (nonatomic,strong) NSOperationQueue *queue;

/// session下载的任务
@property (nonatomic,strong) NSURLSessionDownloadTask *task;

@end

@implementation DownLoadOperation

#pragma mark ----- 自定义初始化方法
-(instancetype)initWithMocieModel:(MovieModel *)model withBelongOperationQueue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        self.downLoadModel = model;
        isDownLoading = YES;
        self.queue = queue;
    }
    return self;
}
#pragma mark -----  子线程main(入口)函数
-(void)main
{
    @autoreleasepool {
        // 主要做的工作是:让线程保持活跃状态,持续下载视频
        
        // 通过NSUrlSession 来进行下载(delegate方式)
        NSString *urlString = self.downLoadModel.flv;
        
        // 创建url
        NSURL *url = [NSURL URLWithString:urlString];
        
        // 创建对象
        NSURLRequest *requset = [NSURLRequest requestWithURL:url];
        
        // 创建session的配置信息 (前台后台下载,默认都支持)
        NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // 创建Session
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:nil];
        // 开始进行网络请求
        self.task = [session downloadTaskWithRequest:requset];
        
        // 执行任务
        [self.task resume];
        
        // 下载状态时,开启RunLoop
        while (isDownLoading) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
        }

    }
}

#pragma mark ----- NSURLSessionDataDelegate 协议
// 收到数据方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // 文件以字节为单位
    // 1:totalBytesExpectedToWrite :所需下载文件的总大小
    // 2:totalBytesWritten :已经下载好部分的大小
    // 3:bytesWritten :当前(本次)下载的文件大小
    
    // 回到主线程调用block
    dispatch_async(dispatch_get_main_queue(), ^{
        // 乘1.0f 是把int类型转成float
        float progress = totalBytesWritten * 1.0f/ totalBytesExpectedToWrite;
        self.updateBlock(progress,self.downLoadModel);
    });
}

// 数据接受完毕
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // 获取Cache路径
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        
    // 拼接cache路径
    NSString *movieName = [NSString stringWithFormat:@"%@.mp4",self.downLoadModel.title];
    
    cachesPath = [cachesPath stringByAppendingPathComponent:movieName];
    
    // 文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 移动下载好的视频到指定的位置
    [manager moveItemAtPath:location.path toPath:cachesPath error:nil];
    
    // 更改模型是否下载完毕的表示属性
    self.downLoadModel.isFinishDownLoad = YES;
    
    // 将下载模型插入到数据库
    [[SqliteHandle sharedSqliteHandle] insertToTable:self.downLoadModel.title withMovieModel:self.downLoadModel];
    
    isDownLoading = NO;
}

#pragma mark ----- 继续下载方法
-(void)downLoadResume
{
    // 开始任务
    [self.task resume];
}

#pragma mark ----- 暂停下载
-(void)downLoadSuspend
{
    // 暂停任务
    [self.task suspend];
}



@end
