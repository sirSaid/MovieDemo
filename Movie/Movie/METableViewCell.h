
#import <UIKit/UIKit.h>
@class MovieModel;
@class METableViewCell;

@protocol METableViewCellDelegate <NSObject>
// 定义协议传出点击的是那个cell上的Button
-(void)METableViewCellPlayButtonDidClicked:(METableViewCell *)cell;

@end

@interface METableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *movieImageView;

@property (strong, nonatomic) IBOutlet UIButton *moviePlayButton;

@property (strong, nonatomic) IBOutlet UIProgressView *moviePlaygressView;

@property (strong, nonatomic) IBOutlet UILabel *movieProgressLabel;

#pragma mark ----- cell的赋值方法
/// cell赋值方法
-(void)setCellDataWithMovieModel:(MovieModel*)model;

@property (nonatomic,weak) id <METableViewCellDelegate>delegate;


@end
