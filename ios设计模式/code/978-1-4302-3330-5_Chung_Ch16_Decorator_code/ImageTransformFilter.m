//
//  ImageTransformFilter.m
//  Decorator
//
//  Created by Carlo Chung on 11/30/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ImageTransformFilter.h"

@implementation ImageTransformFilter

@synthesize transform=transform_;


- (id) initWithImageComponent:(id <ImageComponent>)component 
                    transform:(CGAffineTransform)transform
{
  if (self = [super initWithImageComponent:component])
  {
    [self setTransform:transform];
  }
  
  return self;
}

- (void) apply
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // setup transformation
  CGContextConcatCTM(context, transform_);
}

//自己添加的，其实在父类中已经存在
/*- (void) drawInRect:(CGRect)rect
{
  //  NSLog(@"看看执行了几次");
    [self apply];
   [self.component drawInRect:rect];
}*/

@end
