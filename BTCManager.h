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
@class BTCJoyStickController;

@protocol BTCManagerClientDelegate;
@protocol BTCManagerServerDelegate;


typedef enum {
    dataPacketTypeButton,
    dataPacketTypeJoyStick,
}DataPacketType;

@interface BTCManager : NSObject <GKSessionDelegate> {

}
//This is the unique string used to identify your particular game/controller pairing. 
//  This id needs to be common amount your game and controllers, but unique from all over
//  apps which may be using this library.  
@property (nonatomic, strong) NSString *sessionID;


@property (nonatomic) BTCConnectionType sessionMode;

//This is an optional name for the device (controller and server) 
//  This is human readable identifier that will be passed with all delegate methods
//  This is optional, and if left blank will default to the devices name (ie: "Brian Turner's iPhone 4")
@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, weak) id <BTCManagerClientDelegate> clientDelegate;
@property (nonatomic, weak) id <BTCManagerServerDelegate> serverDelegate;

//Use this to get an instance of the manager
+ (id)sharedManager;


//This will begin the process of looking for connections
//  If registered as a game, you will begin looking for Controllers
//  If registered as a controller, you will begin looking for Games
- (void)startSession;


- (void)disconnect;

//This makes the game unable to accept new connections, but will not disconnect any of the existing connections
//  This will eventually trigger the delegate method manager:serverNoLongerAvailableForConnection:displayName
- (void)becomeUnavailable;

//Tells the controller to connect to the serverID passed as the argument
//  If the connection is successful the controller will be notified with manager:connectedToServer:withDisplayName:
- (void)connectToServer:(NSString *)serverId;

//You must use this to register all buttons with the manager
//  This will allow the button to properly send the Game the notification
- (BOOL)registerButtonWithManager:(BTCButton *)button;

//You must use this to register all joysticks with the manager
//  This will allow the joystick to properly send the Game the notification
- (BOOL)registerJoystickWithManager:(BTCJoyStickController *)js;

- (void)sendNetworkPacketWithID:(DataPacketType)packetID withData:(void *)data ofLength:(size_t)length reliable:(BOOL)howtosend toPeers:(NSArray *)peers;
@end
