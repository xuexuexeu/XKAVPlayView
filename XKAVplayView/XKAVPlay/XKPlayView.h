//
//  XKPlayView.h
//  XKAVplayView
//
//  Created by apple on 2019/2/18.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XKPlayView : UIView
@property(strong,nonatomic)UIViewController *parentVC;
@property(assign,nonatomic)BOOL showTopBackBtn;
@property(strong,nonatomic)NSString *videoTitle;//视频标题
@property(strong,nonatomic)NSString *videoUrl;//视频地址
@property(assign,nonatomic)BOOL isLoopPlayVideo;//是否循环播放
/// click action
@property (nonatomic, copy) void (^backBtnClick)(void);
@property (nonatomic, copy) void (^videoStartPlayStatus)(NSString *status);

//销毁方法
-(void)destoryPlayObj;
@end
