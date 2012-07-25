//
//  BTButton.m
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/12/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCButton.h"
#import "BTCManager.h"


@interface BTCButton ()

- (void)emptyAction;

@end

@implementation BTCButton
@synthesize manager;


+ (id)buttonWithTag:(int)t manager:(BTCManager *)m frame:(CGRect)f inView:(UIView *)view {
    BTCButton *button = [[super allocWithZone:nil] initWithFrame:f];
    [button setTag:t];
    if ([m registerButtonWithManager:button]) {
        [view addSubview:button];
    }
    return button;
}

+ (id)allocWithZone:(NSZone *)zone {
    NSLog(@"Please use buttonWithTag:andManager:andFrame:inView: in order to configure a BTButton correctly");
    return [super allocWithZone:zone];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        [self addTarget:self action:@selector(emptyAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
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
