//
//  BTCCConnectedVC.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/12/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCManager.h"

@interface BTCCConnectedVC : UIViewController {
    BTCManager *manager;
}
@property (nonatomic, strong) NSString *connectedServer;

@end
