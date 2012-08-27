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
@class BTCJoyStickPadView;

typedef void(^ResponseBlock)(BOOL response);

typedef enum {
    dataPacketTypeButton,
    dataPacketTypeJoyStick,
    dataPacketTypeVibration,
    dataPacketTypeArbitrary,
}DataPacketType;


//Notes sent to controllers
extern NSString * const BTCManagerNotificationFoundAvailableController;
extern NSString * const BTCManagerNotificationConnectingToController;
extern NSString * const BTCManagerNotificationConnectedToController;
extern NSString * const BTCManagerNotificationDisconnectedFromController;
extern NSString * const BTCManagerNotificationControllerUnavailable;
//notes sent regarding peer controllers
extern NSString * const BTCManagerNotificationConntedToPeerController;
extern NSString * const BTCManagerNotificationDisconnectedFromPeerController;

//Notes sent to servers
extern NSString * const BTCManagerNotificationFoundAvailableServer;
extern NSString * const BTCManagerNotificationConnectingToServer;
extern NSString * const BTCManagerNotificationConnectedToServer;
extern NSString * const BTCManagerNotificationDisconnectedFromServer;
extern NSString * const BTCManagerNotificationServerUnavailable;


extern NSString * const kBTCPeerID;
extern NSString * const kBTCPeerDisplayName;


@interface BTCManager : NSObject <GKSessionDelegate> {
    NSString *sessionID;
    BTCConnectionType sessionMode;
}

- (void)configureManagerAsServerWithSessionID:(NSString *)sID connectionRequestBlock:(void(^)(NSString *peerID, NSString *displayName, ResponseBlock respBlock))cRequestBlock;
- (void)configureManagerAsControllerWithSessionID:(NSString *)sID serverAvailableBlock:(void(^)(NSString *serverID, NSString *serverDisplayName))sAvailableBlock;

//This is an optional name for the device (controller and server) 
//  This is human readable identifier that will be passed with all delegate methods
//  This is optional, and if left blank will default to the devices name (ie: "Brian Turner's iPhone 4")
@property (nonatomic, strong) NSString *displayName;


//Delegates for manager.  Set yourself as either the controller, or the game delegate
//@property (nonatomic, weak) id <BTCManagerControllerDelegate> controllerDelegate;
//@property (nonatomic, weak) id <BTCManagerGameDelegate> gameDelegate;

//Use this to get an instance of the manager
+ (id)sharedManager;


//This will begin the process of looking for connections
//  If registered as a game, you will begin looking for Controllers
//  If registered as a controller, you will begin looking for Games
- (void)startSession;

//This disconnects ALL current connections
//  This will not make the device unavailable for further connections
- (void)disconnect;

//This makes the game unable to accept new connections, but will not disconnect any of the existing connections
//  This will eventually trigger the delegate method manager:serverNoLongerAvailableForConnection:displayName
- (void)becomeUnavailable;

//Tells the controller to connect to the serverID passed as the argument
//  If the connection is successful the controller will be notified with manager:connectedToServer:withDisplayName:
- (void)connectToServer:(NSString *)serverId;

- (void)registerButtonPressBlock:(void(^)(ButtonDataStruct buttonData, PeerData controllerData))buttonBlock;

- (void)registerJoystickMovedBlock:(void(^)(JoyStickDataStruct joystickData, PeerData controllerData))joystickBlock;

- (void)registerArbitraryDataRecievedBlock:(void(^)(ArbitraryDataStruct arbitraryData, PeerData controllerData))arbitraryDataBlock;

//Use this method to send any data to any device (game, or controller)
//  Package the data in NSData
//  Be sure to pass a unique identifier specific to the data type in order to avoid confusion when then data is recieved
//  Data can be passed either reliably or not reliably.  If set to reliable and the transmit fails, it will be attempted again until it succeeds
//  Provide an array of peerID's.  This will be used to determine who recieves the data
- (void)sendArbitraryData:(NSData *)data withIdentifier:(int)identifier reliably:(BOOL)reliable toPeers:(NSArray *)peers;

//Will make the controllers provided vibrate for .4 seocnds
//  If the controller does not have a vibrating motor (iPod 2nd gen and before) nothing will happen
- (void)vibrateControllers:(NSArray *)peers;


//Do not call this method directly.  Instead, use sendArbitraryData:withIdentifier:reliably:toPeers
- (void)sendNetworkPacketWithID:(DataPacketType)packetID withData:(void *)data ofLength:(size_t)length reliable:(BOOL)howtosend toPeers:(NSArray *)peers;
@end
