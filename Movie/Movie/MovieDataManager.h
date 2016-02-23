
#import <Foundation/Foundation.h>

typedef void(^BLOCK)(BOOL isFinished);

@interface MovieDataManager : NSObject

+(instancetype)sharedMovieDataManage;

#pragma mark ----- 请求电影数据
-(void)getMovieDataFromNet:(BLOCK)finishBlock;

/// 存放电影数据模型的数组
@property (nonatomic,strong) NSArray *movieDataArray;


@end
