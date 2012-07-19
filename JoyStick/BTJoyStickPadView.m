//
//  BTJoyStickPadView.m
//  BTJoyStick
//
//  Created by Brian Turner on 1/28/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "BTJoyStickPadView.h"


@implementation BTJoyStickPadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
 CGContextRef myContext = UIGraphicsGetCurrentContext();
 
 CGContextSetRGBFillColor(myContext, 0, 0, 1, 1);
 CGContextFillEllipseInRect(myContext, self.bounds);
    // Drawing code
    
}


@end
