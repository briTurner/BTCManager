//
//  BTCGameViewController.h
//  GameDemo
//
//  Created by Brian Turner on 9/28/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCJoyStickView.h"

@interface BTCGameViewController : UIViewController <UIAccelerometerDelegate, BTCJoyStickViewDelegate> {
    __weak IBOutlet BTCJoyStickView *joystick;
    
}
- (IBAction)jump:(id)sender;

@end
