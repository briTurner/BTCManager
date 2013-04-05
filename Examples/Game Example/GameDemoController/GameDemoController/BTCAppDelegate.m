//
//  BTCAppDelegate.m
//  GameDemoController
// 
//  Created by Brian Turner on 9/29/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import "BTCAppDelegate.h"
#import "BTCMainViewController.h"
#import "BTCManager.h"

@implementation BTCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    BTCManager *manager = [BTCManager sharedManager];
    [manager configureManagerAsControllerWithSessionID:@"gameDemo" serverAvailableBlock:^(NSString *serverID, NSString *serverDisplayName) {
        NSLog(@"connecting to server %@", serverDisplayName);
        [manager connectToServer:serverID];
    }];
    
    BTCMainViewController *vc = [[BTCMainViewController alloc] initWithNibName:nil bundle:nil];
    [[self window] setRootViewController:vc];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[BTCManager sharedManager] disconnect];
    [[BTCManager sharedManager] becomeUnavailable];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[BTCManager sharedManager] startSession];
}

@end
