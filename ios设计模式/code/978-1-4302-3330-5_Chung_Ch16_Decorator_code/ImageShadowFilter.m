//
//  ImageShadowFilter.m
//  Decorator
//
//  Created by Carlo Chung on 11/30/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ImageShadowFilter.h"


@implementation ImageShadowFilter

- (void) apply
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // set up shadow
  CGSize offset = CGSizeMake (-25,  15);
  CGContextSetShadow(context, offset, 20.0);
}


//自己添加的，其实在父类中已经存在
/*- (void) drawInRect:(CGRect)rect
{
  //  NSLog(@"看看执行了几次");
    [self apply];
     [self.component drawInRect:rect];
}*/
@end
