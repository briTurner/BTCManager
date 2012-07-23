//
//  BTCManager.m
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCManager.h"
#import "BTCButton.h"
#import "BTCJoyStickController.h"
#import "BTCManagerDelegate.h"
#import <GameKit/GameKit.h>

@interface BTCManager () {
    GKSession *_session;
    
    NSString *_conectingServerID;
    NSString *_connectedServerID;
    
    NSMutableArray *_joyStickTags;
    NSMutableArray *_buttonTags;
}
- (void)configureSession;

@end

@implementation BTCManager
@synthesize sessionID;
@synthesize sessionMode;
@synthesize clientDelegate, serverDelegate;
@synthesize displayName;


#pragma mark - Manager config stuff
+ (id)sharedManager {
    static BTCManager *manager = nil;
    if (!manager) {
        manager = [[super allocWithZone:nil] init];
    }
    return manager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedManager];
}

- (void)configureSession {
    if (sessionID) {
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:[self displayName] sessionMode:sessionMode];
        [_session setDataReceiveHandler:self withContext:nil];
        [_session setDelegate:self];
    } else
        NSLog(@"Make sure you set session id and session mode before trying to use manager");
}

- (void)startSession {
    if (!_session)
        [self configureSession];
    [_session setAvailable:YES];
}

- (void)disconnect {
    [_session disconnectFromAllPeers];
}

- (void)becomeUnavailable {
    [_session setAvailable:NO];
}

- (void)connectToServer:(NSString *)serverId {
    [_session connectToPeer:serverId withTimeout:20];
    _conectingServerID = serverId;
}

#pragma mark - UI elements
- (void)registerButtonWithManager:(BTCButton *)button {
    if ([button tag] != NSNotFound && ![_buttonTags containsObject:[NSNumber numberWithInt:[button tag]]]) {
        [button setManager:self];
        [_buttonTags addObject:[NSNumber numberWithInt:[button tag]]];
    } else 
        NSLog(@"The BTButton could not be registered with the manager because the tag is either invalid, or already in use");
}

- (void)registerJoystickWithManager:(BTCJoyStickController *)js {
    if ([[js view] tag] != NSNotFound && ![_joyStickTags containsObject:[NSNumber numberWithInt:[[js view] tag]]]) {
        [js setManager:self];
        [_joyStickTags addObject:[NSNumber numberWithInt:[[js view] tag]]];
    } else
        NSLog(@"The BTCJoyStick could not be registered with the manager becuase the tag is either invalid, or already in use");
}



- (void)session:(GKSession *)s didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSLog(@"Did recieve connection request from %@", [s displayNameForPeer:peerID]);
    if ([serverDelegate respondsToSelector:@selector(manager:allowConnectionFromPeer:withDisplayName:)]) {
        if ([serverDelegate manager:self allowConnectionFromPeer:peerID withDisplayName:[s displayNameForPeer:peerID]]) {
            NSError *error = nil;
            if (![s acceptConnectionFromPeer:peerID error:&error]) {
                NSLog(@"failed to accept connection %@", [error localizedDescription]);
            } 
        } else {
            [s denyConnectionFromPeer:peerID];
        }
    }
}

- (void)session:(GKSession *)s peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"%@ available", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeClient) {
                if ([clientDelegate respondsToSelector:@selector(manager:serverAvailableForConnection:withDisplayName:)])
                    [clientDelegate manager:self serverAvailableForConnection:peerID withDisplayName:[s displayNameForPeer:peerID]];
            } 
            break;
        case GKPeerStateConnecting:
            NSLog(@"%@ connecting", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeClient) {
                if ([clientDelegate respondsToSelector:@selector(manager:connectingToPeer:withDisplayName:)])
                    [clientDelegate manager:self connectingToPeer:peerID withDisplayName:[s displayNameForPeer:peerID]];
            } else {
                if ([serverDelegate respondsToSelector:@selector(manager:connectingToPeer:withDisplayName:)])
                    [serverDelegate manager:self connectingToPeer:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateConnected:
            NSLog(@"%@ connected", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeClient) {
                if ([peerID isEqualToString:_conectingServerID]) {
                    _connectedServerID = _conectingServerID;
                    _conectingServerID = nil;
                    if ([clientDelegate respondsToSelector:@selector(manager:connectedToServer:withDisplayName:)])
                        [clientDelegate manager:self connectedToServer:peerID withDisplayName:[s displayNameForPeer:peerID]];
                } else {
                    if ([clientDelegate respondsToSelector:@selector(manager:connectedToPeer:withDisplayName:)])
                        [clientDelegate manager:self connectedToPeer:peerID withDisplayName:[s displayNameForPeer:peerID]];
                }
            } else {
                if ([serverDelegate respondsToSelector:@selector(manager:connectedToPeer:withDisplayName:)])
                    [serverDelegate manager:self connectedToPeer:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateDisconnected:
            NSLog(@"%@ disconnected", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeClient) {
                if ([peerID isEqualToString:_conectingServerID]) {
                    _connectedServerID = nil;
                    if ([clientDelegate respondsToSelector:@selector(manager:disconnectedFromServer:withDisplayName:)])
                        [clientDelegate manager:self disconnectedFromServer:peerID withDisplayName:[s displayNameForPeer:peerID]];
                }
                if ([clientDelegate respondsToSelector:@selector(manager:disconnectedFromPeer:withDisplayName:)])
                    [clientDelegate manager:self disconnectedFromPeer:peerID withDisplayName:[s displayNameForPeer:peerID]];
            } else {
                if ([serverDelegate respondsToSelector:@selector(manager:disconnectedFromPeer:withDisplayName:)])
                    [serverDelegate manager:self disconnectedFromPeer:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateUnavailable:
            NSLog(@"%@ unavailable", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeClient) {
                if ([clientDelegate respondsToSelector:@selector(manager:serverNoLongerAvailableForConnection:withDisplayName:)])
                    [clientDelegate manager:self serverNoLongerAvailableForConnection:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        default:
            break;
    }
}


- (void)sendNetworkPacketWithID:(DataPacketType)packetID withData:(void *)data ofLength:(size_t)length reliable:(BOOL)howtosend toPeers:(NSArray *)peers {
    unsigned char networkPacket[1024];
    unsigned int headerPacketSize = (sizeof(int)); 
    networkPacket[0]=packetID;
    
    memcpy(&networkPacket[headerPacketSize], data, length);
    
    if (!peers)
        peers = [NSArray arrayWithObject:_connectedServerID];
    
    NSData *packet = [NSData dataWithBytes:networkPacket length:(length+headerPacketSize)];
    if (howtosend == YES) {
        if (![_session sendData:packet toPeers:peers withDataMode:GKSendDataReliable error:nil]) {
            NSLog(@"failed to send data reliably");
        }
    }
    else if (howtosend == NO) {
        if (![_session sendData:packet toPeers:peers withDataMode:GKSendDataUnreliable error:nil]) {
            NSLog(@"failed to send data unreliably");
        }
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession: (GKSession *)s context:(void *)context {
    char * bytes = (char *)[data bytes];
    DataPacketType dataPacketType = (DataPacketType)bytes[0];
    
    
    switch (dataPacketType) {
        case dataPacketTypeButton: {
            int buttonTag = bytes[sizeof(DataPacketType)];
            if ([serverDelegate respondsToSelector:@selector(manager:buttonPressedWithTag:fromPeer:withDisplayName:)]) 
                [serverDelegate manager:self buttonPressedWithTag:buttonTag fromPeer:peerID withDisplayName:[s displayNameForPeer:peerID]];
            break;
        }
        case dataPacketTypeJoyStick: {
            JoyStickDataStruct joyStickData;
            memmove(&joyStickData, bytes + sizeof(dataPacketType), sizeof(JoyStickDataStruct));
            int joyStickTag = joyStickData.joyStickID;
            float angle = joyStickData.angle;
            float distance = joyStickData.distance;  
            
            if ([serverDelegate respondsToSelector:@selector(manager:joyStickMovedWithTag:distance:angle:fromPeer:withDisplayName:)]) 
                [serverDelegate manager:self joyStickMovedWithTag:joyStickTag distance:distance angle:angle fromPeer:peerID withDisplayName:[s displayNameForPeer:peerID]];
        }
        default:
            break;
    }
}


@end
