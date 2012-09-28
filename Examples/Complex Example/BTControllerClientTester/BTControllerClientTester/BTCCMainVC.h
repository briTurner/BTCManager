//
//  BTCCMainVC.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCManager.h"

@class BTCServer;

@interface BTCCMainVC : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    BTCManager *manager;
    BTCServer *connectedServer;
    __weak IBOutlet UITextField *displayNameTF;
    
    UIAlertView *serverAlertView;
    
    NSMutableArray *servers;
    __weak IBOutlet UITableView *tableView;
}

- (IBAction)connect:(id)sender;

@end
