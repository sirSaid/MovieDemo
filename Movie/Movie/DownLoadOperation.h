
#import <Foundation/Foundation.h>
@class MovieModel;

typedef void(^UPDATEBLOCK)(float Progress,MovieModel *currentModel);

@interface DownLoadOperation : NSOperation

#pragma mark ----- 自定义初始化方法
-(instancetype)initWithMocieModel:(MovieModel *)model
         withBelongOperationQueue:(NSOperationQueue *)queue;

#pragma mark ----- 用来回调下载的进度
@property (nonatomic,copy) UPDATEBLOCK updateBlock;

#pragma mark ----- 继续下载方法
-(void)downLoadResume;

#pragma mark ----- 暂停下载
-(void)downLoadSuspend;


@end
