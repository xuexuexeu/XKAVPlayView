//
//  UIView+EXTION.m
//  01新浪微博
//
//  Created by qx-002 on 16/12/7.
//  Copyright © 2016年 谢凯. All rights reserved.
//

#import "UIView+EXTION.h"

@implementation UIView (EXTION)
-(void)setSize:(CGSize)size{

    self.frame = (CGRect){{self.frame.origin.x,self.frame.origin.y},size};
}
-(void)setPoint:(CGPoint)point{

    self.frame = (CGRect){point,{self.frame.size.width,self.frame.size.height}};
}

-(void)setX:(CGFloat)x{

    self.frame = (CGRect){{x,self.frame.origin.y},{self.frame.size.width,self.frame.size.height}};
}

-(void)setY:(CGFloat)y{

self.frame = (CGRect){{self.frame.origin.x,y},{self.frame.size.width,self.frame.size.height}};
}

-(void)setWidth:(CGFloat)width{

self.frame = (CGRect){{self.frame.origin.x,self.frame.origin.y},{width,self.frame.size.height}};
}

-(void)setHeight:(CGFloat)height{

    self.frame = (CGRect){{self.frame.origin.x,self.frame.origin.y},{self.frame.size.width,height}};

}

-(CGSize)size{

    return self.frame.size;
}

-(CGPoint)point{

    return self.frame.origin;
}

-(CGFloat)x{

    return self.frame.origin.x;
}

-(CGFloat)y{

    return self.frame.origin.y;
    
}

-(CGFloat)width{

    return self.frame.size.width;
}

-(CGFloat)height{
    return self.frame.size.height;
}

-(void)setCenterX:(CGFloat)centerX{


    self.center = CGPointMake(centerX, self.center.y);
}

-(void)setCenterY:(CGFloat)centerY{

    self.center = CGPointMake(self.center.x,centerY);
}

-(CGFloat)centerY{

    return self.center.y;
    
}

-(CGFloat)centerX{


    return self.center.x;
}
UIColor* getColor(NSString * hexColor)
{
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}
@end
