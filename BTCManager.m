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
    session = [[GKSession alloc] initWithSessionID:sessionID displayName:@"Server" sessionMode:sessionMode];
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

- (void)session:(GKSession *)s didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    
    if ([delegate respondsToSelector:@selector(allowConnectionFromPeerID:)])
        if ([delegate allowConnectionFromPeerID:peerID])
            [s connectToPeer:peerID withTimeout:20];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"available");
            if (sessionMode == GKSessionModeClient)
                [session connectToPeer:peerID withTimeout:20];
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
            break;
        default:
            break;
    }
    
}

@end
