//
//  UIView+EXTION.h
//  01新浪微博
//
//  Created by qx-002 on 16/12/7.
//  Copyright © 2016年 谢凯. All rights reserved.
//

#import <UIKit/UIKit.h>
#define KEYWINDOW [UIApplication sharedApplication].keyWindow
#define SECREEN  [UIScreen mainScreen].bounds
@interface UIView (EXTION)

@property(nonatomic ,assign)CGSize size;
@property(nonatomic ,assign)CGPoint point;
@property(nonatomic ,assign)CGFloat x;
@property(nonatomic ,assign)CGFloat y;
@property(nonatomic ,assign)CGFloat width;
@property(nonatomic ,assign)CGFloat height;

@property(nonatomic ,assign)CGFloat centerX;
@property(nonatomic ,assign)CGFloat centerY;
UIColor* getColor(NSString * hexColor);
@end
