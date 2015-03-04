//
//  SwiperControlBehavior.m
//  ProtoSwiper
//
//  Created by Aditya KD on 04/03/15.
//  Copyright (c) 2015 Aditya KD. All rights reserved.
//

#import "SwiperControlBehavior.h"

@implementation SwiperControlBehavior
- (instancetype)initWithItem:(id<UIDynamicItem>)item attachedToItem:(id<UIDynamicItem>)attachedItem pullDirection:(CGVector)direction {
    if ((self = [super init])) {
        UIAttachmentBehavior *attch = [[UIAttachmentBehavior alloc] initWithItem:item attachedToItem:attachedItem];
        FBTweakBind(attch, length, @"Adjustments", @"Curve control", @"attachment length", 250.0);
        [self addChildBehavior:attch];
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[item]];
        FBTweakBind(gravity, magnitude, @"Adjustments", @"Physics", @"gravity", 1.5);
        gravity.gravityDirection = direction;
        [self addChildBehavior:gravity];
        
        UIDynamicItemBehavior *ib = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
        FBTweakBind(ib, density, @"Adjustments", @"Physics", @"square density", 1.0);
        FBTweakBind(ib, friction, @"Adjustments", @"Physics", @"square friction", 0.5);
        FBTweakBind(ib, resistance, @"Adjustments", @"Physics", @"square resistance", 1.0);
        [self addChildBehavior:ib];
    }
    return self;
}
@end
