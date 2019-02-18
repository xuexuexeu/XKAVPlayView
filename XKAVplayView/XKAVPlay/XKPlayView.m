//
//  XKPlayView.m
//  XKAVplayView
//
//  Created by apple on 2019/2/18.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "XKPlayView.h"
#import "UIView+EXTION.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
@interface XKPlayView()<AVPlayerViewControllerDelegate>

//相关视频播放控件
@property(strong,nonatomic)AVPlayer *player;
@property(strong,nonatomic)AVPlayerItem *playerItem;
@property(strong,nonatomic)AVPlayerLayer *playerLayer;

//视频播放界面 按钮
@property(strong,nonatomic)UIView *topView;
@property(strong,nonatomic)UIView *bottomView;
@property(weak,nonatomic)UIButton *topBackBtn;
@property(weak,nonatomic)UILabel *topTitleLab;
@property(weak,nonatomic)UIButton *bottomPlayBtn;
@property(weak,nonatomic)UILabel *bottomTimeLab;
@property(weak,nonatomic)UISlider *slider;
@property(weak,nonatomic)UIProgressView *cacheProgress;
@property(weak,nonatomic)UIButton *fullBtn;
@property(weak,nonatomic)UIView *middleView;
@property(weak,nonatomic)UIButton *middlePlayBtn;

//控制当前音量
@property(assign,nonatomic)CGFloat volumeNum;
@property(assign,nonatomic)BOOL isShowViewContent;  //控制上下栏的显示状态
@property(assign,nonatomic)CGRect oldRect;
@end
@implementation XKPlayView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.oldRect = frame;
        //搭建界面
        [self settigPlayViewUI];

    }
    return self;
}

-(void)setParentVC:(UIViewController *)parentVC{
    _parentVC = parentVC;
}
-(void)setShowTopBackBtn:(BOOL)showTopBackBtn{
    _showTopBackBtn = showTopBackBtn;
    self.topBackBtn.hidden = !_showTopBackBtn;
}
-(void)setVideoTitle:(NSString *)videoTitle{
    _videoTitle = videoTitle;
    self.topTitleLab.text = _videoTitle;
}
-(void)setVideoUrl:(NSString *)videoUrl{
    _videoUrl = videoUrl;
    
    ////初始化 视频播放的控件
    [self settingAvPlayObjsWithUrl:_videoUrl];
}
-(void)setIsLoopPlayVideo:(BOOL)isLoopPlayVideo{
    _isLoopPlayVideo = isLoopPlayVideo;
}
//搭建界面
-(void)settigPlayViewUI{
    
    //获取到系统的音量
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat currentVol = audioSession.outputVolume;
    self.volumeNum = currentVol;
    
    CGFloat scrollWidth = self.width;
    //上面和下面的 view
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
    [topView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"top_shadow"]]];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 160, self.width, 40)];
    [bottomView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_shadow"]]];
    
    [self addSubview:topView];
    [self addSubview:bottomView];
    
    //添加各种内容按钮
    //头上返回按钮
    UIButton *topBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [topBackBtn setBackgroundImage:[UIImage imageNamed:@"night_icon_back"] forState:UIControlStateNormal];
    topBackBtn.frame = CGRectMake(10, 9, 40, 33);
    [topBackBtn addTarget:self action:@selector(backBtnclick) forControlEvents:UIControlEventTouchUpInside];
    topBackBtn.hidden = !self.showTopBackBtn;
    [topView addSubview:topBackBtn];
    
    
    //头上视频名称
    UILabel *topTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.width-20, 40)];
    topTitleLab.textAlignment = NSTextAlignmentCenter;
    topTitleLab.numberOfLines = 1;
    topTitleLab.font = [UIFont systemFontOfSize:20];
    topTitleLab.textColor = [UIColor whiteColor];
    topTitleLab.text = self.videoTitle;
    [topView addSubview:topTitleLab];
    [topView bringSubviewToFront:topBackBtn];
    
    //地下的按钮设置
    //地下播放开关
    UIButton *bottomPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomPlayBtn setBackgroundImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    [bottomPlayBtn setBackgroundImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateSelected];
    bottomPlayBtn.frame = CGRectMake(10, 8, 24, 24);
    [bottomPlayBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:bottomPlayBtn];
    //显示时间的lab
    NSString *timeStr = @"00:00/12:22";
    CGSize timeLabSize = [self getLabWithStr:timeStr withFontNum:12 withLimitSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bottomPlayBtn.frame)+5, 0, timeLabSize.width+3, 40)];
    timeLab.font = [UIFont systemFontOfSize:12];
    timeLab.text = timeStr;
    timeLab.textColor = [UIColor whiteColor];
    [bottomView addSubview:timeLab];
    
    //设置进度条
    UISlider *slider = [UISlider new];
    [slider addTarget:self
               action:@selector(sliderChange:)
     forControlEvents:UIControlEventValueChanged];
    [slider setThumbImage:[UIImage imageNamed:@"thumbImage"]
                 forState:UIControlStateNormal];
    //设置最大值的颜色   故事整体的颜色
    slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    //     slider.maximumTrackTintColor = [UIColor clearColor];
    //    slider.minimumTrackTintColor = [UIColor orangeColor];
    //    [slider setMaximumTrackImage:[UIImage imageNamed:@"MaximumTrackImage"]
    //                        forState:UIControlStateNormal];
    //设置滑动了 颜色
    [slider setMinimumTrackImage:[UIImage imageNamed:@"MinimumTrackImage"]
                        forState:UIControlStateNormal];
    slider.frame = CGRectMake(CGRectGetMaxX(timeLab.frame)+2, 0, scrollWidth-CGRectGetMaxX(timeLab.frame)-2-2-40, 40);
    slider.value = 0;
    [bottomView addSubview:slider];
    
    //设置的还需缓存进度条
    UIProgressView *cacheProgress = [UIProgressView new];
    //填充的颜色   就是缓存了的颜色
    cacheProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    //    cacheProgress.progressTintColor = [UIColor orangeColor];
    
    //没有填充的颜色  上面的slider已经设置过整体的颜色  故可以不用设置
    cacheProgress.trackTintColor = [UIColor clearColor];
    cacheProgress.frame = CGRectMake(slider.x, 0, slider.width, 2);
    cacheProgress.centerY = slider.centerY;
    [bottomView addSubview:cacheProgress];
    
    [bottomView bringSubviewToFront:slider];
    
    //最右边的控制全屏的按钮
    UIButton *fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullBtn setBackgroundImage:[UIImage imageNamed:@"sc_video_play_ns_enter_fs_btn"] forState:UIControlStateNormal];
    [fullBtn setBackgroundImage:[UIImage imageNamed:@"sc_video_play_fs_enter_ns_btn"] forState:UIControlStateSelected];
    fullBtn.frame = CGRectMake(self.width-30-10, 5, 30, 30);
    [fullBtn addTarget:self action:@selector(fullBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:fullBtn];
    
    //添加中间的内容
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, scrollWidth, 200-40-40)];
    middleView.backgroundColor = [UIColor clearColor];
    [self addSubview:middleView];
    
    //添加中间的播放按钮
    UIButton *middleplayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [middleplayBtn setBackgroundImage:[UIImage imageNamed:@"full_play_btn"] forState:UIControlStateNormal];
    [middleplayBtn setBackgroundImage:[UIImage imageNamed:@"full_pause_btn"] forState:UIControlStateSelected];
    
    middleplayBtn.y = middleView.height*0.5-15;
    middleplayBtn.centerX = middleView.width*0.5;
    middleplayBtn.size = CGSizeMake(30, 30);
    [middleplayBtn addTarget:self action:@selector(middlPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [middleView addSubview:middleplayBtn];
    

    
    self.topView = topView;
    self.bottomView = bottomView;
    self.topBackBtn = topBackBtn;
    self.topTitleLab = topTitleLab;
    self.bottomPlayBtn = bottomPlayBtn;
    self.bottomTimeLab = timeLab;
    self.slider = slider;
    self.cacheProgress = cacheProgress;
    self.fullBtn = fullBtn;
    self.middleView = middleView;
    self.middlePlayBtn = middleplayBtn;
    
    //设置界面上的手势
    [self addPlayViewGes];
}

//设置界面上的手势
-(void) addPlayViewGes{
    //给播放区域添加 点击手势
    UITapGestureRecognizer *tapGesturRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapPlayerView)];
    [self.middleView addGestureRecognizer:tapGesturRecognizer];
    
    //添加双击手势
    UITapGestureRecognizer *tapGesturRecognizerDouble =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapDoublePlayerView)];
    [self.middleView addGestureRecognizer:tapGesturRecognizerDouble];
    tapGesturRecognizerDouble.numberOfTapsRequired = 2;
    [tapGesturRecognizer requireGestureRecognizerToFail:tapGesturRecognizerDouble];
    //添加上下滑动手势改变音量
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpClick:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.middleView addGestureRecognizer:upSwipe];
    
    UISwipeGestureRecognizer *dowmSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDowmClick:)];
    dowmSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.middleView addGestureRecognizer:dowmSwipe];
    
    //添加左右滑动改变视屏进度
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftClick:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.middleView addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightClick:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.middleView addGestureRecognizer:rightSwipe];
}

// 初始化AVPlayerItem视频内容对象
- (AVPlayerItem *)getPlayItemWithUrl:(NSString *)videoUrl {
    // 编码文件名，以防含有中文，导致存储失败
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *urlStr = [videoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *url = [NSURL URLWithString:urlStr];
    // 创建播放内容对象
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    return item;
}

//初始化 视频播放的控件
-(void)settingAvPlayObjsWithUrl:(NSString*)urlStr{
    
    //初始化AVPlayerItem视频内容对象  视频播放都是在里面添加数据
    AVPlayerItem *playerItem = [self getPlayItemWithUrl:urlStr];
    
    //// 创建视频播放器  avplayer
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    // 添加播放进度监听
    AVPlayerItem *item = player.currentItem;
    __weak typeof (self) weakSelf = self;
    [player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        // CMTime是表示视频时间信息的结构体，包含视频时间点、每秒帧数等信息
        // 获取当前播放到的秒数
        
        float current = CMTimeGetSeconds(time);
        // 获取视频总播放秒数
        float total = CMTimeGetSeconds(item.duration);
        //        NSLog(@"获取当前播放到的秒数 %f  获取视频总播放秒数%f",current,total);
        //设置当前的播放时
        NSString *totalStr = [self timeFormatted:total];
        NSString *currentStr = [self timeFormatted:current];
        strongSelf.bottomTimeLab.text = [NSString stringWithFormat:@"%@:%@",currentStr,totalStr];
        
        //设置进度slider的情况
        strongSelf.slider.value = current/total;
    }];
    // 添加播放内容KVO监听  监听playerItem
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //初始化  视频图层对象  AVPlayerLayer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 0, self.width, self.height);
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    // 添加进控件图层
    [self.layer addSublayer:playerLayer];
    
    self.layer.masksToBounds = YES;
    
    //把播放界面上的控件移到最前面
    [self bringSubviewToFront:self.topView];
    [self bringSubviewToFront:self.bottomView];
    [self bringSubviewToFront:self.middleView];
    
    //开始播放
    [player play];
    
    self.playerItem = playerItem;
    self.playerLayer = playerLayer;
    self.player = player;
    
    //改变播放按钮的状态
    self.bottomPlayBtn.selected = YES;
    self.middlePlayBtn.selected = YES;
    
    //添加事件的监听
    [self addNotificationToPlayerItem];
}

// 属性发生变化，KVO响应函数
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    // 状态发生改变
    if ([keyPath isEqualToString:@"status"]) {
        //        [self.activity stopAnimating];
        AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
        //视频可以播放了
        if (status == AVPlayerStatusReadyToPlay) {
            self.videoStartPlayStatus(@"开始播放");
        } else if (status == AVPlayerStatusFailed){
            self.videoStartPlayStatus(@"播放失败");
        }else if (status == AVPlayerStatusUnknown){
            self.videoStartPlayStatus(@"未知错误");
        }
    }
    // 缓冲区域变化
    else if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {

        NSArray *array = playerItem.loadedTimeRanges;
        // 已缓冲范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        NSTimeInterval totalDuration = CMTimeGetSeconds(playerItem.duration);
        self.cacheProgress.progress = totalBuffer / totalDuration;
        
    }
}

//添加Notification的监听
- (void)addNotificationToPlayerItem {
    // 添加通知中心监听视频播放完成
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(playerDidFinished:)
                   name:AVPlayerItemDidPlayToEndTimeNotification
                 object:self.player.currentItem];
    
    // 监听屏幕改变
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [center addObserver:self
               selector:@selector(orientationChanged:)
                   name:UIDeviceOrientationDidChangeNotification
                 object:device];
}

#pragma mark  界面上的点击事件
//返回按钮点击
-(void)backBtnclick{
    NSLog(@"点击返回");
    //当界面全屏的时  点击返回小的界面
    if (self.height == [UIScreen mainScreen].bounds.size.height && self.width == [UIScreen mainScreen].bounds.size.width) {
        //改变界面为竖屏
        [self forceOrientationPortraitWith:self.parentVC];
    }else{
        //不然就点击返回界面 回调block
        if (self.backBtnClick) {
            self.backBtnClick();
        }
    }
}

//底部播放按钮点击
-(void)bottomBtnClick:(UIButton*)btn{
    NSLog(@"底部播放按钮点击");
    NSLog(@"中部播放按钮点击");
    //点击播放  先判断一步  是否是重新播放的
    if(self.slider.value == 1){
        //刷新界面   重新播放
        [self reloadPlayStatusUI];
        return;
    }
    if(btn.selected){
        [self.player pause];
    }else{
        [self.player play];
    }
    btn.selected = !btn.selected;
    self.middlePlayBtn.selected = !self.middlePlayBtn.selected;
    
}

//中间播放按钮点击
-(void)middlPlayBtnClick:(UIButton*)btn{
    NSLog(@"中部播放按钮点击");
    //点击播放  先判断一步  是否是重新播放的
    if(self.slider.value == 1){
        //刷新界面   重新播放
        [self reloadPlayStatusUI];
        return;
    }
    if(btn.selected){
        [self.player pause];
    }else{
        [self.player play];
    }
    btn.selected = !btn.selected;
    self.bottomPlayBtn.selected = !self.bottomPlayBtn.selected;
}
//移动进度
-(void)sliderChange:(UISlider *)slider{
    NSLog(@"移动进度");
    //当移动了slider的时候   1.改变进度的时间  2.改变视频
    //获取到改变的时间   逻辑：整个视频时间乘以 slider的值
    NSString *currentStr = [self timeFormatted:CMTimeGetSeconds(self.player.currentItem.duration)*slider.value];
    NSString *totalStr = [self timeFormatted:CMTimeGetSeconds(self.player.currentItem.duration)];
    self.bottomTimeLab.text = [NSString stringWithFormat:@"%@:%@",currentStr,totalStr];
    
    //改变视频的情况
    [self.player seekToTime:CMTimeMakeWithSeconds(CMTimeGetSeconds(self.player.currentItem.duration)*slider.value, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


//底部控制全屏按钮点
-(void)fullBtnClick:(UIButton*)btn{
    NSLog(@"全屏按钮按钮点击");
    //逻辑：1.先判断当前屏幕的情况   2.按照屏幕情况的来设置需要改变的位置  3.接着改变按钮状态 4.然后刷新界面
    //    btn.selected = !btn.selected;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"屏幕的旋转情况 fullBtnClick %ld",(long)orientation);
    //home在下面    1 UIInterfaceOrientationPortrait
    //home 在  左边   4  UIInterfaceOrientationLandscapeRight
    //home 在  右边   3  UIInterfaceOrientationLandscapeLeft
    
    //当屏幕在1的情况时  给变成4  当在 3、4的时候变成1；
    
    if(orientation == UIInterfaceOrientationPortrait){
        self.topBackBtn.hidden = NO;
        //改变界面为横屏
        [self forceOrientationLandscapeWith:self.parentVC];
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        //改变界面为竖屏
        [self forceOrientationPortraitWith:self.parentVC];
    }
}

// 允许自动旋转
-(BOOL)shouldAutorotate{
    return YES;
}
// 横屏时是否将状态栏隐藏
-(BOOL)prefersStatusBarHidden{
    return NO;
}
// 横屏 home键在右边
-(void)forceOrientationLandscapeWith:(UIViewController *)VC{
    
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=NO;
    appdelegate.isForceLandscape=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:VC.view.window];
    
    //强制翻转屏幕，Home键在右边。
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}
// 竖屏
- (void)forceOrientationPortraitWith:(UIViewController *)VC{
    
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=YES;
    appdelegate.isForceLandscape=NO;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:VC.view.window];
    
    //强制翻转屏幕
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}

//刷新界面   重新播放
-(void)reloadPlayStatusUI{
    //改变视频的情况  从零开始
    self.slider.value = 0;
    [self.player seekToTime:CMTimeMakeWithSeconds(CMTimeGetSeconds(self.player.currentItem.duration)*0,NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    //按钮状态改变
    self.middlePlayBtn.selected = YES;
    self.bottomPlayBtn.selected = YES;
    [self.player play];
    
    
}
#pragma mark  手势的方法
//手势的点击
-(void)tapPlayerView{
    NSLog(@"点击手势");
    //点击手势  当状态是no的时候 点击隐藏界面  反之显示
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.hidden = !self.isShowViewContent;
        self.bottomView.hidden = !self.isShowViewContent;
        self.middlePlayBtn.hidden = !self.isShowViewContent;
        self.isShowViewContent = !self.isShowViewContent;
    }];
    
}
//点击两次的情况
-(void)tapDoublePlayerView{
    NSLog(@"点击两次");
    NSLog(@"%d",self.bottomPlayBtn.selected);
    if(self.bottomPlayBtn.selected){
        [self.player pause];
        self.bottomPlayBtn.selected = NO;
        self.middlePlayBtn.selected = NO;
    }else{
        [self.player play];
        self.bottomPlayBtn.selected = YES;
        self.middlePlayBtn.selected = YES;
    }
    
}

//上下滑动改变音量手势
-(void)swipeUpClick:(UISwipeGestureRecognizer*)upSwipeGes{
    NSLog(@"改变音量 增加 %@",upSwipeGes);
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    // retrieve system volumefloat systemVolume = volumeViewSlider.value;
    // change system volume, the value is between 0.0f and 1.0f
    self.volumeNum = self.volumeNum == 1? 1.0:self.volumeNum + 0.0625;
    [volumeViewSlider setValue:self.volumeNum animated:NO];
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}
-(void)swipeDowmClick:(UISwipeGestureRecognizer*)dowmSwipeGes{
    NSLog(@"改变音量 减少 %@",dowmSwipeGes);
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    // retrieve system volumefloat systemVolume = volumeViewSlider.value;
    // change system volume, the value is between 0.0f and 1.0f
    self.volumeNum = self.volumeNum == 0? 0.0:self.volumeNum - 0.0625;
    [volumeViewSlider setValue:self.volumeNum animated:NO];
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

//左右滑动手势
-(void)swipeLeftClick:(UISwipeGestureRecognizer*)leftSwipeGes{
    NSLog(@"改变视屏 增加 %@",leftSwipeGes);
}
-(void)swipeRightClick:(UISwipeGestureRecognizer*)rightSwipeGes{
    NSLog(@"改变视屏 减少 %@",rightSwipeGes);
}


#pragma mark notif 的监听事件
//视频播放情况
-(void)playerDidFinished:(NSNotification*)notif{
    NSLog(@"监听视频的播放情况  获取的数据%@",notif);
    //循环播放
    if (self.isLoopPlayVideo) {
        //刷新界面   重新播放
        [self reloadPlayStatusUI];
        return;
    }
    
    //视频播放完成的情况 1.把隐藏的界面显示  2.改变按钮暂停状态  然后重新点击  重头开始播放
    self.topView.hidden = NO;
    self.bottomView.hidden = NO;
    self.middleView.hidden = NO;
    self.middlePlayBtn.selected = NO;
    self.bottomPlayBtn.selected = NO;
    self.slider.value = 1;
    
}

//屏幕的旋转情况
-(void)orientationChanged:(NSNotification*)notif{
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"屏幕的旋转情况  %ld",(long)orientation);
    //home在下面    1 UIInterfaceOrientationPortrait
    //home 在  左边   4  UIInterfaceOrientationLandscapeRight
    //home 在  左边   4  UIInterfaceOrientationLandscapeRight
    //home 在  右边   3  UIInterfaceOrientationLandscapeLeft
    CGFloat screenWidth = [ UIScreen mainScreen ].bounds.size.width;
    CGFloat screenHeight = [ UIScreen mainScreen ].bounds.size.height;
    if(orientation == UIInterfaceOrientationPortrait){

        [self settingReloadObjFrameWithViderViewFram:CGRectMake(self.oldRect.origin.x, self.oldRect.origin.y, self.oldRect.size.width, self.oldRect.size.height)];
        self.fullBtn.selected = NO;
    }else if (orientation == UIInterfaceOrientationLandscapeRight){

        [self settingReloadObjFrameWithViderViewFram:CGRectMake(0, 0, screenWidth, screenHeight)];
        self.fullBtn.selected = YES;
    }else if (orientation == UIInterfaceOrientationLandscapeLeft){

        self.fullBtn.selected = YES;
        [self settingReloadObjFrameWithViderViewFram:CGRectMake(0, 0, screenWidth, screenHeight)];
    }
}

//重新来设置控件的所有fram
-(void)settingReloadObjFrameWithViderViewFram:(CGRect)frame{
    
    
    self.frame = frame;
    self.playerLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    self.topView.frame = CGRectMake(0, 0, frame.size.width, 40);
    self.topBackBtn.frame = CGRectMake(10, 9, 40, 33);
    self.topTitleLab.frame = CGRectMake(10, 0, frame.size.width-20, 40);
    [self.topView bringSubviewToFront:self.topBackBtn];
    
    
    self.bottomView.frame = CGRectMake(0, frame.size.height-40, frame.size.width, 40);
    self.bottomPlayBtn.frame = CGRectMake(10, 8, 24, 24);
    self.bottomTimeLab.frame = CGRectMake(CGRectGetMaxX(self.bottomPlayBtn.frame)+5, 0, self.bottomTimeLab.width, 40);
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.bottomTimeLab.frame)+2, 0, frame.size.width-CGRectGetMaxX(self.bottomTimeLab.frame)-2-2-40, 40);
    self.cacheProgress.frame = CGRectMake(self.slider.x, 0, self.slider.width, 2);
    self.cacheProgress.centerY = self.slider.centerY;
    self.fullBtn.frame = CGRectMake(frame.size.width-30-10, 5, 30, 30);
    
    self.middleView.frame = CGRectMake(0, 40, frame.size.width, frame.size.height-40-40);
    self.middlePlayBtn.frame = CGRectMake(self.middleView.width*0.5-15, self.middleView.height*0.5-15, 30, 30);
}

-(void)dealloc{
    if (self.player) {
        [self.player pause];
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        self.playerItem = nil;
        self.player = nil;
        self.playerLayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}


#pragma mark 私有方法 计算数据的方法
//获取到lab随内容的size
-(CGSize)getLabWithStr:(NSString *)str withFontNum:(NSInteger)num withLimitSize:(CGSize)limitSize{
    NSDictionary *attributesTitle = @{NSFontAttributeName:[UIFont systemFontOfSize:num],};
    CGSize titleTextSize = [str boundingRectWithSize:limitSize
                                             options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin  attributes:attributesTitle context:nil].size;
    return titleTextSize;
}

//计算视频的时间
- (NSString *)timeFormatted:(float)totalSeconds {
    int min = floor(totalSeconds/60);
    int sec = round(totalSeconds - min * 60);
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

//销毁方法
-(void)destoryPlayObj{
    if (self.player) {
        [self.player pause];
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        self.playerItem = nil;
        self.player = nil;
        self.playerLayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}
@end
