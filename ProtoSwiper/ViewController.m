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

static inline CGPoint GetControlPointForQuadBezier(CGPoint start, CGPoint end, CGPoint mid) {
    CGPoint ctrl = CGPointZero;
    ctrl.x = -(((.25 * start.x) + (0.25 * end.x) - mid.x) / 0.5);
    ctrl.y = -(((.25 * start.y) + (0.25 * end.y) - mid.y) / 0.5);
    return ctrl;
}

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
    AVCaptureVideoPreviewLayer *_previewLayer;
}
@property (nonatomic, assign) BOOL hideControlViews;
@property (nonatomic, assign) CGFloat imageOffset;
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
    _previewLayer = [PBJVision sharedInstance].previewLayer;
    _previewLayer.frame = self.view.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:_previewLayer];
}

- (void)setupDynamics {
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _animator2 = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    _topView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 20, 20}]; _topView.backgroundColor = [UIColor yellowColor];
    _bottomView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 20, 20}]; _bottomView.backgroundColor = [UIColor redColor];
    _middleView = [[UIView alloc] initWithFrame:(CGRect){CGRectGetMaxX(self.view.bounds), 333, 20, 20}]; _middleView.backgroundColor = [UIColor greenColor];
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
    FBTweakBind(self, imageOffset, @"Adjustments", @"Image View", @"offset", 50);
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AnImage"]];
    _imageView.contentMode = UIViewContentModeLeft;
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
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        CGPoint translation = [gestureRecognizer translationInView:self.view];

        CGPoint anchor = _middleAnchorBottom.anchorPoint;
        anchor.x += translation.x; anchor.y += translation.y;
        _middleAnchorBottom.anchorPoint = _middleAnchorTop.anchorPoint = anchor;
        
        [gestureRecognizer setTranslation:CGPointZero inView:self.view];
    }
    else {
        CGPoint location = _middleView.center;
        CGPoint newAnchor = CGPointZero;
        CGPoint newPreviewOrigin = CGPointZero;
        if (location.x < self.view.internalCenter.x) {
            newAnchor = (CGPoint){0, self.view.internalCenter.y};
            newPreviewOrigin.x = -CGRectGetMaxX(self.view.bounds);
        }
        else {
            newAnchor = (CGPoint){CGRectGetMaxX(self.view.bounds), self.view.internalCenter.y};
            newPreviewOrigin.x = 0;
        }
        _previewLayer.frame = (CGRect){newPreviewOrigin, _previewLayer.bounds.size};
        _middleAnchorBottom.anchorPoint = _middleAnchorTop.anchorPoint = newAnchor;
    }
}

#define MIN3(_a, _b, _c) (MIN(_a, _b) < MIN(_a, _c) ? MIN(_a, _b) : MIN(_a, _c))
#define MAX3(_a, _b, _c) (MAX(_a, _b) > MAX(_a, _c) ? MAX(_a, _b) : MAX(_a, _c))
#pragma mark - Display Update Callback
- (void)displayTick:(CADisplayLink *)link {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startPoint = [self.view convertPoint:(CGPoint){_topView.center.x, 0} toView:_imageView];
    CGPoint endPoint = [self.view convertPoint:(CGPoint){_bottomView.center.x, CGRectGetMaxY(self.view.bounds)} toView:_imageView];
    CGPoint midPoint = [self.view convertPoint:_middleView.center toView:_imageView];
    CGPoint controlPoint = GetControlPointForQuadBezier(startPoint, endPoint, midPoint);
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];

    CGRect frame = _imageView.frame;
    frame.origin.x = fmax(MIN3(_topView.center.x, _bottomView.center.x, _middleView.center.x) - self.imageOffset, 0);
    _imageView.frame = frame;
    frame.size.width = (CGRectGetWidth(self.view.bounds) - _middleView.center.x);
    _pathView.frame = _imageView.bounds;
    [_pathView setPath:path startPoint:(CGPoint){startPoint.x, 0}];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGPoint previewOrigin = _previewLayer.frame.origin;
    previewOrigin.x = fmin(MAX3(_topView.center.x, _bottomView.center.x, _middleView.center.x) - CGRectGetWidth(self.view.bounds), 0);
    _previewLayer.frame = (CGRect){previewOrigin, _previewLayer.frame.size};
    [CATransaction commit];
}

@end
