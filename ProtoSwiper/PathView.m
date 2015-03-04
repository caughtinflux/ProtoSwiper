//
//  PathView.m
//  ProtoSwiper
//
//  Created by Aditya KD on 04/03/15.
//  Copyright (c) 2015 Aditya KD. All rights reserved.
//

#import "PathView.h"

@implementation PathView

- (void)setPath:(UIBezierPath *)path {
    _path = path;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor redColor] setStroke];
    [_path stroke];
}

@end
