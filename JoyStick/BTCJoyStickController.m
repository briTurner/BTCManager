//
//  BTCJoyStickVC.m
//  BTJoyStickTester
//
//  Created by Brian Turner on 7/14/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCJoyStickController.h"
#import "BTCJoyStickView.h"
#import "BTCJoyStickPadView.h"
#import "BTCManager.h"

@interface BTCJoyStickController () {
    
}
@property (nonatomic) CGRect viewFrame;
@end

@implementation BTCJoyStickController
@synthesize manager;
@synthesize viewFrame;

+ (id)joyStickWithTag:(int)tag andManager:(BTCManager *)m andFrame:(CGRect)f inView:(UIView *)view {
    BTCJoyStickController *joyStick = [[super allocWithZone:nil] initWithNibName:nil bundle:nil];
    [joyStick setViewFrame:f];
    [[joyStick view] setTag:tag];
    
    if ([m registerJoystickWithManager:joyStick]) {
        [view addSubview:[joyStick view]];
    }
    return joyStick;
}

+ (id)allocWithZone:(NSZone *)zone {
    NSLog(@"please use joyStickWithTag:andManager:andFrame:inView: to setup a BTCJoyStickVC correctly");
    return [self joyStickWithTag:NSNotFound andManager:nil andFrame:CGRectZero inView:nil];
}

- (void)loadView {
    BTCJoyStickPadView *padView = [[BTCJoyStickPadView alloc] initWithFrame:[self viewFrame]];
    [padView setController:self];
    [self setView:padView];
}

- (void)joyStickPositionUpdated:(JoyStickDataStruct)jsData {
    [manager sendNetworkPacketWithID:dataPacketTypeJoyStick withData:&jsData ofLength:sizeof(jsData) reliable:NO toPeers:nil];
}

@end
