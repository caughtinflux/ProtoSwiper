//
//  SwiperControlBehavior.m
//  ProtoSwiper
//
//  Created by Aditya KD on 04/03/15.
//  Copyright (c) 2015 Aditya KD. All rights reserved.
//

#import "SwiperControlBehavior.h"

@implementation SwiperControlBehavior {
    UIAttachmentBehavior *_attachment;
    UIGravityBehavior *_gravity;
    UIDynamicItemBehavior *_itemBehavior;
}

- (instancetype)initWithItem:(id<UIDynamicItem>)item attachedToItem:(id<UIDynamicItem>)attachedItem pullDirection:(CGVector)direction {
    if ((self = [super init])) {
        _attachment = [[UIAttachmentBehavior alloc] initWithItem:item attachedToItem:attachedItem];
        FBTweakBind(_attachment, length, @"Adjustments", @"Curve control", @"attachment length", 300.0);
        
        _gravity = [[UIGravityBehavior alloc] initWithItems:@[item]];
        FBTweakBind(_gravity, magnitude, @"Adjustments", @"Physics", @"gravity", 88.0);
        _gravity.gravityDirection = direction;
        
        _itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
        FBTweakBind(_itemBehavior, density, @"Adjustments", @"Physics", @"square density", 5.0);
        FBTweakBind(_itemBehavior, friction, @"Adjustments", @"Physics", @"square friction", 42.0);
        FBTweakBind(_itemBehavior, resistance, @"Adjustments", @"Physics", @"square resistance", 23.00);

        [self addChildBehavior:_attachment];
        [self addChildBehavior:_gravity];
        [self addChildBehavior:_itemBehavior];
    }
    return self;
}

- (void)willMoveToAnimator:(UIDynamicAnimator *)dynamicAnimator {
    [super willMoveToAnimator:dynamicAnimator];
//  For some reason, these values need to be force-set on the behaviours on moving to the animator
    _attachment.length = FBTweakValue(@"Adjustments", @"Curve control", @"attachment length", 300.0);
    _gravity.magnitude = FBTweakValue(@"Adjustments", @"Physics", @"gravity", 88.0);
    _itemBehavior.density = FBTweakValue(@"Adjustments", @"Physics", @"square density", 5.0);
    _itemBehavior.friction = FBTweakValue(@"Adjustments", @"Physics", @"square friction", 42.0);
    _itemBehavior.resistance = FBTweakValue(@"Adjustments", @"Physics", @"square resistance", 23.00);
}

@end
