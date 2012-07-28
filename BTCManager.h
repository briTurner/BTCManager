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

@protocol BTCManagerControllerDelegate;
@protocol BTCManagerGameDelegate;


typedef enum {
    dataPacketTypeButton,
    dataPacketTypeJoyStick,
    dataPacketTypeVibration,
    dataPacketTypeArbitrary,
}DataPacketType;

@interface BTCManager : NSObject <GKSessionDelegate> {

}
//This is the unique string used to identify your particular game/controller pairing. 
//  This id needs to be common amoung your game and controllers, but unique from all over
//  apps which may be using this library.  
@property (nonatomic, strong) NSString *sessionID;

//Set this to either controller or game depending on your use
@property (nonatomic) BTCConnectionType sessionMode;

//This is an optional name for the device (controller and server) 
//  This is human readable identifier that will be passed with all delegate methods
//  This is optional, and if left blank will default to the devices name (ie: "Brian Turner's iPhone 4")
@property (nonatomic, strong) NSString *displayName;


//Delegates for manager.  Set yourself as either the controller, or the game delegate
@property (nonatomic, weak) id <BTCManagerControllerDelegate> controllerDelegate;
@property (nonatomic, weak) id <BTCManagerGameDelegate> gameDelegate;

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
