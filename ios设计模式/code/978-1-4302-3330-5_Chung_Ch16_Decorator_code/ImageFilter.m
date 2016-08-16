//
//  ImageFilter.m
//  Decorator
//
//  Created by Carlo Chung on 11/30/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ImageFilter.h"


@implementation ImageFilter

@synthesize component=component_;


- (id) initWithImageComponent:(id <ImageComponent>) component
{
  if (self = [super init])
  {
    // save an ImageComponent
    [self setComponent:component];
  }
  
  return self;
}

- (void) apply
{
  // should be overridden by subclasses
  // to apply real filters
}
/*
 1.动态方法解析
 向当前类发送 resolveInstanceMethod: 信号，检查是否动态向该类添加了方法。（迷茫请搜索：@dynamic）
 2.快速消息转发
 检查该类是否实现了 forwardingTargetForSelector: 方法，若实现了则调用这个方法。若该方法返回值对象非nil或非self，则向该返回对象重新发送消息。
 3.标准消息转发
 runtime发送methodSignatureForSelector:消息获取Selector对应的方法签名。返回值非空则通过forwardInvocation:转发消息，返回值为空则向当前对象发送doesNotRecognizeSelector:消息，程序崩溃退出。
 
 */

- (id) forwardingTargetForSelector:(SEL)aSelector
{
  NSString *selectorName = NSStringFromSelector(aSelector);
  if ([selectorName hasPrefix:@"draw"])
  {
    [self apply];
  }
  
    id a= component_;
    
  return component_;
    
    
  //  return  self;
}

/*- (void) drawInRect:(CGRect)rect
{
    NSLog(@"看看执行了几次");
    [self apply];
    [component_ drawInRect:rect];
}*/

/*
- (void) drawAsPatternInRect:(CGRect)rect
{
  [self apply];
  [component_ drawAsPatternInRect:rect];
}



- (void) drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
  [self apply];
  [component_ drawAtPoint:point
                blendMode:blendMode
                    alpha:alpha];
}

- (void) drawInRect:(CGRect)rect
{
  [self apply];
  [component_ drawInRect:rect];
}

- (void) drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
  [self apply];
  [component_ drawInRect:rect
               blendMode:blendMode
                   alpha:alpha];
}
*/



@end
