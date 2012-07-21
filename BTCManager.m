//
//  BTCManager.m
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCManager.h"
#import "BTButton.h"
#import "BTCJoyStickController.h"

@interface BTCManager ()

@end

@implementation BTCManager
@synthesize sessionID;
@synthesize sessionMode;
@synthesize clientDelegate, serverDelegate;

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
        NSString *displayName = sessionMode == GKSessionModeServer ? @"Server" : @"Client";
        session = [[GKSession alloc] initWithSessionID:sessionID displayName:displayName sessionMode:sessionMode];
        [session setDataReceiveHandler:self withContext:nil];
        [session setDelegate:self];
    } else {
        NSLog(@"Make sure you set session id and session mode before trying to use manager");
    }
}

- (void)startSession {
    if (!session)
        [self configureSession];
    [session setAvailable:YES];
}

- (void)disconnect {
    [session disconnectFromAllPeers];
}

- (void)becomeUavailable {
    [session setAvailable:NO];
}

- (void)connectToServer:(NSString *)serverId {
    [session connectToPeer:serverId withTimeout:20];
}

- (void)registerButtonWithManager:(BTButton *)button {
    if ([button tag] != NSNotFound && ![buttonTags containsObject:[NSNumber numberWithInt:[button tag]]]) {
        [button setManager:self];
        [buttonTags addObject:[NSNumber numberWithInt:[button tag]]];
    } else 
        NSLog(@"The BTButton could not be registered with the manager because the tag is either invalid, or already in use");
}

- (void)registerJoystickWithManager:(BTCJoyStickController *)js {
    if ([[js view] tag] != NSNotFound && ![joyStickTags containsObject:[NSNumber numberWithInt:[[js view] tag]]]) {
        [js setManager:self];
        [joyStickTags addObject:[NSNumber numberWithInt:[[js view] tag]]];
    } else
        NSLog(@"The BTCJoyStick could not be registered with the manager becuase the tag is either invalid, or already in use");
}

- (void)session:(GKSession *)s didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSLog(@"Did recieve connection request");
    if ([serverDelegate respondsToSelector:@selector(allowConnectionFromPeerID:withDisplayName:)]) {
        if ([serverDelegate allowConnectionFromPeerID:peerID withDisplayName:[s displayNameForPeer:peerID]]) {
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
                if ([clientDelegate respondsToSelector:@selector(serverAvailableForConnection:withDisplayName:)])
                    [clientDelegate serverAvailableForConnection:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateConnecting:
            NSLog(@"%@ connecting", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeServer) {
                if ([serverDelegate respondsToSelector:@selector(peerConnecting:withDisplayName:)])
                    [serverDelegate peerConnecting:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateConnected:
            NSLog(@"%@ connected", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeClient) {
                [clientDelegate peerConnected:peerID withDisplayName:[s displayNameForPeer:peerID]];                
                connectedServerID = peerID;
            } else 
                [serverDelegate peerConnected:peerID withDisplayName:[s displayNameForPeer:peerID]];
            break;
        case GKPeerStateDisconnected:
            NSLog(@"%@ disconnected", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeClient) {
                [clientDelegate peerDisconnected:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateUnavailable:
            NSLog(@"%@ unavailable", [s displayNameForPeer:peerID]);
            if (sessionMode == GKSessionModeClient) {
                if ([clientDelegate respondsToSelector:@selector(serverNoLongerAvailableForConnection:withDisplayName:)])
                    [clientDelegate serverNoLongerAvailableForConnection:peerID withDisplayName:[s displayNameForPeer:peerID]];
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
        peers = [NSArray arrayWithObject:connectedServerID];
    
    NSData *packet = [NSData dataWithBytes:networkPacket length:(length+headerPacketSize)];
    if (howtosend == YES) {
        if (![session sendData:packet toPeers:peers withDataMode:GKSendDataReliable error:nil]) {
            NSLog(@"failed to send data reliably");
        }
    }
    else if (howtosend == NO) {
        if (![session sendData:packet toPeers:peers withDataMode:GKSendDataUnreliable error:nil]) {
            NSLog(@"failed to send data unreliably");
        }
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)s context:(void *)context {
    char * bytes = (char *)[data bytes];
    DataPacketType dataPacketType = (DataPacketType)bytes[0];
    
    
    switch (dataPacketType) {
        case dataPacketTypeButton: {
            int buttonTag = bytes[sizeof(DataPacketType)];
            if ([serverDelegate respondsToSelector:@selector(buttonPressedWithTag:fromPeer:withDisplayName:)]) 
                [serverDelegate buttonPressedWithTag:buttonTag fromPeer:peer withDisplayName:[s displayNameForPeer:peer]];
            break;
        }
        case dataPacketTypeJoyStick: {
            JoyStickDataStruct joyStickData;
            memmove(&joyStickData, bytes + sizeof(dataPacketType), sizeof(JoyStickDataStruct));
            int joyStickTag = joyStickData.joyStickID;
            float angle = joyStickData.angle;
            float distance = joyStickData.distance;  
            
            if ([serverDelegate respondsToSelector:@selector(joyStickMovedWithTag:distance:angle:fromPeer:withDisplayName:)]) 
                [serverDelegate joyStickMovedWithTag:joyStickTag distance:distance angle:angle fromPeer:peer withDisplayName:[s displayNameForPeer:peer]];
        }
        default:
            break;
    }
}


@end
