//
//  BTJoyStickPadView.m
//  BTJoyStick
//
//  Created by Brian Turner on 1/28/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "BTCJoyStickPadView.h"
#import "BTCJoyStickView.h"
#import "BTCJoyStickController.h"

@interface BTCJoyStickPadView () {
    CGPoint joyStickOrigin;    
    
    BTCJoyStickView *joyStickView;
    
    UIView *selectedView;
}

@end

@implementation BTCJoyStickPadView
@synthesize controller;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGSize joyStickSize = CGSizeMake(40, 40);
        joyStickView = [[BTCJoyStickView alloc] initWithFrame:CGRectMake(joyStickOrigin.x - joyStickSize.width/2, joyStickOrigin.y - joyStickSize.height/2, joyStickSize.width, joyStickSize.height)];
        
        [self addSubview:joyStickView];
    }
    return self;
}

- (void)layoutSubviews {
    joyStickOrigin = CGPointMake([self frame].size.width / 2, [self frame].size.height / 2);        
    [joyStickView setCenter:CGPointMake([self frame].size.width / 2, [self frame].size.height / 2)];
}

#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint locationOfTouch = [touch locationInView:self];
    locationOfTouch = [self convertPoint:locationOfTouch toView:joyStickView];
    
    if ([joyStickView pointInside:locationOfTouch withEvent:nil]) {
        selectedView = joyStickView;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (selectedView) {
        UITouch *touch = [touches anyObject];
        CGPoint locationOfTouch = [touch locationInView:self];
        locationOfTouch = [self convertPoint:locationOfTouch toView:self];
        
        JoyStickDataStruct joyStickData;
        joyStickData.joyStickID = [self tag];
        
        float distanceOfPoint = 0;
        
        float angelOfPoint = [self angleBetweenPoints:joyStickOrigin andSecond:locationOfTouch];
        
        if ([self distanceBetweenPoint:locationOfTouch andPoint:joyStickOrigin] <75) {
            [joyStickView setCenter:locationOfTouch];
            distanceOfPoint = [self distanceBetweenPoint:joyStickOrigin andPoint:locationOfTouch]/75;    
        }
        
        else if ([self distanceBetweenPoint:locationOfTouch andPoint:joyStickOrigin] > 75) {
            distanceOfPoint = 1;
            
            CGFloat yValue = sinf(angelOfPoint)*75;
            CGFloat xValue = cosf(angelOfPoint)*75;
            
            [joyStickView setCenter:CGPointMake(joyStickOrigin.x+yValue, joyStickOrigin.y-xValue)];
        }
        joyStickData.angle = angelOfPoint;
        joyStickData.distance = distanceOfPoint;
        [controller joyStickPositionUpdated:joyStickData];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {   
    if (selectedView)
    {
        [UIView animateWithDuration:.2 animations:^(void) {
            [selectedView setCenter:joyStickOrigin];
        } completion:^(BOOL finished) {
            JoyStickDataStruct jsData;
            jsData.distance = 0;
            jsData.angle = 0;
            jsData.joyStickID = [self tag];
            
            [controller joyStickPositionUpdated:jsData];
        }];
    }
    selectedView = nil;
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

#pragma mark - my math stuff

- (CGFloat) angleBetweenPoints:(CGPoint)first andSecond:(CGPoint)second {
    CGFloat height = abs(second.y - first.y);
    CGFloat width = abs(first.x - second.x);
    
    CGFloat rads = 0;
    if (second.y <= first.y && second.x >= first.x) {
        rads = atan(width/height);
    } else if(second.y >= first.y &&second.x >= first.x) {
        rads = atan(height/width);
        rads += (M_PI*.5);
    } else  if (second.y >= first.y && second.x <= first.x) {
        rads = atan(width/height);
        rads += M_PI;        
    } else if (second.x <= first.x && second.y <= first.y) {
        rads = atan(height/width);
        rads += (M_PI*1.5);
    }
    return rads;
}

- (CGFloat) distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};


@end
