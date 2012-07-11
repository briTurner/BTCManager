//
//  BTCManager.h
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol BTCManagerDelegate <NSObject>


@optional
- (BOOL)allowConnectionFromPeerID:(NSString *)peer;

@end

@interface BTCManager : NSObject <GKSessionDelegate> {
    GKSession *session;
    NSString *sessionID;
    GKSessionMode sessionMode;
    id <BTCManagerDelegate> delegate;
}
@property (nonatomic, weak) id <BTCManagerDelegate> delegate;

- (id)initWithSessionID:(NSString *)sID andMode:(GKSessionMode)sMode;

- (void)startSession;
- (void)stopSession;
@end
