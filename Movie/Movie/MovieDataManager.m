
#import "MovieDataManager.h"
#import "MovieModel.h"


static MovieDataManager *movieDataManager = nil;
@implementation MovieDataManager

+(instancetype)sharedMovieDataManage
{
    return [[self alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == movieDataManager) {
            movieDataManager = [super allocWithZone:zone];
        }
    });
    return movieDataManager;
}


#pragma mark ----- 请求电影数据
-(void)getMovieDataFromNet:(BLOCK)finishBlock
{
    // 网址字符串
    NSString *string = @"http://www.aipai.com/api/aipaiApp_action-searchVideo_gameid-25296_keyword-%E8%92%B8%E6%B1%BD%E6%9C%BA%E5%99%A8%E4%BA%BA_op-AND_appver-a2.4.6_page-1.html";
    //  包装为url
    NSURL *url = [NSURL URLWithString:string];
    
    // 创建网络请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 利用NSURLSession 发送网络请求
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 发送
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 子线程要添加 自动释放池
        @autoreleasepool {
            // 如果data为空或者nil 不为空 网络解析失败
            if (nil == data || nil != error) {
                // 回到主线程
//                dispatch_async(dispatch_get_main_queue(), ^{
                    finishBlock(NO);
                    return ;
//                });
            }
            // 解析数据
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *videlArray = [resultDic valueForKey:@"video"];
            
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
            // 遍历数组
            for (NSDictionary *dict in videlArray) {
                MovieModel *model = [[MovieModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [array addObject:model];
            }
            self.movieDataArray = [NSArray arrayWithArray:array];
            
            // 回到主线程
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                // 调用 Block
                finishBlock(weakSelf.movieDataArray.count > 0);
            });
        }
        
    }];
    
    // 执行任务
    [task resume];
    
    // 暂停任务
//    [task response];
}



@end
