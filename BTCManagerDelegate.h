//
//  BTCManagerDelegate.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/22/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BTCManager;

@protocol BTCManagerDelegate <NSObject>

@optional

//Alerts the delegate when a peer is in the process of connecting
- (void)manager:(BTCManager *)manager connectingToPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;

//Alerts the delegate when a peer has connected. 
//  If the peer that is now connected is the server, the controller will not recieve this message.
//  Instead the controller will recieve the message manager:connectedToServer:withDisplayName:
- (void)manager:(BTCManager *)manager connectedToPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;

//Alerts the delegate whena peer has disconnected.
//  If the peer that is no longer connected is the server, the client will not recieve this message.
//  Instead the client will recieve the message manager:disconnectedFromServer:withDisplayName
- (void)manager:(BTCManager *)manager disconnectedFromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;

@end




@protocol BTCManagerClientDelegate <BTCManagerDelegate>
//This is required and will notify the controller when a server is available. You should present the 
//  user with the servers display name and give them some way to chose to connect to the server. 
- (void)manager:(BTCManager *)manager serverAvailableForConnection:(NSString *)serverID withDisplayName:(NSString *)dName;

@optional
//Alerts the delegate when a the controller has successfully conntected to a server
//  manager:connectedToPeer:withDisplayName: will NOT be triggered as well. 
- (void)manager:(BTCManager *)manager connectedToServer:(NSString *)serverID withDisplayName:(NSString *)dName;

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
- (void)manager:(BTCManager *)manager serverNoLongerAvailableForConnection:(NSString *)serverID withDisplayName:(NSString *)displayName;
@end





@protocol BTCManagerServerDelegate <BTCManagerDelegate>
//Required method which prompts the server as to wether or not it should accept a connection from a controller
//  You can either simply return yes; or you can use the displayName of the controller to prompt the user in some way
- (void)manager:(BTCManager *)manager allowConnectionFromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName response:(void(^)(BOOL response))responseBlock;

@optional
//These methods are the real meat of the library
//  the server will be notified when the controller presses a button or moves a joystick
//  You will be notified of the button/joystick ID number as well as which peer sent the message.
//  Use the peerID in order to figure out which controller sent the message if you allow multiplayer
- (void)manager:(BTCManager *)manager buttonPressedWithTag:(int)buttonTag fromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;
- (void)manager:(BTCManager *)manager joyStickMovedWithTag:(int)joystickTag distance:(float)distance angle:(float)angle fromPeer:(NSString *)peerID withDisplayName:(NSString *)displayName;

@end
