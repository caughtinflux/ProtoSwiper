//
//  ViewController.m
//  ProtoSwiper
//
//  Created by Aditya KD on 01/03/15.
//  Copyright (c) 2015 Aditya KD. All rights reserved.
//

#import "ViewController.h"
#import "SwiperControlBehavior.h"
#import "PathView.h"

@interface UIView (ICCat)
@property (nonatomic, readonly) CGPoint internalCenter;
@end

@implementation UIView (ICCat)
- (CGPoint)internalCenter {
    return (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
}
@end

@interface ViewController () {
    UIDynamicAnimator *_animator, *_animator2;
    UIView *_topView, *_bottomView, *_middleView;
    UIPanGestureRecognizer *_recognizer;
    UIAttachmentBehavior *_middleAnchorBottom, *_middleAnchorTop;
    PathView *_pathView;
}
@property (nonatomic, assign) BOOL hideControlViews;
@end

@implementation ViewController

#pragma mark - Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    
    FBTweakBind(self, hideControlViews, @"Adjustments", @"Control Views", @"hidden", YES);

    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _animator2 = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    _topView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 20, 20}]; _topView.backgroundColor = [UIColor yellowColor];
    _bottomView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 20, 20}]; _bottomView.backgroundColor = [UIColor redColor];
    _middleView = [[UIView alloc] initWithFrame:(CGRect){100, 200, 20, 20}]; _middleView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_topView];
    [self.view addSubview:_bottomView];
    [self.view addSubview:_middleView];
    
    SwiperControlBehavior *topControlBehavior = [[SwiperControlBehavior alloc] initWithItem:_topView attachedToItem:_middleView pullDirection:(CGVector){0, -1.0}];
    SwiperControlBehavior *bottomControlBehavior = [[SwiperControlBehavior alloc] initWithItem:_bottomView attachedToItem:_middleView pullDirection:(CGVector){0, 1.0}];
    [_animator addBehavior:topControlBehavior];
    [_animator2 addBehavior:bottomControlBehavior];
    
    _middleAnchorBottom = [[UIAttachmentBehavior alloc] initWithItem:_middleView attachedToAnchor:(CGPoint){200, 200}];
    _middleAnchorBottom.length = 0.0;
    [_animator addBehavior:_middleAnchorBottom];
    
    _middleAnchorTop = [[UIAttachmentBehavior alloc] initWithItem:_middleView attachedToAnchor:(CGPoint){200, 200}];
    _middleAnchorTop.length = 0.0;
    [_animator2 addBehavior:_middleAnchorTop];
    
    _recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.view addGestureRecognizer:_recognizer];
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayTick:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    _pathView = [[PathView alloc] initWithFrame:self.view.bounds];
    _pathView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_pathView];
}

#pragma mark - Setter Override
- (void)setHideControlViews:(BOOL)hideControlViews {
    _hideControlViews = hideControlViews;
    _topView.hidden = _middleView.hidden = _bottomView.hidden = hideControlViews;
}

#pragma mark - Pan Handling (lol)
- (void)panned:(UIPanGestureRecognizer *)gestureRecognizer {
    _middleAnchorBottom.anchorPoint = _middleAnchorTop.anchorPoint = [gestureRecognizer locationInView:self.view];
}

#pragma mark - Display Update Callback
- (void)displayTick:(CADisplayLink *)link {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:(CGPoint){_topView.center.x, 0}];
    [path addQuadCurveToPoint:(CGPoint){_bottomView.center.x, CGRectGetMaxY(self.view.bounds)} controlPoint:_middleView.center];
    [_pathView setPath:path startPoint:(CGPoint){_topView.center.x, 0}];
}

@end
