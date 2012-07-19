//
//  BTCJoyStickVC.h
//  BTJoyStickTester
//
//  Created by Brian Turner on 7/14/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BTJoyStickView;
@class BTCManager;

@interface BTCJoyStickVC : UIViewController {
    UIView *selectedView;
    
    BTJoyStickView *joyStickView;

    
    CGPoint joyStickOrigin;
}
@property (nonatomic, weak) BTCManager *manager;
@end
