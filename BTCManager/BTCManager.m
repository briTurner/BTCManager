//
//  BTCManager.m
//  BTControllerServerTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCManager.h"
#import "BTCButton.h"
#import "BTCJoyStickView.h"
#import <GameKit/GameKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BTCManager () {
    NSString *sessionID;
    BTCConnectionType sessionMode;
    
    GKSession *_session;
    
    NSString *_conectingServerID;
    NSString *_connectedServerID;
    
    NSMutableArray *_joyStickTags;
    NSMutableArray *_buttonTags;
    
    NSMutableArray *_buttonPressBlocks;
    NSMutableArray *_joystickMoveBlocks;
    NSMutableArray *_arbitraryDataBlocks;
    
    void(^connectionRequestBlock)(NSString *peerID, NSString *displayName, ResponseBlock respBlock);
    void(^serverAvailableBlock)(NSString *serverID, NSString *serverDisplayName);
}
- (void)configureSession;

@end

NSString * const BTCManagerNotificationFoundAvailableController = @"BTCManagerNotificationControllerAvailableForConnection";
NSString * const BTCManagerNotificationConnectingToController = @"BTCManagerNotificationConnectingToController";
NSString * const BTCManagerNotificationConnectedToController = @"BTCManagerNotificationConnectedToController";
NSString * const BTCManagerNotificationDisconnectedFromController = @"BTCManagerNotificationDisconnectedFromController";
NSString * const BTCManagerNotificationControllerUnavailable = @"BTCManagerNotificationControllerUnavailable";

NSString * const BTCManagerNotificationConntedToPeerController = @"BTCManagerNotificationConntedToPeerController";
NSString * const BTCManagerNotificationDisconnectedFromPeerController = @"BTCManagerNotificationDisconnectedFromPeerController";

NSString * const BTCManagerNotificationConnectingToServer = @"BTCManagerNotificationConnectingToServer";
NSString * const BTCManagerNotificationConnectedToServer = @"BTCManagerNotificationConnectedToServer";
NSString * const BTCManagerNotificationDisconnectedFromServer = @"BTCManagerNotificationDisconnectedFromServer";
NSString * const BTCManagerNotificationServerUnavailable = @"BTCManagerNotificationServerUnavailable";

NSString * const kBTCPeerID = @"kBTCPeerID";
NSString * const kBTCPeerDisplayName = @"kBTCPeerDisplayName";

@implementation BTCManager
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

- (void)configureManagerAsGameWithSessionID:(NSString *)sID connectionRequestBlock:(void(^)(NSString *peerID, NSString *displayName, ResponseBlock respBlock))cRequestBlock {
    sessionID = sID;
    sessionMode = BTCConnectionTypeGame;
    connectionRequestBlock = [cRequestBlock copy];
}

- (void)configureManagerAsControllerWithSessionID:(NSString *)sID serverAvailableBlock:(void(^)(NSString *serverID, NSString *serverDisplayName))sAvailableBlock {
    sessionID = sID;
    sessionMode = BTCConnectionTypeController;
    serverAvailableBlock = [sAvailableBlock copy];
}

- (void)configureSession {
    if (sessionID) {
        GKSessionMode sesMode = sessionMode == BTCConnectionTypeController ? GKSessionModeClient : GKSessionModeServer;
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:[self displayName] sessionMode:sesMode];
        [_session setDataReceiveHandler:self withContext:nil];
        [_session setDelegate:self];
    } else
        NSLog(@"Please run one of the configureManager methods before attempting to use this class");
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
    
    [self sendNetworkPacketWithID:DataPacketTypeArbitrary withData:&completeArbitraryData ofLength:[data length] + headerPacketSize reliable:reliable toPeers:nil];
}

- (void)vibrateControllers:(NSArray *)peers {
    [self sendNetworkPacketWithID:DataPacketTypeVibration withData:NULL ofLength:0 reliable:YES toPeers:peers];
}

#pragma mark - UI callbacks

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

#pragma mark - GKSession Methods

- (void)session:(GKSession *)s didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSLog(@"Did recieve connection request from %@", [s displayNameForPeer:peerID]);
    connectionRequestBlock(peerID, [s displayNameForPeer:peerID], ^(BOOL response){
        if (response) {
            NSError *error = nil;
            if (![s acceptConnectionFromPeer:peerID error:&error]) {
                NSLog(@"failed to accept connection %@", [error localizedDescription]);
            }
        } else {
            [s denyConnectionFromPeer:peerID];
        }
    });
}

- (void)session:(GKSession *)s peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:peerID, kBTCPeerID, [s displayNameForPeer:peerID], kBTCPeerDisplayName, nil];
    switch (state) {
        case GKPeerStateAvailable:
            NSLog(@"%@ available", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                serverAvailableBlock(peerID, [s displayNameForPeer:peerID]);
            } else {
                NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationFoundAvailableController object:nil userInfo:userData];
                [noteCenter postNotification:note];
            }
            break;
        case GKPeerStateConnecting:
            NSLog(@"%@ connecting", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationConnectingToServer object:nil userInfo:userData];
                [noteCenter postNotification:note];
            } else {
                NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationConnectingToController object:nil userInfo:userData];
                [noteCenter postNotification:note];
            }
            break;
        case GKPeerStateConnected:
            NSLog(@"%@ connected", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                if ([peerID isEqualToString:_conectingServerID]) {
                    _connectedServerID = _conectingServerID;
                    _conectingServerID = nil;
                    NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationConnectedToServer object:nil userInfo:userData];
                    [noteCenter postNotification:note];
                } else {
                    NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationConntedToPeerController object:nil userInfo:userData];
                    [noteCenter postNotification:note];
                }
            } else {
                NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationConnectedToController object:nil userInfo:userData];
                [noteCenter postNotification:note];
            }
            break;
        case GKPeerStateDisconnected:
            NSLog(@"%@ disconnected", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                if ([peerID isEqualToString:_conectingServerID]) {
                    _connectedServerID = nil;
                    NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationDisconnectedFromServer object:nil userInfo:userData];
                    [noteCenter postNotification:note];
                } else {
                    NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationDisconnectedFromPeerController object:nil userInfo:userData];
                    [noteCenter postNotification:note];
                }
            } else {
                NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationDisconnectedFromController object:nil userInfo:userData];
                [noteCenter postNotification:note];
            }
            break;
        case GKPeerStateUnavailable:
            NSLog(@"%@ unavailable", [s displayNameForPeer:peerID]);
            if (sessionMode == BTCConnectionTypeController) {
                NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationServerUnavailable object:nil userInfo:userData];
                [noteCenter postNotification:note];
            } else {
                NSNotification *note = [NSNotification notificationWithName:BTCManagerNotificationControllerUnavailable object:nil userInfo:userData];
                [noteCenter postNotification:note];
            }
            break;
        default:
            NSLog(@"%@ triggered session mode change but was not caught", [s displayNameForPeer:peerID]);
            break;
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"connection with peer %@ failed with error %@", [session displayNameForPeer:peerID], [error localizedDescription]);
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
            if (![_session sendData:packet toPeers:peers withDataMode:howtosend == YES ? GKSendDataReliable : GKSendDataUnreliable error:nil]) {
                NSLog(@"failed to send data");
            }
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession: (GKSession *)s context:(void *)context {
    char * bytes = (char *)[data bytes];
    DataPacketType dataPacketType = (DataPacketType)bytes[0];
    
    
    switch (dataPacketType) {
        case DataPacketTypeButton: {
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
        case DataPacketTypeJoyStick: {
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
        case DataPacketTypeVibration: {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        }
        case DataPacketTypeArbitrary: {
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
