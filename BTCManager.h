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
@class BTCJoyStickView;

typedef void(^ResponseBlock)(BOOL response);

typedef enum {
    DataPacketTypeButton,
    DataPacketTypeJoyStick,
    DataPacketTypeVibration,
    DataPacketTypeArbitrary,
} DataPacketType;


//Notes sent to controllers
extern NSString * const BTCManagerNotificationFoundAvailableController;
extern NSString * const BTCManagerNotificationConnectingToController;
extern NSString * const BTCManagerNotificationConnectedToController;
extern NSString * const BTCManagerNotificationDisconnectedFromController;
extern NSString * const BTCManagerNotificationControllerUnavailable;
//Notes sent to controllers regarding peer controllers
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

}
//This is an optional name for the device (controller and server) 
//  This is human readable identifier that will be passed with all notes and blocks
//  This is optional, and if left blank it will default to the devices name (ie: "Brian Turner's iPhone 4")
@property (nonatomic, strong) NSString *displayName;

//Use this to get the instance of the manager
+ (id)sharedManager;

//One of the following two methods must be run before attempting to use the Datamanager for the first time

//SessionID - unique id for your controller/game pair.  this must be the same across all controllers and games
//   but must be unique from any other game/server pair
//ConnectionRequestBlock - this block will be called every time a controller attempts to connect to this server
//   the connection block takes three arguemnts, the id of the controller, the display name
//   of the controller and a response block. The response block is called after the server has
//   decided to accept or reject the connection
- (void)configureManagerAsGameWithSessionID:(NSString *)sID connectionRequestBlock:(void(^)(NSString *peerID, NSString *displayName, ResponseBlock responseBlock))cRequestBlock;

//SessionID - unique id for your controller/game pair.  this must be the same across all controllers and games
//   but must be unique from any other game/server pair
//ServerAvailableBlock - this block is called every time an available server is found
//   it contains serverID and server display name as arguments
- (void)configureManagerAsControllerWithSessionID:(NSString *)sID serverAvailableBlock:(void(^)(NSString *serverID, NSString *serverDisplayName))sAvailableBlock;


//This will begin the process of looking for connections
//  If registered as a game, you will begin looking for Controllers
//  If registered as a controller, you will begin looking for Games
//  Before this method can be successfully run, you must first run one of the two configureManager methods
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
//  Data can be passed either reliably or Unreliably.  If set to reliable and the transmit fails, it will be attempted again until it succeeds
//  Provide an array of peerID's.  This will be used to determine who recieves the data
- (void)sendArbitraryData:(NSData *)data withIdentifier:(int)identifier reliably:(BOOL)reliable toPeers:(NSArray *)peers;

//Will make the controllers provided vibrate for .4 seocnds
//  If the controller does not have a vibrating motor (iPod 2nd gen and before) nothing will happen
- (void)vibrateControllers:(NSArray *)peers;

//Do not call this method directly.  Instead, use sendArbitraryData:withIdentifier:reliably:toPeers
- (void)sendNetworkPacketWithID:(DataPacketType)packetID withData:(void *)data ofLength:(size_t)length reliable:(BOOL)howtosend toPeers:(NSArray *)peers;
@end
