//
//  BTButton.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/12/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BTCManager;

@interface BTCButton : UIButton

@property (nonatomic, weak) BTCManager *manager;

//Custom constructor method for button
//  tag is a unique id in order to distinguish one button from another
+ (id)buttonWithTag:(int)t manager:(BTCManager *)m frame:(CGRect)f inView:(UIView *)view;
@end
