//
//  BTCManagerDelegate.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/22/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BTCManagerDelegate <NSObject>

- (void)peerConnected:(NSString *)peerID withDisplayName:(NSString *)displayName;
- (void)peerDisconnected:(NSString *)sID withDisplayName:(NSString *)displayName;

@end

@protocol BTCManagerClientDelegate <BTCManagerDelegate>

- (void)serverAvailableForConnection:(NSString *)sID withDisplayName:(NSString *)dName;
- (void)successfullyConnectedToServer:(NSString *)sID withDisplayName:(NSString *)dName;

@optional

- (void)serverNoLongerAvailableForConnection:(NSString *)sID withDisplayName:(NSString *)displayName;

@end

@protocol BTCManagerServerDelegate <BTCManagerDelegate>

- (BOOL)allowConnectionFromPeerID:(NSString *)peerID withDisplayName:(NSString *)displayName;

@optional
- (void)peerConnecting:(NSString *)peerID withDisplayName:(NSString *)displayName;

- (void)buttonPressedWithTag:(int)buttonTag fromPeer:(NSString *)peer withDisplayName:(NSString *)displayName;
- (void)joyStickMovedWithTag:(int)joystickTag distance:(float)d angle:(float)a fromPeer:(NSString *)peer withDisplayName:(NSString *)displayName;

@end
