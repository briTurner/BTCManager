//
//  BTCServer.h
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/12/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTCServer : NSObject

@property (nonatomic, strong) NSString *serverID;
@property (nonatomic, strong) NSString *serverDisplayName;
@property (nonatomic) BOOL connected;

@end
