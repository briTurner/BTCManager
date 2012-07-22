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
+ (id)buttonWithTag:(int)t andManager:(BTCManager *)m andFrame:(CGRect)f inView:(UIView *)view;
- (void)emptyAction;
@end
