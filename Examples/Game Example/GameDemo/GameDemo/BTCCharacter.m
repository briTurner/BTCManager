//
//  BTCCharacter.m
//  GameDemo
//
//  Created by Brian Turner on 9/28/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import "BTCCharacter.h"
#import "BTCManager.h"

@interface BTCCharacter () {
    BOOL jumping;
    float jumpMomentum;
    JumpDirection jumpDirection;
    CGFloat width;
    CGFloat height;
}

@end

@implementation BTCCharacter

- (id)initWithFrame:(CGRect)frame displayName:(NSString *)displayName
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:[self bounds]];
        [label setText:[NSString stringWithFormat:@"%@\nTap Me", displayName]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setMinimumFontSize:6];
        [label setNumberOfLines:0];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
        width = [[UIScreen mainScreen] bounds].size.height;
        height = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame displayName:nil];
}

- (void)jump {
    if (!jumping) {
        jumping = YES;
        jumpMomentum = 20;
        jumpDirection = JumpDirectionRising;
    }
}

- (void)update {
    CGRect currnetRect = [self frame];
    CGFloat newX =     currnetRect.origin.x + ([self direction] * ([self velocity] * 10));
    if (newX <= 0)
        newX = 0;
    if (newX >= width - currnetRect.size.width)
        newX = width - currnetRect.size.width;
    currnetRect.origin.x = newX;
    
    if (jumping) {
        CGFloat newY = currnetRect.origin.y - (jumpDirection * jumpMomentum);
        jumpMomentum -= jumpDirection;
        if (!jumpMomentum)
            jumpDirection = !jumpDirection;
        if (newY > height - [self frame].size.height) {
            newY = height - [self frame].size.height;
            jumping = NO;
        }
        currnetRect.origin.y = newY;
    }
    
    [self setFrame:currnetRect];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[BTCManager sharedManager] vibrateControllers:[NSArray arrayWithObject:[self peerID]]];
}


@end
