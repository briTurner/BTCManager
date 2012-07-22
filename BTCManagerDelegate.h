//
//  BTCManagerDelegate.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/22/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BTCManager;

@protocol BTCManagerDelegate <NSObject>
- (void)manager:(BTCManager *)manager connectedToPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager disconnectedFromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;

@end




@protocol BTCManagerClientDelegate <BTCManagerDelegate>
- (void)manager:(BTCManager *)manager serverAvailableForConnection:(NSString *)serverID withDisplayName:(NSString *)dName;

@optional
- (void)manager:(BTCManager *)manager successfullyConnectedToServer:(NSString *)serverID withDisplayName:(NSString *)dName;
- (void)manager:(BTCManager *)manager serverNoLongerAvailableForConnection:(NSString *)serverID withDisplayName:(NSString *)displayName;
@end





@protocol BTCManagerServerDelegate <BTCManagerDelegate>
- (BOOL)manager:(BTCManager *)manager allowConnectionFromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;

@optional
- (void)manager:(BTCManager *)manager connectingToPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager buttonPressedWithTag:(int)buttonTag fromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager joyStickMovedWithTag:(int)joystickTag distance:(float)distance angle:(float)angle fromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;

@end
