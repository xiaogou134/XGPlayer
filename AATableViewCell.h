//
//  AATableViewCell.h
//  Player
//
//  Created by xiaogou134 on 2017/5/20.
//  Copyright © 2017年 xiaogou134. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AVI.h"

@interface AATableViewCell : UITableViewCell
//播放键
@property(nonatomic,strong)UIButton *playBtn;
//描述框
@property(strong, nonatomic) UILabel *detailLabel;
//作者名称框
@property(strong, nonatomic) UILabel *authorLabel;
//作者头像框
@property(strong, nonatomic) UIImageView *authorImage;
//占位框
@property (strong, nonatomic) UIImageView *MainImageView;
//数据
@property (strong, nonatomic) AVI * model;
@end
