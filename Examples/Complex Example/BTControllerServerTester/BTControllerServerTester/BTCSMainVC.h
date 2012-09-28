//
//  BTCSMainVC.h
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCManager.h"

@interface BTCSMainVC : UIViewController {
    BTCManager *manager;
}
- (IBAction)beAvailable:(id)sender;
- (IBAction)beUnavailable:(id)sender;
- (IBAction)disconnect:(id)sender;

@end
