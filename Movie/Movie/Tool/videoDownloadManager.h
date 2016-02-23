
#import <Foundation/Foundation.h>
@class MovieModel;
@protocol videoDownloadManagerDelegate <NSObject>

-(void)videoDownloadManagerPassValue:(float)progress
               withCurrentMovieModel:(MovieModel *)currentModel;

@end



@interface videoDownloadManager : NSObject


// 暴露接口,方便外部进行设置代理
@property (nonatomic,weak)id<videoDownloadManagerDelegate>delegate;

// 记录并存储下载的电影模型
@property (nonatomic,strong) NSMutableArray *downLoadingArray;

+(instancetype)sharedDownLoadManager;

#pragma mark  ----- 开始下载视频的方法
-(void)startDownLoadVideoWithMovieModel:(MovieModel *)model;


#pragma mark ----- 继续下载方法
-(void)continueDownLoadVideoWithModel:(MovieModel *)model;

#pragma mark ----- 暂停下载
-(void)suspendDownLoadVideoWithModel:(MovieModel *)model;


@end
