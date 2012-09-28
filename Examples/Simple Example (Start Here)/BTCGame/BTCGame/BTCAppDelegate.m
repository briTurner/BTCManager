//
//  BTCAppDelegate.m
//  BTCGame
//
//  Created by Brian Turner on 9/27/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import "BTCAppDelegate.h"
#import "BTCMainViewController.h"

@implementation BTCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    BTCMainViewController *vc = [[BTCMainViewController alloc] initWithNibName:nil bundle:nil];
    [[self window] setRootViewController:vc];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
