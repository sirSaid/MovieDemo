
#import "HomeTableViewCell.h"
#import "MovieModel.h"
#import "UIImageView+WebCache.h"

@implementation HomeTableViewCell

#pragma mark --- cell的赋值方法
-(void)setCellDataWithMovieModel:(MovieModel *)model
{
    [self.movieImageView sd_setImageWithURL:[NSURL URLWithString:model.big] placeholderImage:[UIImage imageNamed:@"英雄2.png"]];
    self.movieNameLabel.text = model.title;
    self.speakerNameLabel.text = model.nickname;
    self.movieTotalTimeLabel.text = model.totalTime;
}
// 相当于可视化的init
- (void)awakeFromNib {
    self.movieImageView.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
