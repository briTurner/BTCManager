//
//  BTCSMainVC.m
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCSMainVC.h"
#import "BNRControllerDemoVC.h"
#import "BNRControllerDemoView.h"

@interface BTCSMainVC () {
    NSMutableDictionary *controllers;
    NSMutableArray *controllerViews;
}

- (void)updateConnectionView;

@end

@implementation BTCSMainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        manager = [BTCManager sharedManager];
        [manager configureManagerAsGameWithSessionID:@"btsSessionID" connectionRequestBlock:^(NSString *peerID, NSString *displayName, ResponseBlock respBlock) {
            respBlock(YES);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedToController:) name:BTCManagerNotificationConnectedToController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectedFromController:) name:BTCManagerNotificationDisconnectedFromController object:nil];
        
        [manager registerButtonPressBlock:^(ButtonDataStruct buttonData, PeerData controllerData) {
            BNRControllerDemoVC *controller = [controllers valueForKey:controllerData.ident];
            if (controller)
                [controller buttonPressed:buttonData];
        }];
        
        [manager registerJoystickMovedBlock:^(JoyStickDataStruct joystickData, PeerData controllerData) {
            BNRControllerDemoVC *controller = [controllers valueForKey:controllerData.ident];
            if (controller)
                [controller joyStick:joystickData.joyStickID movedDistance:joystickData.distance angle:joystickData.angle];
        }];
        
        [manager registerArbitraryDataRecievedBlock:^(ArbitraryDataStruct arbitraryData, PeerData controllerData) {
            switch (arbitraryData.dataID) {
                case 1: {
                    NSString *stringRecieved = [[NSString alloc] initWithData:arbitraryData.data encoding:NSUTF8StringEncoding];
                    BNRControllerDemoVC *controller = [controllers valueForKey:controllerData.ident];
                    if (controller) {
                        [controller messageRecieved:stringRecieved];
                    }
                }
                    break;
                default:
                    break;
            }
        }];
        
        
        controllers = [NSMutableDictionary dictionary];
        controllerViews = [NSMutableArray array];
    }
    return self;
}

- (IBAction)beAvailable:(id)sender {
    [manager startSession];
}

- (IBAction)beUnavailable:(id)sender {
    [manager becomeUnavailable];
}

- (IBAction)disconnect:(id)sender {
    [manager disconnect];
}

- (void)updateConnectionView {
    int i = 0;
    for (BNRControllerDemoView *controllerView in controllerViews) {
        [controllerView setFrame:CGRectMake(20 + 340 * i, 40, 320, 480)];
        i++;
    }
}

- (void)connectedToController:(NSNotification *)note {
    NSDictionary *dic = [note userInfo];
    NSString *controllerID = [dic valueForKey:kBTCPeerID];
    NSString *displayName = [dic valueForKey:kBTCPeerDisplayName];
    
    BNRControllerDemoVC *vc = [[BNRControllerDemoVC alloc] initWithControllerID:controllerID displayName:displayName];
    [self addChildViewController:vc];
    [[self view] addSubview:[vc view]];
    [controllerViews addObject:[vc view]];
    
    [controllers setValue:vc forKey:controllerID];
    [self updateConnectionView];
}

- (void)disconnectedFromController:(NSNotification *)note {
    NSDictionary *dic = [note userInfo];
    NSString *controllerID = [dic valueForKey:kBTCPeerID];
    
    BNRControllerDemoVC *controller = [controllers valueForKey:controllerID];
    if (controller) {
        [[controller view] removeFromSuperview];
        [controller removeFromParentViewController];
        [controllerViews removeObject:[controller view]];
        [controllers removeObjectForKey:controllerID];
        [self updateConnectionView];
    }
}


@end
