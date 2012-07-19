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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        [self setTag:NSNotFound];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)emptyAction {
}

@end
