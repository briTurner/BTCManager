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

- (void)touchUp:(id)sender;
- (void)touchDown:(id)sender;

@end

@implementation BTCButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        [self addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self setTag:NSNotFound];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self tag] == 0)
            NSLog(@"Make sure you are setting the tag for all buttons instanciated through IB");
        [self addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)touchUp:(id)sender {
    int buttonTag = [self tag];
    
    if (buttonTag != NSNotFound) {
        
        ButtonDataStruct buttonData;
        buttonData.buttonID = buttonTag;
        buttonData.state = ButtonStateUp;
        
        [[BTCManager sharedManager] sendNetworkPacketWithID:DataPacketTypeButton withData:&buttonData ofLength:sizeof(buttonData) reliable:YES toPeers:nil];
    } else {
        NSLog(@"Please set the buttons tag before attempting to use. You can do this programatically or in IB");
    }
    
}

- (void)touchDown:(id)sender {
    int buttonTag = [self tag];
    
    if (buttonTag != NSNotFound) {
        
        ButtonDataStruct buttonData;
        buttonData.buttonID = buttonTag;
        buttonData.state = ButtonStateDown;
        
        [[BTCManager sharedManager] sendNetworkPacketWithID:DataPacketTypeButton withData:&buttonData ofLength:sizeof(buttonData) reliable:YES toPeers:nil];
    } else {
        NSLog(@"Please set the buttons tag before attempting to use. You can do this programatically or in IB");
    }
    
}


@end
