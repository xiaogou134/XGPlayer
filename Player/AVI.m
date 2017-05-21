//
//  AVI.m
//  Player
//
//  Created by xiaogou134 on 2017/5/20.
//  Copyright © 2017年 xiaogou134. All rights reserved.
//

#import "AVI.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface AVI()

@end
@implementation AVI

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"name"]) {
        self.name = value;
    } else if ([key isEqualToString:@"text"]) {
        self.detail = value;
    } else if ([key isEqualToString:@"image2"]) {
        self.coverForFeed = value;
    }
    else if ([key isEqualToString:@"video_ur"]) {
        self.playUrl = value;
    } else if ([key isEqualToString:@"isPlaying"])
        self.isPlaying = NO;
}
@end
