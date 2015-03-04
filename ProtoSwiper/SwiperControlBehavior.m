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
        attch.length = 250.0;
        [self addChildBehavior:attch];
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[item]];
        gravity.gravityDirection = direction;
        [self addChildBehavior:gravity];
        
        UIDynamicItemBehavior *ib = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
        ib.friction = 0.5;
        ib.resistance = 2.0;
        [self addChildBehavior:ib];
        
    }
    return self;
}
@end
