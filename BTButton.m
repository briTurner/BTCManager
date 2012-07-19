//
//  BTButton.m
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/12/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTButton.h"
#import "BTCManager.h"

@implementation BTButton
@synthesize manager;


+ (id)buttonWithTag:(int)t andManager:(BTCManager *)m andFrame:(CGRect)f inView:(UIView *)view {
    BTButton *button = [[super allocWithZone:nil] initWithFrame:f];
    [button setTag:t];
    [button setBackgroundColor:[UIColor redColor]];
    [m registerButtonWithManager:button];
    [button setFrame:f];
    [button addTarget:button action:@selector(emptyAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return button;
}

+ (id)allocWithZone:(NSZone *)zone {
    NSLog(@"Please use buttonWithTag:andManager:andFrame:inView: in order to configure a BTButton correctly");
    return [self buttonWithTag:NSNotFound andManager:nil andFrame:CGRectZero inView:nil];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [super sendAction:action to:target forEvent:event];

    int buttonTag = [self tag];
    if (!manager || buttonTag == NSNotFound) {
        NSLog(@"please set manager and tag before attempting to use BTButton");
    } else
        [manager sendNetworkPacketWithID:dataPacketTypeButton withData:&buttonTag ofLength:sizeof(buttonTag) reliable:YES toPeers:nil];
}



- (void)emptyAction {
}

@end
