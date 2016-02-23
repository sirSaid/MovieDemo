

#import "MovieModel.h"

@implementation MovieModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

// 归档时会执行的方法
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.flv forKey:@"flv"];
    [aCoder encodeObject:self.totalTime forKey:@"totalTime"];
    [aCoder encodeObject:self.big forKey:@"big"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeBool:self.isFinishDownLoad forKey:@"isFinishDownLoad"];
}

// 反归档的时候会执行的方法
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.flv = [aDecoder decodeObjectForKey:@"flv"];
        self.totalTime = [aDecoder decodeObjectForKey:@"totalTime"];
        self.big = [aDecoder decodeObjectForKey:@"big"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.isFinishDownLoad = [aDecoder decodeBoolForKey:@"isFinishDownLoad"];
    }
    return self;
}

@end
