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
        attch.length = FBTweakValue(@"Adjustments", @"Curve control", @"attachment length", 300.0);
        FBTweakBind(attch, length, @"Adjustments", @"Curve control", @"attachment length", 300.0);
        [self addChildBehavior:attch];
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[item]];
        gravity.magnitude = FBTweakValue(@"Adjustments", @"Physics", @"gravity", 88.0);
        FBTweakBind(gravity, magnitude, @"Adjustments", @"Physics", @"gravity", 88.0);
        gravity.gravityDirection = direction;
        [self addChildBehavior:gravity];
        
        UIDynamicItemBehavior *ib = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
        ib.density = FBTweakValue(@"Adjustments", @"Physics", @"square density", 5.0);
        FBTweakBind(ib, density, @"Adjustments", @"Physics", @"square density", 5.0);
        ib.friction = FBTweakValue(@"Adjustments", @"Physics", @"square friction", 42.0);
        FBTweakBind(ib, friction, @"Adjustments", @"Physics", @"square friction", 42.0);
        ib.resistance = FBTweakValue(@"Adjustments", @"Physics", @"square resistance", 23.00);
        FBTweakBind(ib, resistance, @"Adjustments", @"Physics", @"square resistance", 23.00);
        [self addChildBehavior:ib];
    }
    return self;
}
@end
