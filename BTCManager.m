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
#import <AudioToolbox/AudioToolbox.h>

@interface BTCManager () {
    GKSession *_session;
    
    NSString *_conectingServerID;
    NSString *_connectedServerID;
    
    NSMutableArray *_joyStickTags;
    NSMutableArray *_buttonTags;
    
    NSMutableArray *_buttonPressBlocks;
    NSMutableArray *_joystickMoveBlocks;
    NSMutableArray *_arbitraryDataBlocks;
}
- (void)configureSession;

@end

@implementation BTCManager
@synthesize sessionID;
@synthesize sessionMode;
@synthesize controllerDelegate, gameDelegate;
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

- (id)init {
    self = [super init];
    if (self) {
        _buttonTags = [NSMutableArray array];
        _joyStickTags = [NSMutableArray array];
    }
    return self;
}

- (void)configureSession {
    if (sessionID) {
        GKSessionMode sesMode = sessionMode == BTCConnectionTypeController ? GKSessionModeClient : GKSessionModeServer;
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:[self displayName] sessionMode:sesMode];
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

- (void)sendArbitraryData:(NSData *)data withIdentifier:(int)identifier reliably:(BOOL)reliable toPeers:(NSArray *)peers {
    unsigned char completeArbitraryData[1024];
    unsigned int headerPacketSize = (sizeof(int));
    completeArbitraryData[0]=identifier;
    
    const void * dataBytes = [data bytes];
    
    memcpy(&completeArbitraryData[headerPacketSize], dataBytes, [data length]);
    
    [self sendNetworkPacketWithID:dataPacketTypeArbitrary withData:&completeArbitraryData ofLength:[data length] + headerPacketSize reliable:reliable toPeers:nil];
}

- (void)vibrateControllers:(NSArray *)peers {
    [self sendNetworkPacketWithID:dataPacketTypeVibration withData:NULL ofLength:0 reliable:YES toPeers:peers];
}

#pragma mark - UI elements
- (BOOL)registerButtonWithManager:(BTCButton *)button {
    if ([button tag] != NSNotFound && ![_buttonTags containsObject:[NSNumber numberWithInt:[button tag]]]) {
        [button setManager:self];
        [_buttonTags addObject:[NSNumber numberWithInt:[button tag]]];
        return YES;
    } else {
        NSLog(@"The BTButton could not be registered with the manager because the tag is either invalid, or already in use");
        NSLog(@"button tag is %i and is already contained in the array %@", [button tag], _buttonTags);
        return NO;
    }
}

- (void)unregisterButtonWithmanager:(BTCButton *)button {
    if ([_buttonTags containsObject:[NSNumber numberWithInt:[button tag]]])
        [_buttonTags removeObject:[NSNumber numberWithInt:[button tag]]];
    else
        NSLog(@"There are no buttons registered with that Tag");
}

- (BOOL)registerJoystickWithManager:(BTCJoyStickController *)js {
    if ([[js view] tag] != NSNotFound && ![_joyStickTags containsObject:[NSNumber numberWithInt:[[js view] tag]]]) {
        [js setManager:self];
        [_joyStickTags addObject:[NSNumber numberWithInt:[[js view] tag]]];
        return YES;
    } else {
        NSLog(@"The BTCJoyStick could not be registered with the manager becuase the tag is either invalid, or already in use");
        return NO;
    }
}

- (void)unregisterJoystickWithManager:(BTCJoyStickController *)joystick {
    if ([_joyStickTags containsObject:[NSNumber numberWithInt:[[joystick view] tag]]])
        [_joyStickTags removeObject:[NSNumber numberWithInt:[[joystick view] tag]]];
    else
        NSLog(@"There are no buttons registered with that Tag");
}

- (void)registerButtonPressBlock:(void(^)(ButtonDataStruct buttonData, PeerData controllerData))buttonBlock {
    if (!_buttonPressBlocks)
        _buttonPressBlocks = [NSMutableArray array];
    if (![_buttonPressBlocks containsObject:buttonBlock])
        [_buttonPressBlocks addObject:buttonBlock];
}

- (void)registerJoystickMovedBlock:(void(^)(JoyStickDataStruct joystickData, PeerData controllerData))joystickBlock {
    if (!_joystickMoveBlocks)
        _joystickMoveBlocks = [NSMutableArray array];
    if (![_joystickMoveBlocks containsObject:joystickBlock])
        [_joystickMoveBlocks addObject:joystickBlock];
}

- (void)registerArbitraryDataRecievedBlock:(void(^)(ArbitraryDataStruct arbitraryData, PeerData controllerData))arbitraryDataBlock {
    if (!_arbitraryDataBlocks)
        _arbitraryDataBlocks = [NSMutableArray array];
    if (![_arbitraryDataBlocks containsObject:arbitraryDataBlock])
        [_arbitraryDataBlocks addObject:arbitraryDataBlock];
}

- (void)session:(GKSession *)s didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSLog(@"Did recieve connection request from %@", [s displayNameForPeer:peerID]);
    [gameDelegate manager:self allowConnectionFromPeer:peerID withDisplayName:[s displayNameForPeer:peerID] response:^(BOOL response) {
        if (response) {
            NSError *error = nil;
            if (![s acceptConnectionFromPeer:peerID error:&error]) {
                NSLog(@"failed to accept connection %@", [error localizedDescription]);
            }
        } else {
            [s denyConnectionFromPeer:peerID];
        }
    }];
}

- (void)session:(GKSession *)s peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"%@ available", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                if ([controllerDelegate respondsToSelector:@selector(manager:serverAvailableForConnection:withDisplayName:)])
                    [controllerDelegate manager:self serverAvailableForConnection:peerID withDisplayName:[s displayNameForPeer:peerID]];
            } else {
                if ([gameDelegate respondsToSelector:@selector(manager:controllerAvailableForConnection:withDisplayName:)])
                    [gameDelegate manager:self controllerAvailableForConnection:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateConnecting:
            NSLog(@"%@ connecting", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                if ([controllerDelegate respondsToSelector:@selector(manager:connectingToServer:withDisplayName:)])
                    [controllerDelegate manager:self connectingToServer:peerID withDisplayName:[s displayNameForPeer:peerID]];
            } else {
                if ([gameDelegate respondsToSelector:@selector(manager:connectingToController:withDisplayName:)])
                    [gameDelegate manager:self connectingToController:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateConnected:
            NSLog(@"%@ connected", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                if ([peerID isEqualToString:_conectingServerID]) {
                    _connectedServerID = _conectingServerID;
                    _conectingServerID = nil;
                    if ([controllerDelegate respondsToSelector:@selector(manager:connectedToServer:withDisplayName:)])
                        [controllerDelegate manager:self connectedToServer:peerID withDisplayName:[s displayNameForPeer:peerID]];
                } else {
                    if ([controllerDelegate respondsToSelector:@selector(manager:peerControllerConnected:withDisplayName:)])
                        [controllerDelegate manager:self peerControllerConnected:peerID withDisplayName:[s displayNameForPeer:peerID]];
                }
            } else {
                if ([gameDelegate respondsToSelector:@selector(manager:connectedToController:withDisplayName:)])
                    [gameDelegate manager:self connectedToController:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateDisconnected:
            NSLog(@"%@ disconnected", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                if ([peerID isEqualToString:_conectingServerID]) {
                    _connectedServerID = nil;
                    if ([controllerDelegate respondsToSelector:@selector(manager:disconnectedFromServer:withDisplayName:)])
                        [controllerDelegate manager:self disconnectedFromServer:peerID withDisplayName:[s displayNameForPeer:peerID]];
                } else
                    if ([controllerDelegate respondsToSelector:@selector(manager:peerControllerDisconnected:withDisplayName:)])
                        [controllerDelegate manager:self peerControllerDisconnected:peerID withDisplayName:[s displayNameForPeer:peerID]];
            } else {
                if ([gameDelegate respondsToSelector:@selector(manager:disconnectedFromController:withDisplayName:)])
                    [gameDelegate manager:self disconnectedFromController:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        case GKPeerStateUnavailable:
            NSLog(@"%@ unavailable", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                if ([controllerDelegate respondsToSelector:@selector(manager:serverNoLongerAvailable:withDisplayName:)])
                    [controllerDelegate manager:self serverNoLongerAvailable:peerID withDisplayName:[s displayNameForPeer:peerID]];
            } else {
                if ([gameDelegate respondsToSelector:@selector(manager:controllerNoLongerAvailable:withDisplayName:)])
                    [gameDelegate manager:self controllerNoLongerAvailable:peerID withDisplayName:[s displayNameForPeer:peerID]];
            }
            break;
        default:
            break;
    }
}


- (void)sendNetworkPacketWithID:(DataPacketType)packetID withData:(void *)data ofLength:(size_t)length reliable:(BOOL)howtosend toPeers:(NSArray *)peers {
    
    if (!peers && _connectedServerID)
        peers = [NSArray arrayWithObject:_connectedServerID];
    
    unsigned char networkPacket[1024];
    unsigned int headerPacketSize = (sizeof(int));
    networkPacket[0]=packetID;
    
    memcpy(&networkPacket[headerPacketSize], data, length);
    
    if (peers) {
        
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
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession: (GKSession *)s context:(void *)context {
    char * bytes = (char *)[data bytes];
    DataPacketType dataPacketType = (DataPacketType)bytes[0];
    
    
    switch (dataPacketType) {
        case dataPacketTypeButton: {
            ButtonDataStruct buttonData;
            PeerData peer;
            peer.ident = peerID;
            peer.displayName = [s displayNameForPeer:peerID];
            memmove(&buttonData, bytes + sizeof(dataPacketType), sizeof(ButtonDataStruct));
            for (void(^buttonBlock)(ButtonDataStruct data, PeerData controllerData) in _buttonPressBlocks) {
                buttonBlock(buttonData, peer);
            }
            break;
        }
        case dataPacketTypeJoyStick: {
            JoyStickDataStruct joyStickData;
            PeerData peer;
            peer.ident = peerID;
            peer.displayName = [s displayNameForPeer:peerID];
            memmove(&joyStickData, bytes + sizeof(dataPacketType), sizeof(JoyStickDataStruct));
            for (void(^joystickBlock)(JoyStickDataStruct data, PeerData controllerData) in _joystickMoveBlocks) {
                joystickBlock(joyStickData, peer);
            }
            break;
        }
        case dataPacketTypeVibration: {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        }
        case dataPacketTypeArbitrary: {
            int dataType = bytes[sizeof(DataPacketType)];
            
            void * adddressToStartReading = bytes + sizeof(DataPacketType) + sizeof(dataType);
            unsigned long sizeOfArbitraryData = [data length] - (sizeof(dataPacketType) + sizeof(dataType));            
            char movedBytes[sizeOfArbitraryData];
            
            memmove(&movedBytes, adddressToStartReading, sizeOfArbitraryData);
            NSData *arbitraryD = [NSData dataWithBytes:movedBytes length:sizeof(movedBytes)];
            
            ArbitraryDataStruct arbitraryData;
            arbitraryData.data = arbitraryD;
            arbitraryData.dataID = dataType;
            
            PeerData peerData;
            peerData.ident = peerID;
            peerData.displayName = [s displayNameForPeer:peerID];
            
            for (void(^arbiraryDataBlock)(ArbitraryDataStruct dataStruct, PeerData peerData) in _arbitraryDataBlocks) {
                arbiraryDataBlock(arbitraryData, peerData);
            }   
        }
        default:
            break;
    }
}


@end
