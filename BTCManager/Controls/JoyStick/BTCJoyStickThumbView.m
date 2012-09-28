//
//  BTJoyStickView.m
//  BTJoyStick
//
//  Created by Brian Turner on 1/28/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "BTCJoyStickThumbView.h"


@implementation BTCJoyStickThumbView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(myContext, 1, 0, 0, 1);
    CGContextFillEllipseInRect(myContext, self.bounds);
}

@end
