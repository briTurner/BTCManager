//
//  BTCJoyStickVC.h
//  BTJoyStickTester
//
//  Created by Brian Turner on 7/14/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCConstants.h"

@class BTCJoyStickView;
@class BTCManager;


@interface BTCJoyStickController : UIViewController {
    
}
@property (nonatomic, weak) BTCManager *manager;

//Returns a configured BTCJoyStick
//  set tag in order to distinguish between multiple joysticks
//  set manager to handle transfering data to game
//  frame and view will determine position and size of joystick and the view it appears in
+ (id)joyStickWithTag:(int)tag manager:(BTCManager *)m frame:(CGRect)f inView:(UIView *)v;

- (void)joyStickPositionUpdated:(JoyStickDataStruct)jsData;
@end
