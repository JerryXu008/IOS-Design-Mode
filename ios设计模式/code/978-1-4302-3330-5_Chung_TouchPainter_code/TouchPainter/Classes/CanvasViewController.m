//
//  CanvasViewController.m
//  Composite
//
//  Created by Carlo Chung on 9/11/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "CanvasViewController.h"
#import "Dot.h"
#import "Stroke.h"
#import "PaperCanvasViewGenerator.h"
@implementation CanvasViewController

@synthesize canvasView=canvasView_;
@synthesize scribble=scribble_;
@synthesize strokeColor=strokeColor_;
@synthesize strokeSize=strokeSize_;


// hook up everything with a new Scribble instance
- (void) setScribble:(Scribble *)aScribble
{
  if (scribble_ != aScribble)
  {
    [scribble_ autorelease];
    scribble_ = [aScribble retain];
    
    // add itself to the scribble as
    // an observer for any changes to
    // its internal state - mark
      //NSKeyValueObservingOptionInitial 作用：这个选项让scribble通知CanvasViewCOntroller，在这个消息调用之后立即提供其mark属性得初始值。这个
      //选项很重要，因为当Scribble对象在init方法中进行初始化，第一次设置mark属性时，CanvasViewController也需要接收通知
    [scribble_ addObserver:self
                forKeyPath:@"mark"
                   options:NSKeyValueObservingOptionInitial | 
                           NSKeyValueObservingOptionNew
                   context:nil];
  }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  // Get a default canvas view
  // with the factory method of 
  // the CanvasViewGenerator
    //我的理解，加在view视图，简单工厂模式，返回不同的画布视图
  CanvasViewGenerator *defaultGenerator = [[[CanvasViewGenerator alloc] init] autorelease];
  //  CanvasViewGenerator *defaultGenerator = [[[PaperCanvasViewGenerator alloc] init] autorelease];
  [self loadCanvasViewWithGenerator:defaultGenerator];
  
  // initialize a Scribble model
  Scribble *scribble = [[[Scribble alloc] init] autorelease];//设置观察者模式
  [self setScribble:scribble];
  
  // setup default stroke color and size
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  CGFloat redValue = [userDefaults floatForKey:@"red"];
  CGFloat greenValue = [userDefaults floatForKey:@"green"];
  CGFloat blueValue = [userDefaults floatForKey:@"blue"];
  CGFloat sizeValue = [userDefaults floatForKey:@"size"];
  
  [self setStrokeSize:sizeValue];//设置颜色
    //设置颜色
  [self setStrokeColor:[UIColor colorWithRed:redValue
                                       green:greenValue 
                                        blue:blueValue 
                                       alpha:1.0]];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning 
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
  [canvasView_ release];
  [scribble_ release];
  [super dealloc];
}

#pragma mark -
#pragma mark Stroke color and size accessor methods

- (void) setStrokeSize:(CGFloat) aSize
{
  // enforce the smallest size
  // allowed
  if (aSize < 5.0) 
  {
    strokeSize_ = 5.0;
  }
  else 
  {
    strokeSize_ = aSize;
  }
}


#pragma mark -
#pragma mark Toolbar button hit method

- (IBAction) onBarButtonHit:(id)button
{
  UIBarButtonItem *barButton = button;
  
  if ([barButton tag] == 4)
  {
    [self.undoManager undo];
  }
  else if ([barButton tag] == 5)
  {
    [self.undoManager redo];
  }
}

//点击保存图像
- (IBAction) onCustomBarButtonHit:(CommandBarButton *)barButton
{
  [[barButton command] execute];
}

#pragma mark -
#pragma mark Loading a CanvasView from a CanvasViewGenerator

- (void) loadCanvasViewWithGenerator:(CanvasViewGenerator *)generator
{
  [canvasView_ removeFromSuperview];
  CGRect aFrame = CGRectMake(0, 0, 320, 436);
  CanvasView *aCanvasView = [generator canvasViewWithFrame:aFrame];
  [self setCanvasView:aCanvasView];
  NSInteger viewIndex = [[[self view] subviews] count] - 1;
  [[self view] insertSubview:canvasView_ atIndex:viewIndex];
}


#pragma mark -
#pragma mark Touch Event Handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  startPoint_ = [[touches anyObject] locationInView:canvasView_];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint lastPoint = [[touches anyObject] previousLocationInView:canvasView_];
  
  // add a new stroke to scribble
  // if this is indeed a drag from
  // a finger
  if (CGPointEqualToPoint(lastPoint, startPoint_))//重新开始起点，重新画一条线
  {
      NSLog(@"%@",@"看看是不是一直走啊");
    id <Mark> newStroke = [[[Stroke alloc] init] autorelease];
    [newStroke setColor:strokeColor_];
    [newStroke setSize:strokeSize_];
    
    [scribble_ addMark:newStroke shouldAddToPreviousMark:NO];//这是一个'线'对象，加在scrible得最顶层
    
    // retrieve a new NSInvocation for drawing and
    // set new arguments for the draw command
  //  NSInvocation *drawInvocation = [self drawScribbleInvocation];
   // [drawInvocation setArgument:&newStroke atIndex:2];
    
    // retrieve a new NSInvocation for undrawing and
    // set a new argument for the undraw command
   // NSInvocation *undrawInvocation = [self undrawScribbleInvocation];
   // [undrawInvocation setArgument:&newStroke atIndex:2];
    
    // execute the draw command with the undraw command
  //  [self executeInvocation:drawInvocation withUndoInvocation:undrawInvocation];
  }
  
  // add the current touch as another vertex to the
  // temp stroke
  CGPoint thisPoint = [[touches anyObject] locationInView:canvasView_];
  //初始化顶点  ,不断新建得顶点，一条线段由无数个顶点组成，顶点加在最后一个'线'对象上面，由顶点组成了线段
  Vertex *vertex = [[[Vertex alloc]
                     initWithLocation:thisPoint] 
                    autorelease];
  
  // we don't need to undo every vertex
  // so we are keeping this
  [scribble_ addMark:vertex shouldAddToPreviousMark:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint lastPoint = [[touches anyObject] previousLocationInView:canvasView_];
  CGPoint thisPoint = [[touches anyObject] locationInView:canvasView_];
  
  // if the touch never moves (stays at the same spot until lifted now)
  // just add a dot to an existing stroke composite
  // otherwise add it to the temp stroke as the last vertex
  if (CGPointEqualToPoint(lastPoint, thisPoint)) //从来没移动，那么就是画得是一个点
  {
    Dot *singleDot = [[[Dot alloc] 
                       initWithLocation:thisPoint] 
                      autorelease];
    [singleDot setColor:strokeColor_];
    [singleDot setSize:strokeSize_];
    
    [scribble_ addMark:singleDot shouldAddToPreviousMark:NO];//点不属于任何一个线段，所以加在scribe得顶层
    
    // retrieve a new NSInvocation for drawing and
    // set new arguments for the draw command
   // NSInvocation *drawInvocation = [self drawScribbleInvocation];
   // [drawInvocation setArgument:&singleDot atIndex:2];
    
    // retrieve a new NSInvocation for undrawing and
    // set a new argument for the undraw command
   // NSInvocation *undrawInvocation = [self undrawScribbleInvocation];
   // [undrawInvocation setArgument:&singleDot atIndex:2];
    
    // execute the draw command with the undraw command
    //[self executeInvocation:drawInvocation withUndoInvocation:undrawInvocation];
  }
  else //我自己加的，画线得时候最后一个顶点，没啥作用
  {
      CGPoint thisPoint = [[touches anyObject] locationInView:canvasView_];
      //初始化顶点  ,不断新建得顶点，一条线段由无数个顶点组成，顶点加在最后一个'线'对象上面，由顶点组成了线段
      Vertex *vertex = [[[Vertex alloc]
                         initWithLocation:thisPoint]
                        autorelease];
      
      // we don't need to undo every vertex
      // so we are keeping this
      [scribble_ addMark:vertex shouldAddToPreviousMark:YES];
  
  }
  // reset the start point here
  startPoint_ = CGPointZero;
  
  // if this is the last point of stroke
  // don't bother to draw it as the user
  // won't tell the difference
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  // reset the start point here
  startPoint_ = CGPointZero;
}


#pragma mark -
#pragma mark Scribble observer method
//mark改变之后获得得通知，进行重画，目前具体重画方法还不知道
- (void) observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object 
                         change:(NSDictionary *)change 
                        context:(void *)context
{
  if ([object isKindOfClass:[Scribble class]] && 
      [keyPath isEqualToString:@"mark"])
  {
    id <Mark> mark = [change objectForKey:NSKeyValueChangeNewKey];
    [canvasView_ setMark:mark];
    [canvasView_ setNeedsDisplay];
  }
}


#pragma mark -
#pragma mark Draw Scribble Invocation Generation Methods

- (NSInvocation *) drawScribbleInvocation
{
  NSMethodSignature *executeMethodSignature = [scribble_ 
                                               methodSignatureForSelector:
                                               @selector(addMark:
                                                         shouldAddToPreviousMark:)];
  NSInvocation *drawInvocation = [NSInvocation 
                                  invocationWithMethodSignature:
                                  executeMethodSignature];
  [drawInvocation setTarget:scribble_];
  [drawInvocation setSelector:@selector(addMark:shouldAddToPreviousMark:)];
  BOOL attachToPreviousMark = NO;
  [drawInvocation setArgument:&attachToPreviousMark atIndex:3];
  
  return drawInvocation;
}

- (NSInvocation *) undrawScribbleInvocation
{
  NSMethodSignature *unexecuteMethodSignature = [scribble_ 
                                                 methodSignatureForSelector:
                                                 @selector(removeMark:)];
  NSInvocation *undrawInvocation = [NSInvocation 
                                    invocationWithMethodSignature:
                                    unexecuteMethodSignature];
  [undrawInvocation setTarget:scribble_]; 
  [undrawInvocation setSelector:@selector(removeMark:)];
  
  return undrawInvocation;
}

#pragma mark Draw Scribble Command Methods

- (void) executeInvocation:(NSInvocation *)invocation 
        withUndoInvocation:(NSInvocation *)undoInvocation
{
  [invocation retainArguments];

  [[self.undoManager prepareWithInvocationTarget:self] 
   unexecuteInvocation:undoInvocation
   withRedoInvocation:invocation];
  
  [invocation invoke];
}

- (void) unexecuteInvocation:(NSInvocation *)invocation 
          withRedoInvocation:(NSInvocation *)redoInvocation
{  
  [[self.undoManager prepareWithInvocationTarget:self] 
   executeInvocation:redoInvocation
   withUndoInvocation:invocation];
  
  [invocation invoke];
}

@end
