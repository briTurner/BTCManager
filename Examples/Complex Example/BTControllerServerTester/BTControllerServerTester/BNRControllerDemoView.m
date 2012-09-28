//
//  BNRControllerDemoView.m
//  ViewTester
//
//  Created by Brian Turner on 7/21/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BNRControllerDemoView.h"

@interface BNRControllerDemoView () {
    CGPoint joystickOrigin;
}
@end

@implementation BNRControllerDemoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

- (void)setJoyStickDistance:(CGFloat)d angle:(CGFloat)a {
    
    CGFloat deltaX = cosf(a - ((M_PI / 2) - (.5 * M_PI))) * (d * ([self bounds].size.width / 2));
    CGFloat deltaY = sinf(a - ((M_PI / 2) - (.5 * M_PI))) * (d * ([self bounds].size.width / 2 ));
    
    joystickOrigin.x = [self bounds].size.width / 2 + deltaX;
    joystickOrigin.y = [self bounds].size.height / 2 + deltaY;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(myContext, 1, 0, 0, 1);
    CGContextFillEllipseInRect(myContext, [self bounds]);
    
    CGContextSetRGBFillColor(myContext, 0, 1, 0, 1);
    CGContextFillEllipseInRect(myContext, CGRectMake(joystickOrigin.x - 10, joystickOrigin.y - 10, 20, 20));
}


@end
