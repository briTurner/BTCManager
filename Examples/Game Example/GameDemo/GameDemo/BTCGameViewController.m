//
//  BTCGameViewController.m
//  GameDemo
//
//  Created by Brian Turner on 9/28/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import "BTCGameViewController.h"
#import "BTCCharacter.h"
#import <QuartzCore/QuartzCore.h>
#import "BTCManager.h"

NSString * const borderType = @"borderType";
NSString * const characterType = @"characterType";


@interface BTCGameViewController () {
    CADisplayLink *displayLink;
    
    NSMutableDictionary *charactersToControllers;
    NSMutableArray *allCharacters;
}

@end

@implementation BTCGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        charactersToControllers = [NSMutableDictionary dictionary];
        
        BTCManager *manager = [BTCManager sharedManager];
        [manager configureManagerAsGameWithSessionID:@"gameDemo" connectionRequestBlock:^(NSString *peerID, NSString *displayName, ResponseBlock responseBlock) {
            responseBlock(YES);
        }];
        
        [manager registerJoystickMovedBlock:^(JoyStickDataStruct joystickData, PeerData controllerData) {
            BTCCharacter *character = [charactersToControllers valueForKey:controllerData.ident];
            [self moveCharacter:character withDistance:joystickData.distance angle:joystickData.angle];
        }];
        
        [manager registerButtonPressBlock:^(ButtonDataStruct buttonData, PeerData controllerData) {
            BTCCharacter *character = [charactersToControllers valueForKey:controllerData.ident];
            [character jump];
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerConnected:) name:BTCManagerNotificationConnectedToController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDisconnected:) name:BTCManagerNotificationDisconnectedFromController object:nil];
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated {
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    displayLink.frameInterval = 1;
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)update {
    for (BTCCharacter *character in allCharacters) {
        [character update];
    }
}

- (void)moveCharacter:(BTCCharacter *)c withDistance:(CGFloat)d angle:(CGFloat)a {
    int direction = 0;
    
    CGFloat limitOfBottomRight = (1.0 / 4.0) * (2 * M_PI);
    CGFloat lowerBoundOfTopRight = (3.0 / 4.0) * (2 * M_PI);
    if (a > lowerBoundOfTopRight || a < limitOfBottomRight)
        direction = DirectionRight;
    else
        direction = DirectionLeft;
    [c setDirection:direction];
    [c setVelocity:d];
}

- (void)controllerConnected:(NSNotification *)note {
    NSLog(@"controller %@ connected", [[note userInfo] valueForKey:kBTCPeerDisplayName]);

    BTCCharacter *character = [[BTCCharacter alloc] initWithFrame:CGRectMake(150, 200, 100, 100)];
    [character setBackgroundColor:[UIColor redColor]];
    [[self view] addSubview:character];
    
    [charactersToControllers setValue:character forKey:[[note userInfo] valueForKey:kBTCPeerID]];
    [allCharacters addObject:character];
}

- (void)controllerDisconnected:(NSNotification *)note {
    NSLog(@"controller %@ disconnected", [[note userInfo] valueForKey:kBTCPeerDisplayName]);
    
    BTCCharacter *character = [charactersToControllers valueForKey:[[note userInfo] valueForKey:kBTCPeerID]];
    
    [character removeFromSuperview];
    [charactersToControllers removeObjectForKey:[[note userInfo] valueForKey:kBTCPeerID]];
    [allCharacters removeObject:character];
}

@end