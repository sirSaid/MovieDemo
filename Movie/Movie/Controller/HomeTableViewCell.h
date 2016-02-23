
#import <UIKit/UIKit.h>
@class MovieModel;

@interface HomeTableViewCell : UITableViewCell

/// 电影图片
@property (strong, nonatomic) IBOutlet UIImageView *movieImageView;

/// 电影名称
@property (strong, nonatomic) IBOutlet UILabel *movieNameLabel;

/// 解说人
@property (strong, nonatomic) IBOutlet UILabel *speakerNameLabel;

/// 电影总时长
@property (strong, nonatomic) IBOutlet UILabel *movieTotalTimeLabel;

#pragma mark --- cell的赋值方法
-(void)setCellDataWithMovieModel:(MovieModel *)model;


@end
