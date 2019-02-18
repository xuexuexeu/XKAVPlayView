//
//  ViewController.m
//  XKAVplayView
//
//  Created by apple on 2019/2/18.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "ViewController.h"
#import "XKPlayView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor greenColor];
    
    XKPlayView *playView = [[XKPlayView alloc] initWithFrame:CGRectMake(10, 65, [UIScreen mainScreen].bounds.size.width-20, 200)];
    playView.parentVC = self;
//    playView.showTopBackBtn = NO;
//    playView.isLoopPlayVideo = YES;
    playView.videoTitle = @"123456";
    playView.videoUrl = @"http://flv.bn.netease.com/videolib1/1901/10/71s7unc8b/SD/71s7unc8b-mobile.mp4";
    [self.view addSubview:playView];
    
    playView.backBtnClick = ^{
        NSLog(@"点击返回");
    };
    NSLog(@"缓存中");
    playView.videoStartPlayStatus = ^(NSString *status) {
        NSLog(@"%@",status);
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
