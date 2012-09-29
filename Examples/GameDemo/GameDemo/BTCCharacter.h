//
//  BTCCharacter.h
//  GameDemo
//
//  Created by Brian Turner on 9/28/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DirectionLeft = -1,
    DirectionRight = 1
} Direction;

typedef enum {
    JumpDirectionRising = 1,
    JumpDirectionFalling = -1,
} JumpDirection;

@interface BTCCharacter : UIView {


}
@property (nonatomic) Direction direction;
@property (nonatomic) CGFloat velocity;

- (void)update;
- (void)jump;
@end
