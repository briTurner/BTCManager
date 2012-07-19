//
//  BTCJoyStickVC.m
//  BTJoyStickTester
//
//  Created by Brian Turner on 7/14/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCJoyStickVC.h"
#import "BTJoyStickView.h"
#import "BTJoyStickPadView.h"
#import "BTCManager.h"

@interface BTCJoyStickVC ()

@end

@implementation BTCJoyStickVC
@synthesize manager;

- (void)loadView {
    BTJoyStickPadView *padView = [[BTJoyStickPadView alloc] initWithFrame:CGRectZero];
    [self setView:padView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    joyStickOrigin = CGPointMake(75,75);
    CGSize joyStickSize = CGSizeMake(40, 40);
    
    joyStickView = [[BTJoyStickView alloc] initWithFrame:CGRectMake(joyStickOrigin.x - joyStickSize.width/2, joyStickOrigin.y - joyStickSize.height/2, joyStickSize.width, joyStickSize.height)];
    
    [[self view] addSubview:joyStickView];
}


#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint locationOfTouch = [touch locationInView:self.view];
    locationOfTouch = [self.view convertPoint:locationOfTouch toView:joyStickView];
    
    if ([joyStickView pointInside:locationOfTouch withEvent:nil]) {
        selectedView = joyStickView;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (selectedView) {
        UITouch *touch = [touches anyObject];
        CGPoint locationOfTouch = [touch locationInView:self.view];
        locationOfTouch = [self.view convertPoint:locationOfTouch toView:[self view]];
        
        JoyStickDataStruct joyStickData;
        joyStickData.joyStickID = [[self view] tag];
        
        float distanceOfPoint;
        
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
        
        NSLog(@"joystick moved distance %f and angle %f", joyStickData.distance, joyStickData.angle);
        [manager sendNetworkPacketWithID:dataPacketTypeJoyStick withData:&joyStickData ofLength:sizeof(JoyStickDataStruct) reliable:NO toPeers:nil];
    }
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{   
    if (selectedView)
    {
        [UIView animateWithDuration:.2 animations:^(void) {
            [selectedView setCenter:joyStickOrigin];
        } completion:^(BOOL finished) {
            //            NSLog(@"joystick reset");
        }];
    }
    selectedView = nil;
}



#pragma mark - my math stuff

- (CGFloat) angleBetweenPoints:(CGPoint)first andSecond:(CGPoint)second {
    //    NSLog(@"first point is %f,%f     second point is %f,%f",first.x, first.y, second.x,second.y);
    CGFloat height = abs(second.y - first.y);
    CGFloat width = abs(first.x - second.x);
    //    CGFloat rads = atan(height/width);
    
    if (second.y <= first.y && second.x >= first.x)
    {
        //        NSLog(@"first hem");
        CGFloat rads = atan(width/height);
        return rads;
    }
    if(second.y >= first.y &&second.x >= first.x)
    {
        //       NSLog(@"second hem");
        CGFloat rads = atan(height/width);
        rads += (M_PI*.5);
        return rads;
    }
    if (second.y >= first.y && second.x <= first.x)
    {
        //        NSLog(@"third hem");
        CGFloat rads = atan(width/height);
        rads += M_PI;
        return rads;
        
    }
    if (second.x <= first.x && second.y <= first.y)
    {
        //        NSLog(@"fourth hem");
        CGFloat rads = atan(height/width);
        rads += (M_PI*1.5);
        return rads;
    }
    
    
    
    return 0;
}

- (CGFloat) distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};



@end
