//
//  BTCManager.m
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCManager.h"

@interface BTCManager ()

- (void)configureSession;

@end

@implementation BTCManager
@synthesize clientDelegate, serverDelegate;

- (id)initWithSessionID:(NSString *)sID andMode:(GKSessionMode)sMode {
    self = [super init];
    if (self) {
        sessionID = sID;
        sessionMode = sMode;
        [self configureSession];
    }
    return self;
}

- (void)configureSession {
    NSString *displayName = sessionMode == GKSessionModeServer ? @"Server" : @"Client";
    session = [[GKSession alloc] initWithSessionID:sessionID displayName:displayName sessionMode:sessionMode];
    [session setDataReceiveHandler:self withContext:nil];
    [session setDelegate:self];
}

- (void)startSession {
    if (!session)
        [self configureSession];
    [session setAvailable:YES];
}

- (void)stopSession {
    [session disconnectFromAllPeers];
    [session setDataReceiveHandler:nil withContext:nil];
    [session setAvailable:NO];
    session = nil;
}

- (void)connectToServer:(NSString *)serverId {
    [session connectToPeer:serverId withTimeout:20];
}

- (void)session:(GKSession *)s didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    
    NSLog(@"did recieve connection request");
    if ([serverDelegate respondsToSelector:@selector(allowConnectionFromPeerID:)])
        if ([serverDelegate allowConnectionFromPeerID:peerID]) {
            NSError *error = nil;
            if (![s acceptConnectionFromPeer:peerID error:&error]) {
                NSLog(@"failed to accept connection %@", [error localizedDescription]);
            }
        } else {
            [s denyConnectionFromPeer:peerID];
        }
}

- (void)session:(GKSession *)s peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"available");
            if (sessionMode == GKSessionModeClient) {
                if ([clientDelegate respondsToSelector:@selector(serverAvailableForConnection:withDisplayName:)])
                    [clientDelegate serverAvailableForConnection:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateConnecting:
            NSLog(@"connecting");
            break;
        case GKPeerStateConnected:
            NSLog(@"connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            break;
        case GKPeerStateUnavailable:
            NSLog(@"unavailable");
            if (sessionMode == GKSessionModeClient) {
                if ([clientDelegate respondsToSelector:@selector(serverNoLongerAvailableForConnection:withDisplayName:)])
                    [clientDelegate serverNoLongerAvailableForConnection:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        default:
            break;
    }
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSLog(@"data recieved");
}


@end
