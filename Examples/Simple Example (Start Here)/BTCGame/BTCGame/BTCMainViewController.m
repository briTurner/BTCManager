//
//  BTCMainViewController.m
//  BTCGame
//
//  Created by Brian Turner on 9/27/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import "BTCMainViewController.h"
#import "BTCManager.h"

@interface BTCMainViewController ()

@end

@implementation BTCMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        BTCManager *manager = [BTCManager sharedManager];
        [manager configureManagerAsGameWithSessionID:@"btcDemoID" connectionRequestBlock:^(NSString *peerID, NSString *displayName, ResponseBlock responseBlock) {
            //this block will run when the server recieves a connection request from a controller.
            //at the very least, it should accept or reject the connection. but should probably
            //ask the user and response accordingly.
            
            responseBlock(YES);
        }];
        [manager startSession];
        
        
        // if you would like to be notified when a button is pressed,
        //register for the event using the following method
        [manager registerButtonPressBlock:^(ButtonDataStruct buttonData, PeerData controllerData) {
           NSLog(@"Button %i pressed %@ from controller: %@", buttonData.buttonID, buttonData.state == ButtonStateUp ? @"Up" : @"Down", controllerData.displayName);
        }];

        // if you would like to be notified when a joystick is moved,
        //register for the event using the following method
        [manager registerJoystickMovedBlock:^(JoyStickDataStruct joystickData, PeerData controllerData) {
            NSLog(@"Joystick %i moved distance %f at angle %f from controller: %@", joystickData.joyStickID, joystickData.distance, joystickData.angle, controllerData.displayName);
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


@end
