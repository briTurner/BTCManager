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
+ (id)joyStickWithTag:(int)tag andManager:(BTCManager *)m andFrame:(CGRect)f inView:(UIView *)v;

- (void)joyStickPositionUpdated:(JoyStickDataStruct)jsData;
@end
