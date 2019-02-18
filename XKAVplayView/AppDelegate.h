//
//  AppDelegate.h
//  XKAVplayView
//
//  Created by apple on 2019/2/18.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(assign,nonatomic)BOOL isForcePortrait;
@property(assign,nonatomic)BOOL isForceLandscape;

@end

