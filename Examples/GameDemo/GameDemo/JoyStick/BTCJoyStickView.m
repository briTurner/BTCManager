//
//  BTJoyStickPadView.m
//  BTJoyStick
//
//  Created by Brian Turner on 1/28/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "BTCJoyStickView.h"
#import "BTCJoyStickThumbView.h"


@interface BTCJoyStickView () {
    CGPoint joyStickOrigin;
    
    BTCJoyStickThumbView *joyStickView;
    
    UIView *selectedView;
}

@end

@implementation BTCJoyStickView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTag:NSNotFound];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGSize joyStickSize = CGSizeMake(40, 40);
        joyStickView = [[BTCJoyStickThumbView alloc] initWithFrame:CGRectMake(joyStickOrigin.x - joyStickSize.width/2, joyStickOrigin.y - joyStickSize.height/2, joyStickSize.width, joyStickSize.height)];
        
        [self addSubview:joyStickView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"Make sure you are setting the tag for all joysticks instanciated through IB");
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGSize joyStickSize = CGSizeMake(40, 40);
        joyStickView = [[BTCJoyStickThumbView alloc] initWithFrame:CGRectMake(joyStickOrigin.x - joyStickSize.width/2, joyStickOrigin.y - joyStickSize.height/2, joyStickSize.width, joyStickSize.height)];
        
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
        

            
            float distanceOfPoint = 0;
            
            float angelOfPoint = [self angleBetweenPoints:joyStickOrigin andSecond:locationOfTouch];
            
            if ([self distanceBetweenPoint:locationOfTouch andPoint:joyStickOrigin] <= 75) {
                [joyStickView setCenter:locationOfTouch];
                distanceOfPoint = [self distanceBetweenPoint:joyStickOrigin andPoint:locationOfTouch]/75;
            }
            
            else if ([self distanceBetweenPoint:locationOfTouch andPoint:joyStickOrigin] > 75) {
                distanceOfPoint = 1;
                
                CGFloat yValue = sinf(angelOfPoint + (M_PI * .5))*75;
                CGFloat xValue = cosf(angelOfPoint + (M_PI * .5))*75;
                
                [joyStickView setCenter:CGPointMake(joyStickOrigin.x+yValue, joyStickOrigin.y-xValue)];
            }
    [[self delegate] joystick:self movedDistance:distanceOfPoint andgle:angelOfPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (selectedView)
    {
        [UIView animateWithDuration:.2 animations:^(void) {
            [selectedView setCenter:joyStickOrigin];
        } completion:^(BOOL finished) {

        }];
    }
    selectedView = nil;
        [[self delegate] joystick:self movedDistance:0 andgle:0];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(myContext, 0, 0, 1, 1);
    CGContextFillEllipseInRect(myContext, self.bounds);
}

#pragma mark - my math stuff

- (CGFloat) angleBetweenPoints:(CGPoint)first andSecond:(CGPoint)second {
    CGFloat height = abs(second.y - first.y);
    CGFloat width = abs(first.x - second.x);
    
    CGFloat rads = 0;
    if (second.y <= first.y && second.x >= first.x) {
        //upper right
        rads = atan(width/height);
        rads += (M_PI*1.5);
    } else if(second.y >= first.y &&second.x >= first.x) {
        //bottom right
        rads = atan(height/width);
    } else  if (second.y >= first.y && second.x <= first.x) {
        //bottom left
        rads = atan(width/height);
        rads += (M_PI*.5);
    } else if (second.x <= first.x && second.y <= first.y) {
        //top left
        rads = atan(height/width);
        rads += M_PI;
    }
    return rads;
}

- (CGFloat) distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};


@end
