//
//  BTJoyStickPadView.h
//  BTJoyStick
//
//  Created by Brian Turner on 1/28/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCConstants.h"

// DO NOT DO ANYTHING WITH THIS CLASS DIRECTLY
// THIS IS ONLY A HELPER CLASS FOR BTCJoystickController

@class BTCJoyStickController;

@interface BTCJoyStickPadView : UIView {
    
}
@property (nonatomic, weak) BTCJoyStickController *controller;


@end
