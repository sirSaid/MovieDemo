
#import <Foundation/Foundation.h>

@interface MovieModel : NSObject<NSCoding>

/// 视频标题
@property (nonatomic,copy) NSString *title;

/// 视频地址
@property (nonatomic,copy) NSString *flv;

/// 视频总时长
@property (nonatomic,copy) NSString *totalTime;

/// 视频图片
@property (nonatomic,copy) NSString *big;

/// 解说人
@property (nonatomic,copy) NSString *nickname;


// 判断视频是否下载完毕的标志
@property (nonatomic,assign) BOOL isFinishDownLoad;


@end
