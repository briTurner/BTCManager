//
//  BTJoyStickPadView.m
//  BTJoyStick
//
//  Created by Brian Turner on 1/28/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "BTCJoyStickView.h"
#import "BTCJoyStickThumbView.h"
#import "BTCManager.h"

@interface BTCJoyStickView () {
    CGPoint joyStickOrigin;
    
    BTCJoyStickThumbView *joyStickThumbView;
    
    UIView *selectedView;
    
    CGFloat radiusDistance;
}

@end

@implementation BTCJoyStickView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTag:NSNotFound];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        radiusDistance = frame.size.width / 2.0;
        
        CGSize joyStickSize = CGSizeMake(40, 40);
        joyStickThumbView = [[BTCJoyStickThumbView alloc] initWithFrame:CGRectMake(joyStickOrigin.x - joyStickSize.width/2, joyStickOrigin.y - joyStickSize.height/2, joyStickSize.width, joyStickSize.height)];
        
        [self addSubview:joyStickThumbView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"Make sure you are setting the tag for all joysticks instanciated through IB");
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        radiusDistance = [self frame].size.width / 2;
        
        CGSize joyStickSize = CGSizeMake(40, 40);
        joyStickThumbView = [[BTCJoyStickThumbView alloc] initWithFrame:CGRectMake(joyStickOrigin.x - joyStickSize.width/2, joyStickOrigin.y - joyStickSize.height/2, joyStickSize.width, joyStickSize.height)];
        
        [self addSubview:joyStickThumbView];
    }
    return self;
}

- (void)layoutSubviews {
    joyStickOrigin = CGPointMake([self frame].size.width / 2, [self frame].size.height / 2);
    [joyStickThumbView setCenter:CGPointMake([self frame].size.width / 2, [self frame].size.height / 2)];
}

#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint locationOfTouch = [touch locationInView:self];
    locationOfTouch = [self convertPoint:locationOfTouch toView:joyStickThumbView];
    
    if ([joyStickThumbView pointInside:locationOfTouch withEvent:nil]) {
        selectedView = joyStickThumbView;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (selectedView) {
        UITouch *touch = [touches anyObject];
        CGPoint locationOfTouch = [touch locationInView:self];
        locationOfTouch = [self convertPoint:locationOfTouch toView:self];
        
        JoyStickDataStruct joyStickData;
        joyStickData.joyStickID = [self tag];
        if (joyStickData.joyStickID != NSNotFound) {
            
            float distanceOfPoint = 0;
            
            float angelOfPoint = [self angleBetweenPoints:joyStickOrigin andSecond:locationOfTouch];
            
            if ([self distanceBetweenPoint:locationOfTouch andPoint:joyStickOrigin] <= radiusDistance) {
                [joyStickThumbView setCenter:locationOfTouch];
                distanceOfPoint = [self distanceBetweenPoint:joyStickOrigin andPoint:locationOfTouch] / radiusDistance;
            }
            
            else if ([self distanceBetweenPoint:locationOfTouch andPoint:joyStickOrigin] > radiusDistance) {
                distanceOfPoint = 1;
                
                CGFloat yValue = sinf(angelOfPoint + (M_PI * .5)) * radiusDistance;
                CGFloat xValue = cosf(angelOfPoint + (M_PI * .5)) * radiusDistance;
                
                [joyStickThumbView setCenter:CGPointMake(joyStickOrigin.x+yValue, joyStickOrigin.y-xValue)];
            }
            joyStickData.angle = angelOfPoint;
            joyStickData.distance = distanceOfPoint;
            [[BTCManager sharedManager] sendNetworkPacketWithID:DataPacketTypeJoyStick withData:&joyStickData ofLength:sizeof(joyStickData) reliable:NO toPeers:nil];
        } else {
            NSLog(@"This joystick does not have a proper tag.  Please set one either programatically or in IB");
        }
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
            
            [[BTCManager sharedManager] sendNetworkPacketWithID:DataPacketTypeJoyStick withData:&jsData ofLength:sizeof(jsData) reliable:NO toPeers:nil];
        }];
    }
    selectedView = nil;
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
        //upper rightx
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
