
#import "SqliteHandle.h"
#import <sqlite3.h>
#import "MovieModel.h"

static SqliteHandle *sqliteHandle = nil;
static sqlite3 *db = nil;
@implementation SqliteHandle

+(instancetype)sharedSqliteHandle
{
    return [[self alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == sqliteHandle) {
            sqliteHandle = [super allocWithZone:zone];
        }
    });
    return sqliteHandle;
}

#pragma mark ----- 打开数据库
-(void)openDB
{
    // 判断
    if (db) {
        return;
    }
    // 获取路径
    NSString *patn = [self getPathOfDataBase];
    
    // 打开数据库 如果路径所指示的数据库已经存在则直接打开,否则创建data.sqlite然后打开
    sqlite3_open([patn UTF8String], &db);
}

#pragma mark ----- 获取路径
-(NSString *)getPathOfDataBase
{
    // 获取保存位置
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    // 拼接创建文件
    path = [path stringByAppendingPathComponent:@"data.sqlite"];
    
    return path;
}


#pragma mark ----- 创建表格
-(void)createTable
{
    // 打开数据库
    [self openDB];
    
    // 创建表格
    NSString *creatSql = @"create table video_table (key TEXT,model BLOB)";
    
    // 实行sql
    sqlite3_exec(db, [creatSql UTF8String], NULL, NULL, NULL);
    
}

#pragma mark ----- 插入数据
-(void)insertToTable:(NSString *)key
      withMovieModel:(MovieModel *)model
{
    // 如果数据库需要插入BLOB 类型数据,必须用绑定的方式,如果不需要则可以使用sqlite3_exec这种简单的方式
    // 归档(可变的二进制对象)
    NSMutableData *data = [NSMutableData data];
    // 创建反归档对象
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    // 编码
    [archiver encodeObject:model forKey:key];
    // 结束归档
    [archiver finishEncoding];
    
    // 创建sql语句
    NSString *sql = @"insert into video_table (key,model) values (?,?)";
    // 创建临时结果集
    sqlite3_stmt *stmt = nil;
    // 数据库准备状态
    int result = sqlite3_prepare(db, [sql UTF8String], -1, &stmt, nil);
    // 判断
    if (result == SQLITE_OK) {
        // 绑定
        sqlite3_bind_text(stmt, 1, [key UTF8String], -1, nil);
        sqlite3_bind_blob(stmt, 2, [data bytes], (int)[data length], nil);
        // 把结果集数据插入到数据库
        sqlite3_step(stmt);
    }
    // 结束结果集的写入操作
    sqlite3_finalize(stmt);
}

#pragma mark ----- 查找所有电影模型
-(NSArray *)selectALLmodelFromTable
{
    NSString *sql = @"select *from video_table";
    
    // 准备临时结果集
    sqlite3_stmt *stmt =nil;
    
    // 准备
    int result = sqlite3_prepare(db, [sql UTF8String], -1, &stmt, NULL);
    
    // 创建数组接受并返回
    NSMutableArray *array = [NSMutableArray array];
    
    if (result == SQLITE_OK) {
        // 遍历结果集
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const char *keyChar = (const char*) sqlite3_column_text(stmt, 0);
            NSString *key = [[NSString alloc] initWithUTF8String:keyChar];
            
            // 取出二级制model字段
            // 二进制流
            const void *modelBytes = sqlite3_column_blob(stmt, 1);
            // 二进制数据长度
            int length = sqlite3_column_bytes(stmt, 1);
            // 初始化modelData
            NSData *modelData = [NSData dataWithBytes:modelBytes length:length];
            
            // 反归档
            NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:modelData];
            // 取出赋值模型
            MovieModel *model = [unArchiver decodeObjectForKey:key];
            
            // 结束反归档
            [unArchiver finishDecoding];
            
            // 将反归档对象存入数组
            [array addObject:model];
        }
    }
    // 结束结果集写入
    sqlite3_finalize(stmt);
    
    return  array;
}



@end
