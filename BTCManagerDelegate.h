//
//  BTCManagerDelegate.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/22/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BTCManager;




@protocol BTCManagerClientDelegate <NSObject>
//This is required and will notify the controller when a server is available. You should present the 
//  user with the servers display name and give them some way to chose to connect to the server. 
- (void)manager:(BTCManager *)manager serverAvailableForConnection:(NSString *)serverID withDisplayName:(NSString *)displayName;

@optional

- (void)manager:(BTCManager *)manager connectingToServer:(NSString *)serverID withDisplayName:(NSString *)displayName;

//Alerts the delegate when a the controller has successfully conntected to a server
//  manager:connectedToPeer:withDisplayName: will NOT be triggered as well. 
- (void)manager:(BTCManager *)manager connectedToServer:(NSString *)serverID withDisplayName:(NSString *)displayName;

//Alerts the delegate when a the controller has disconnected from a server
//  manager:disconnectedFromPeer:withDisplayName: will NOT be triggered as well. 
//  This does not mean that the server is no longer available for reconnection.  
//  It only means that the server will no longer be alerted of button presses and joystick movements
//  It would be wise to alert the user of the disconnect; possibly attempt a reconnect for them, or disable all buttons on the screen
- (void)manager:(BTCManager *)manager disconnectedFromServer:(NSString *)serverID withDisplayName:(NSString *)displayName;

//Alerts the controller when the server is no longer available for new connections
//  This does not mean that the controller has been disconnected. 
//  Please keep in mind that even after you have sent the manager becomeUnavailable this method will not
//  be triggered right away.  Apple does not acvtually set their devices as unavailable instantly, so
//  do not depend on recieving this message in a timely mannor, or at all
- (void)manager:(BTCManager *)manager serverNoLongerAvailable:(NSString *)serverID withDisplayName:(NSString *)displayName;

- (void)manager:(BTCManager *)manager peerControllerConnected:(NSString *)controllerID withDisplayName:(NSString *)displayName;

- (void)manager:(BTCManager *)manager peerControllerDisconnected:(NSString *)controllerID withDisplayName:(NSString *)displayName;
@end





@protocol BTCManagerServerDelegate <NSObject>
//Required method which prompts the server as to wether or not it should accept a connection from a controller
//  You can either simply return yes; or you can use the displayName of the controller to prompt the user in some way
- (void)manager:(BTCManager *)manager allowConnectionFromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName response:(void(^)(BOOL response))responseBlock;

@optional

- (void)manager:(BTCManager *)manager controllerAvailableForConnection:(NSString *)controllerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager connectingToController:(NSString *)controllerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager connectedToController:(NSString *)controllerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager disconnectedFromController:(NSString *)controllerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager controllerNoLongerAvailable:(NSString *)controllerID withDisplayName:(NSString *)displayName;

//These methods are the real meat of the library
//  the server will be notified when the controller presses a button or moves a joystick
//  You will be notified of the button/joystick ID number as well as which peer sent the message.
//  Use the peerID in order to figure out which controller sent the message if you allow multiplayer
- (void)manager:(BTCManager *)manager buttonPressedWithTag:(int)buttonTag fromController:(NSString *)peerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager joyStickMovedWithTag:(int)joystickTag distance:(float)distance angle:(float)angle fromController:(NSString *)controllerID withDisplayName:(NSString *)displayName;

@end
