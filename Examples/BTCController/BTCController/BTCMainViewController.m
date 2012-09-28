//
//  BTCMainViewController.m
//  BTCController
//
//  Created by Brian Turner on 9/27/12.
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
        [manager configureManagerAsControllerWithSessionID:@"btcDemoID" serverAvailableBlock:^(NSString *serverID, NSString *serverDisplayName) {
            //this block of code will execute when a server is found which is accepting connections
            //at the very least, you should connect to it. but more than likely, you should
            //present the user with a list of available servers and wait for their confirmation
            
            
            //this is how you connect to a server
            [manager connectToServer:serverID];
        }];
        
        [manager startSession];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //we will create one button and one joystick in code, and then one button and joystick in IB
    //be sure to check the xib to see how to configure the controls in IB
    
    
    //you need to be sure that both the joystick and the button have a tag set
    //this tag needs to be different than that of any other control of the same type
    
    BTCButton *button = [[BTCButton alloc] initWithFrame:CGRectMake(5, 5, 100, 44)];
    [button setTitle:@"Button a" forState:UIControlStateNormal];
    [button setTag:111];
    [[self view] addSubview:button];
    
    [button setBackgroundColor:[UIColor purpleColor]];
    
    BTCJoyStickView *joystick = [[BTCJoyStickView alloc] initWithFrame:CGRectMake(5, 60, 150, 150)];
    [joystick setTag:111];
    [[self view] addSubview:joystick];
}


@end
