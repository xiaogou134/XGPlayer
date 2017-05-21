//
//  AATableViewCell.m
//  Player
//
//  Created by xiaogou134 on 2017/5/20.
//  Copyright © 2017年 xiaogou134. All rights reserved.
//

#import "AATableViewCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@implementation AATableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self initCell];
    }

    return self;
}
- (void)initCell {
    //在cell中添加作者头像
    _authorImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    //图像居中，多余截取
    _authorImage.contentMode= UIViewContentModeCenter;
    _authorImage.clipsToBounds  = YES;
    [self.contentView addSubview:_authorImage];
    _authorImage.layer.cornerRadius = 8.0;
    //添加作者的名字,在头像后面20
    _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,10,200,25)];
    _authorLabel.textAlignment = NSTextAlignmentLeft;
    _authorLabel.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:_authorLabel];
    
    //在cell中添加视频描述,在头像下面10
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 375, 25)];
    _detailLabel.textAlignment = NSTextAlignmentLeft;
    _detailLabel.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:_detailLabel];
    //在cell中添加一imageview
    _MainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 65, [UIScreen mainScreen].bounds.size.width - 10, 180)];
    [self.contentView addSubview:_MainImageView];
    _MainImageView.userInteractionEnabled = YES;
    
    //播放键的设置
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"video_list_cell_big_icon"] forState:UIControlStateNormal];
    //[self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.MainImageView addSubview:self.playBtn];
    self.playBtn.frame = CGRectMake((self.contentView.bounds.size.width)/2,(self.contentView.bounds.size.height)/2 , 60, 60);

    // 初始化播放器item
}
////加载一个封面图吧
//- (void)setModel:(AVI *)model{
//    [self.MainImageView sd_setImageWithURL:[NSURL URLWithString:model.coverForFeed] placeholderImage:[UIImage imageNamed:@"loading_bgView"]];
//}


@end
