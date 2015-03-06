//
//  PathView.m
//  ProtoSwiper
//
//  Created by Aditya KD on 04/03/15.
//  Copyright (c) 2015 Aditya KD. All rights reserved.
//

#import "PathView.h"

@implementation PathView {
    UIBezierPath *_path;
}

- (void)setPath:(UIBezierPath *)path startPoint:(CGPoint)startPoint {
    _path = path;
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    [newPath moveToPoint:_path.currentPoint];
    [newPath addLineToPoint:(CGPoint){CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)}];
    [newPath addLineToPoint:(CGPoint){CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds)}];
    [newPath addLineToPoint:startPoint];
    [_path appendPath:newPath];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor blackColor] setStroke];
    [[UIColor orangeColor] setFill];
    [_path stroke];
    [_path fill];
}

@end
