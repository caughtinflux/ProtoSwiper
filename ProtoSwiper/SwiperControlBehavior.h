//
//  SwiperControlBehavior.h
//  ProtoSwiper
//
//  Created by Aditya KD on 04/03/15.
//  Copyright (c) 2015 Aditya KD. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SwiperControlBehavior : UIDynamicBehavior
- (instancetype)initWithItem:(id<UIDynamicItem>)item attachedToItem:(id<UIDynamicItem>)attachedItem pullDirection:(CGVector)direction;
@end
