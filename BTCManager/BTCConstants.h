
//
//  Header.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#ifndef BTControllerClientTester_Header_h
#define BTControllerClientTester_Header_h


typedef enum {
    ButtonStateDown,
    ButtonStateUp,
}ButtonState;

typedef struct {
    __unsafe_unretained NSString *ident;
    __unsafe_unretained NSString *displayName;
} PeerData;

typedef struct {
    int joyStickID;
    float angle;
    float distance;
} JoyStickDataStruct;


//button data.
//button ID is used to uniquely identify one button on the controller from another
//state is used to determine if the button is being pressed down, or lifted up. 
typedef struct {
    int buttonID;
    ButtonState state;
} ButtonDataStruct;

typedef struct {
    int dataID;
    __unsafe_unretained NSData *data;
} ArbitraryDataStruct;

typedef enum {
    BTCConnectionTypeController,
    BTCConnectionTypeGame
} BTCConnectionType;

#endif
