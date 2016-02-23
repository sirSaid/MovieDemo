
#import <Foundation/Foundation.h>
@class MovieModel;

@interface SqliteHandle : NSObject

+(instancetype)sharedSqliteHandle;

#pragma mark -----  ***** 数据库 *****

#pragma mark ----- 创建表格
-(void)createTable;

#pragma mark ----- 插入数据
-(void)insertToTable:(NSString *)key
      withMovieModel:(MovieModel *)model;

#pragma mark ----- 查找所有电影模型
-(NSArray *)selectALLmodelFromTable;


@end
