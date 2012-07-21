//
//  BTCManager.h
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "BTCConstants.h"

@class BTButton;
@class BTCJoyStickController;

@protocol BTCManagerDelegate <NSObject>

- (void)peerConnected:(NSString *)peerID withDisplayName:(NSString *)displayName;
- (void)peerDisconnected:(NSString *)sID withDisplayName:(NSString *)displayName;

@end

@protocol BTCManagerClientDelegate <BTCManagerDelegate>

- (void)serverAvailableForConnection:(NSString *)sID withDisplayName:(NSString *)displayName;

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

typedef enum {
    dataPacketTypeButton,
    dataPacketTypeJoyStick,
}DataPacketType;



@interface BTCManager : NSObject <GKSessionDelegate> {
    
    GKSession *session;
    
    NSString *connectedServerID;

    NSMutableArray *joyStickTags;
    NSMutableArray *buttonTags;
}
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic) GKSessionMode sessionMode;

@property (nonatomic, weak) id <BTCManagerClientDelegate> clientDelegate;
@property (nonatomic, weak) id <BTCManagerServerDelegate> serverDelegate;
+ (id)sharedManager;

- (void)configureSession;

- (void)startSession;
- (void)disconnect;
- (void)becomeUavailable;

- (void)connectToServer:(NSString *)serverId;

- (void)registerButtonWithManager:(BTButton *)button;
- (void)registerJoystickWithManager:(BTCJoyStickController *)js;

- (void)sendNetworkPacketWithID:(DataPacketType)packetID withData:(void *)data ofLength:(size_t)length reliable:(BOOL)howtosend toPeers:(NSArray *)peers;
@end
