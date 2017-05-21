//
//  AVI.h
//  Player
//
//  Created by xiaogou134 on 2017/5/20.
//  Copyright © 2017年 xiaogou134. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVI : NSObject
//

//描述
@property (strong, nonatomic) NSString *detail;
//

//作者头像
@property (strong, nonatomic) NSString *Arimage;
//作者名
@property (strong, nonatomic) NSString *name;

//标题
@property (nonatomic, copy  ) NSString *title;

//视频地址
@property (nonatomic, copy  ) NSString *playUrl;
//封面图
@property (nonatomic, copy  ) NSString *coverForFeed;


@property(nonatomic,assign)BOOL isPlaying;

@end
