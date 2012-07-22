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

@class BTCButton;
@class BTCJoyStickController;

@protocol BTCManagerClientDelegate;
@protocol BTCManagerServerDelegate;


typedef enum {
    dataPacketTypeButton,
    dataPacketTypeJoyStick,
}DataPacketType;

@interface BTCManager : NSObject <GKSessionDelegate> {

}
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic) GKSessionMode sessionMode;
@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, weak) id <BTCManagerClientDelegate> clientDelegate;
@property (nonatomic, weak) id <BTCManagerServerDelegate> serverDelegate;
+ (id)sharedManager;

- (void)startSession;
- (void)disconnect;
- (void)becomeUnavailable;

- (void)connectToServer:(NSString *)serverId;

- (void)registerButtonWithManager:(BTCButton *)button;
- (void)registerJoystickWithManager:(BTCJoyStickController *)js;

- (void)sendNetworkPacketWithID:(DataPacketType)packetID withData:(void *)data ofLength:(size_t)length reliable:(BOOL)howtosend toPeers:(NSArray *)peers;
@end
