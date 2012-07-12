//
//  BTCManager.h
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol BTCManagerClientDelegate <NSObject>

- (void)serverAvailableForConnection:(NSString *)sID withDisplayName:(NSString *)displayName;
- (void)serverNoLongerAvailableForConnection:(NSString *)sID withDisplayName:(NSString *)displayName;


@end

@protocol BTCManagerServerDelegate <NSObject>

- (BOOL)allowConnectionFromPeerID:(NSString *)peer;

@end

@interface BTCManager : NSObject <GKSessionDelegate> {
    GKSession *session;
    NSString *sessionID;
    GKSessionMode sessionMode;
}
@property (nonatomic, weak) id <BTCManagerClientDelegate> clientDelegate;
@property (nonatomic, weak) id <BTCManagerServerDelegate> serverDelegate;

- (id)initWithSessionID:(NSString *)sID andMode:(GKSessionMode)sMode;

- (void)startSession;
- (void)stopSession;


- (void)connectToServer:(NSString *)serverId;
@end
