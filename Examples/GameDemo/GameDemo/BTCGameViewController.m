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
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    character = [[BTCCharacter alloc] initWithFrame:CGRectMake(150, 200, 100, 100)];
    [character setBackgroundColor:[UIColor redColor]];
    [[self view] addSubview:character];
    
    [joystick setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    displayLink.frameInterval = 1;
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
    [accel setUpdateInterval:1.0f/30.0f];
    [accel setDelegate:self];
}

- (void)update {
    [character update];
}

- (IBAction)jump:(id)sender {
    [character jump];
}

#pragma mark - BTCJoystickDelegate Methods

- (void)joystick:(BTCJoyStickView *)js movedDistance:(CGFloat)d andgle:(CGFloat)a {

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
