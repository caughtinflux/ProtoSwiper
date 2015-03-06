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
#import "PBJVision.h"

@import AVFoundation;

@interface UIView (ICCat)
@property (nonatomic, readonly) CGPoint internalCenter;
@end

@implementation UIView (ICCat)
- (CGPoint)internalCenter {
    return (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
}
@end

@interface ViewController () <UIDynamicAnimatorDelegate> {
    UIDynamicAnimator *_animator, *_animator2;
    UIView *_topView, *_bottomView, *_middleView;
    UIPanGestureRecognizer *_recognizer;
    UIAttachmentBehavior *_middleAnchorBottom, *_middleAnchorTop;
    PathView *_pathView;
    UIImageView *_imageView;
}
@property (nonatomic, assign) BOOL hideControlViews;
@end

@implementation ViewController

#pragma mark - Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPreview];
    [self setupDynamics];
    [self setupImageViewAndMask];
    
    _recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.view addGestureRecognizer:_recognizer];
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayTick:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Setup
- (void)setupPreview {
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatStandard;
    [vision startPreview];
    AVCaptureVideoPreviewLayer *previewLayer = [PBJVision sharedInstance].previewLayer;
    previewLayer.frame = self.view.bounds;
    previewLayer.backgroundColor = [UIColor redColor].CGColor;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:previewLayer];
}

- (void)setupDynamics {
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _animator2 = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    _topView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 20, 20}]; _topView.backgroundColor = [UIColor yellowColor];
    _bottomView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 20, 20}]; _bottomView.backgroundColor = [UIColor redColor];
    _middleView = [[UIView alloc] initWithFrame:(CGRect){CGRectGetMaxX(self.view.bounds) + 50, 333, 20, 20}]; _middleView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_topView];
    [self.view addSubview:_bottomView];
    [self.view addSubview:_middleView];
    
    FBTweakBind(self, hideControlViews, @"Adjustments", @"Control Views", @"hidden", YES);
    
    SwiperControlBehavior *topControlBehavior = [[SwiperControlBehavior alloc] initWithItem:_topView attachedToItem:_middleView pullDirection:(CGVector){0, -1.0}];
    SwiperControlBehavior *bottomControlBehavior = [[SwiperControlBehavior alloc] initWithItem:_bottomView attachedToItem:_middleView pullDirection:(CGVector){0, 1.0}];
    
    _middleAnchorBottom = [[UIAttachmentBehavior alloc] initWithItem:_middleView attachedToAnchor:_middleView.center];
    _middleAnchorBottom.length = 0.0;
    
    _middleAnchorTop = [[UIAttachmentBehavior alloc] initWithItem:_middleView attachedToAnchor:_middleView.center];
    _middleAnchorTop.length = 0.0;
    
    [_animator addBehavior:topControlBehavior];
    [_animator2 addBehavior:bottomControlBehavior];
    [_animator2 addBehavior:_middleAnchorTop];
    [_animator addBehavior:_middleAnchorBottom];
}

- (void)setupImageViewAndMask {
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AnImage"]];
    [self.view addSubview:_imageView];
    
    _pathView = [[PathView alloc] initWithFrame:self.view.bounds];
    _pathView.backgroundColor = [UIColor clearColor];
    _imageView.layer.mask = _pathView.layer;
//    [self.view addSubview:_pathView];
}

#pragma mark - Setter Override
- (void)setHideControlViews:(BOOL)hideControlViews {
    _hideControlViews = hideControlViews;
    _topView.hidden = _middleView.hidden = _bottomView.hidden = hideControlViews;
}

#pragma mark - Pan Handling (lol)
- (void)panned:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        _middleAnchorBottom.anchorPoint = _middleAnchorTop.anchorPoint = location;
    }
    else {
        CGPoint newAnchor = CGPointZero;
        if (location.x < self.view.internalCenter.x) {
            newAnchor = (CGPoint){0, self.view.internalCenter.y};
        }
        else {
            newAnchor = (CGPoint){CGRectGetMaxX(self.view.bounds), self.view.internalCenter.y};
        }
        _middleAnchorBottom.anchorPoint = _middleAnchorTop.anchorPoint = newAnchor;
    }
}

#pragma mark - Display Update Callback
- (void)displayTick:(CADisplayLink *)link {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startPoint = (CGPoint){_topView.center.x, 0};
    CGPoint endPoint = (CGPoint){_bottomView.center.x, CGRectGetMaxY(self.view.bounds)};
    CGPoint midPoint = _middleView.center;
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:midPoint];
    [_pathView setPath:path startPoint:(CGPoint){_topView.center.x, 0}];
}

@end
