//
//  BNRControllerDemoVC.m
//  ViewTester
//
//  Created by Brian Turner on 7/21/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BNRControllerDemoVC.h"
#import "BNRControllerDemoView.h"
#import "BTCManager.h"

@interface BNRControllerDemoVC () {
    NSString *_displayName;
    NSString *_controllerID;
}

@end

@implementation BNRControllerDemoVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithControllerID:nil displayName:nil];
}

- (id)initWithControllerID:(NSString *)controllerID displayName:(NSString *)dName {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _displayName = dName;
        _controllerID = controllerID;
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [deviceNameLabel setText:_displayName];
}

- (void)buttonPressed:(ButtonDataStruct)bData {
    [buttonID setHighlighted:!bData.state];
    [buttonID setTitle:[NSString stringWithFormat:@"%i", bData.buttonID] forState:UIControlStateNormal];
}

- (void)joyStick:(int)joyStickID movedDistance:(CGFloat)distance angle:(CGFloat)angle {
    [joystickIDLabel setText:[NSString stringWithFormat:@"%i", joyStickID]];
    [joyStickView setJoyStickDistance:distance angle:angle];
}

- (void)messageRecieved:(NSString *)message {
    [messageLabel setText:message];
}

- (IBAction)vibrateButtonPressed:(id)sender {
    [[BTCManager sharedManager] vibrateControllers:[NSArray arrayWithObject:_controllerID]];
}

- (void)viewDidUnload {
    buttonID = nil;
    joystickIDLabel = nil;
    deviceNameLabel = nil;
    messageLabel = nil;
    [super viewDidUnload];
}
@end
