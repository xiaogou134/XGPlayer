//
//  ViewController.m
//  Player
//
//  Created by xiaogou134 on 2017/5/20.
//  Copyright © 2017年 xiaogou134. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "AATableViewCell.h"
#import "AVI.h"
#import "ZWPlayer.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,strong) NSMutableArray *dataSource;
@property(nonatomic,strong)UITableView *tableView;

//播放器
@property(nonatomic,strong)ZWPlayerView *playerView;
//离开页面时候是否在播放
@property (nonatomic, assign) BOOL isPlaying;
//是否在cell中播放
@property(nonatomic,assign)BOOL isInCell;

//记录当前在哪一个cell上播放对应的indexPath
@property(nonatomic,strong) NSIndexPath *currentIndexPath;
//播放器在哪个cell上播放
@property(nonatomic,retain)AATableViewCell *currentCell;
@end

@implementation ViewController
#pragma mark - Life Cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _isInCell = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self getJSONData];
    [self.view addSubview:self.tableView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (_playerView) {
        [_playerView setNeedsLayout];
    }
    //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

}
#pragma mark - dataSource Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier        = @"playerCell";
    AATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[AATableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    AVI *model = self.dataSource[indexPath.row];
    cell.model = model;
    [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    cell.detailLabel.text = [model.detail substringFromIndex:11];
    cell.authorLabel.text = model.name;
    cell.authorImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.Arimage]]];
//
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 250;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark - cell上播放按钮点击事件
-(void)startPlayVideo:(UIButton *)sender{
    _currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    //根据cell上的播放按钮获取到当前cell
    if ([UIDevice currentDevice].systemVersion.floatValue>=8||[UIDevice currentDevice].systemVersion.floatValue<7) {
        self.currentCell = (AATableViewCell *)sender.superview.superview.superview;
    }else{
        self.currentCell = (AATableViewCell *)sender.superview.superview.superview.subviews;
    }
    
    //设置播放器的显示相关
    _playerView = [ZWPlayerView sharedPlayerView];
    [self.currentCell.MainImageView addSubview:self.playerView];
    self.playerView.frame = self.currentCell.MainImageView.bounds;
    _playerView.transform = CGAffineTransformIdentity;
    [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentCell.MainImageView).with.offset(0);
        make.left.equalTo(self.currentCell.MainImageView).with.offset(0);
        make.right.equalTo(self.currentCell.MainImageView).with.offset(0);
        make.height.equalTo(@(self.currentCell.MainImageView.frame.size.height));
    }];
    
    [self.currentCell.MainImageView bringSubviewToFront:self.playerView];
    [self.currentCell.playBtn.superview sendSubviewToBack:self.currentCell.playBtn];
    [self.tableView reloadData];
    
    //每次播放另外一个视频之前要调用该方法，最好放在播放参数和开始播放之前
    [self.playerView resetToPlayNewURL];
    
    //*****************设置播放器相关*****************
    //必须要设置的参数
    self.playerView.isCellVideo = YES;
    //设置播放器的videoUrl
    AVI *model = self.dataSource[_currentIndexPath.row];
    NSURL *videoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",model.playUrl]];
    self.playerView.videoURL = videoUrl;
    self.playerView.playerLayerGravity = ZWPlayerLayerGravityResize;
    //设置图
    //设置自动播放
    [self.playerView autoPlayTheVideo];
    
    //设置返回按钮图片
    if (_isInCell) {
        [_playerView.controlView.backBtn setImage:[UIImage imageNamed:ZWPlayerSrcName(@"ZFPlayer_close")] forState:UIControlStateNormal];
    }
    //返回按钮回调事件
    __weak typeof(self) weakSelf = self;
    _playerView.goBackBlock = ^(){
        if (!weakSelf.isInCell) {
            weakSelf.isInCell = YES;
            weakSelf.playerView.controlView.fullScreenBtn.selected = NO;
        }
        [weakSelf releasePlayerView];
        //调用这句话才能更新状态栏（控制显示、隐藏以及样式）
        [weakSelf setNeedsStatusBarAppearanceUpdate];
        //为下一次播放做准备
        _isInCell = YES;
    };
    _playerView.playCompletedBlock = ^(){
        if (!weakSelf.isInCell) {
            weakSelf.isInCell = YES;
            weakSelf.playerView.controlView.fullScreenBtn.selected = NO;
        }
        [weakSelf releasePlayerView];
        //调用这句话才能更新状态栏（控制显示、隐藏以及样式）
        [weakSelf setNeedsStatusBarAppearanceUpdate];
        //为下一次播放做准备
        _isInCell = YES;
    };
    _playerView.fullScreenBtnBlock = ^(UIButton *fullScreenBtn){
        if (fullScreenBtn.selected) {//转为非全屏状态
            _isInCell = YES;
            AATableViewCell *currentCell = (AATableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.currentIndexPath.row inSection:0]];
            [currentCell.MainImageView addSubview:weakSelf.playerView];
            [weakSelf toOrientation:UIInterfaceOrientationPortrait];
            fullScreenBtn.selected = NO;
        }else{//转为全屏状态
            _isInCell = NO;
            [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.playerView];
            [weakSelf toOrientation:UIInterfaceOrientationLandscapeRight];
            [weakSelf.playerView.controlView.backBtn setImage:[UIImage imageNamed:ZWPlayerSrcName(@"ZFPlayer_close")] forState:UIControlStateNormal];
            fullScreenBtn.selected = YES;
        }
        //调用这句话才能更新状态栏（控制显示、隐藏以及样式）
        [weakSelf setNeedsStatusBarAppearanceUpdate];
    };
    ZWPlayerControlView *controlView = self.playerView.controlView;
    [controlView.activity startAnimating];
    
    [self.tableView reloadData];
    
}

- (void)releasePlayerView{
    [self.playerView pause];
    [self.playerView removeFromSuperview];
    [self.playerView.playerLayer removeFromSuperlayer];

}
#pragma mark -控制状态栏显示和隐藏
- (BOOL)prefersStatusBarHidden{
    if (_isInCell) {
        return NO;
    }else{
        return YES;
    }
    return NO;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}



#pragma mark- 屏幕旋转相关
//点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
-(void)toOrientation:(UIInterfaceOrientation)orientation{
    //根据要旋转的方向,使用Masonry重新修改限制
    if (orientation ==UIInterfaceOrientationPortrait) {//
        AATableViewCell *currentCell = (AATableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndexPath.row inSection:0]];
        [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(currentCell.MainImageView).with.offset(0);
            make.left.equalTo(currentCell.MainImageView).with.offset(0);
            make.right.equalTo(currentCell.MainImageView).with.offset(0);
            make.height.equalTo(@(currentCell.MainImageView.frame.size.height));
        }];
    }else{
        [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@([UIScreen mainScreen].bounds.size.height));
            make.height.equalTo(@([UIScreen mainScreen].bounds.size.width));
            make.center.equalTo(_playerView.superview);
        }];
    }
    //获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    //给你的播放视频的view视图设置旋转
    if (orientation ==UIInterfaceOrientationPortrait) {
        _playerView.transform = CGAffineTransformIdentity;
    }else{
        _playerView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    [UIView setAnimationDuration:1.0];
    //开始旋转
    [UIView commitAnimations];
}

#pragma mark - scrollView代理方法
//tableViewCell离开界面，视频消失
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.tableView) {
        if (_playerView.superview) {
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:_currentIndexPath];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            
            if (rectInSuperview.origin.y<-self.currentCell.MainImageView.frame.size.height||rectInSuperview.origin.y>[UIScreen mainScreen].bounds.size.height-64-49) {//往上拖动
                [self releasePlayerView];
                [self.currentCell.playBtn.superview bringSubviewToFront:self.currentCell.playBtn];
            }
        }
    }
    
}


#pragma mark - 懒加载方法
- (NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 49) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


#pragma mark -初始化数据源

- (void)getJSONData {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
    //子线程异步执行下载任务，防止主线程卡顿
    
    NSURL *url = [NSURL URLWithString:@"http://route.showapi.com/255-1?showapi_appid=38553&showapi_sign=76E857CEEDE1A67FF3977521928A1A76"];
    //由这个url生成一个request（请求）
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //由NSURLConnection发送请求，调用的是以下的方法，返回的类型是NSData（十六进制流）
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    //如果返回数据不为空，则可进行下一步操作
    if (data != nil) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        //异步返回主线程，根据获取的数据，更新UI
        dispatch_async(mainQueue, ^{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            // JSON数据存入model
            for (int i = 0; i < [dic[@"showapi_res_body"][@"pagebean"][@"contentlist"] count]; i++) {
                
            if([dic[@"showapi_res_body"][@"pagebean"][@"contentlist"][i][@"type"]  isEqual: @"41"])
                {
                    AVI *model = [[AVI alloc] init];

                     //作者头像
                    model.Arimage = dic[@"showapi_res_body"][@"pagebean"][@"contentlist"][i][@"profile_image"];
                    //放名字
                    model.name = dic[@"showapi_res_body"][@"pagebean"][@"contentlist"][i][@"name"];
                    //放图
                    model.coverForFeed = dic[@"showapi_res_body"][@"pagebean"][@"contentlist"][i][@"image2"];
                    //放描述
                    model.detail = dic[@"showapi_res_body"][@"pagebean"][@"contentlist"][i][@"text"];
                     [self.dataSource addObject:model];
                    //放片
                    model.playUrl = dic[@"showapi_res_body"][@"pagebean"][@"contentlist"][i][@"video_uri"];
                   }
                [_tableView reloadData];
            }
                        });
    }
    
    else {
        NSLog(@"error when download:%@",error);
    }
});
}



@end
