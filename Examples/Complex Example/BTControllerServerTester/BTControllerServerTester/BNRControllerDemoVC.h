//
//  BNRControllerDemoVC.h
//  ViewTester
//
//  Created by Brian Turner on 7/21/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCConstants.h"

@class BNRControllerDemoView;

@interface BNRControllerDemoVC : UIViewController {
    __weak IBOutlet UILabel *deviceNameLabel;
    __weak IBOutlet BNRControllerDemoView *joyStickView;
    __weak IBOutlet UIButton *buttonID;
    __weak IBOutlet UILabel *joystickIDLabel;
    __weak IBOutlet UILabel *messageLabel;
}

- (id)initWithControllerID:(NSString *)controllerID displayName:(NSString *)dName;

- (void)joyStick:(int)joyStickID movedDistance:(CGFloat)distance angle:(CGFloat)angle;
- (void)buttonPressed:(ButtonDataStruct)bData;
- (void)messageRecieved:(NSString *)message;
- (IBAction)vibrateButtonPressed:(id)sender;

@end
