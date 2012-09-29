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
    BTCCharacter *character;
}

@end

@implementation BTCGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        BTCManager *manager = [BTCManager sharedManager];
        [manager configureManagerAsGameWithSessionID:@"gameDemo" connectionRequestBlock:^(NSString *peerID, NSString *displayName, ResponseBlock responseBlock) {
            responseBlock(YES);
        }];
        
        [manager registerJoystickMovedBlock:^(JoyStickDataStruct joystickData, PeerData controllerData) {
            [self moveCharacterWithDistance:joystickData.distance angle:joystickData.angle];
        }];
        
        [manager registerButtonPressBlock:^(ButtonDataStruct buttonData, PeerData controllerData) {
            [character jump];
        }];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    character = [[BTCCharacter alloc] initWithFrame:CGRectMake(150, 200, 100, 100)];
    [character setBackgroundColor:[UIColor redColor]];
    [[self view] addSubview:character];
}

- (void)viewDidAppear:(BOOL)animated {
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    displayLink.frameInterval = 1;
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)update {
    [character update];
}

- (void)moveCharacterWithDistance:(CGFloat)d angle:(CGFloat)a {
    int direction = 0;
    
    CGFloat limitOfBottomRight = (1.0 / 4.0) * (2 * M_PI);
    CGFloat lowerBoundOfTopRight = (3.0 / 4.0) * (2 * M_PI);
    if (a > lowerBoundOfTopRight || a < limitOfBottomRight)
        direction = DirectionRight;
    else
        direction = DirectionLeft;
    [character setDirection:direction];
    [character setVelocity:d];
}

@end
