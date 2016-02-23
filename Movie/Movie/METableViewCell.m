

#import "METableViewCell.h"
#import "MovieModel.h"
#import "UIImageView+WebCache.h"


@implementation METableViewCell
#pragma mark ----- cell的赋值方法
/// cell赋值方法
-(void)setCellDataWithMovieModel:(MovieModel*)model
{
    [self.movieImageView sd_setImageWithURL:[NSURL URLWithString:model.big] placeholderImage:[UIImage imageNamed:@"英雄2.png"]];
    if (model.isFinishDownLoad) {
        self.moviePlaygressView.progress = 1.0f;
        self.movieProgressLabel.text = @"完成";
    }
    
}

#pragma mark ----- Button 点击事件

- (IBAction)MoviePlayButtonDidClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(METableViewCellPlayButtonDidClicked:)]) {
        // 把自己传给控制器
        [self.delegate METableViewCellPlayButtonDidClicked:self];
        
    }
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
