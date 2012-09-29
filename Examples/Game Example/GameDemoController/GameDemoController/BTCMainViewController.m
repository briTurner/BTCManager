//
//  BTCMainViewController.m
//  GameDemoController
//
//  Created by Brian Turner on 9/29/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import "BTCMainViewController.h"
#import "BTCManager.h"

@interface BTCMainViewController ()

@end

@implementation BTCMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        BTCManager *manager = [BTCManager sharedManager];
        [manager configureManagerAsControllerWithSessionID:@"gameDemo" serverAvailableBlock:^(NSString *serverID, NSString *serverDisplayName) {
            [manager connectToServer:serverID];
        }];
        [manager startSession];
    }
    return self;
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    [[BTCManager sharedManager] disconnect];
//}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [[BTCManager sharedManager] startSession];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
