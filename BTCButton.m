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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        [self addTarget:self action:@selector(emptyAction) forControlEvents:UIControlEventTouchUpInside];
        [self setTag:NSNotFound];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"Make sure you are setting the tag for all buttons instanciated through IB");
        [self addTarget:self action:@selector(emptyAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [super sendAction:action to:target forEvent:event];
    int buttonTag = [self tag];
    
    if (buttonTag != NSNotFound) {
        
        ButtonDataStruct buttonData;
        buttonData.buttonID = buttonTag;
        buttonData.state = ButtonStateUp;
        
        [[BTCManager sharedManager] sendNetworkPacketWithID:dataPacketTypeButton withData:&buttonData ofLength:sizeof(buttonData) reliable:YES toPeers:nil];
    } else {
        NSLog(@"Please set the buttons tag before attempting to use. You can do this programatically or in IB");
    }
}



- (void)emptyAction {
}

@end
