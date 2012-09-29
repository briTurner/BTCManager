//
//  BTCCharacter.m
//  GameDemo
//
//  Created by Brian Turner on 9/28/12.
//  Copyright (c) 2012 Brian Turner. All rights reserved.
//

#import "BTCCharacter.h"

@interface BTCCharacter () {
    BOOL jumping;
    float jumpMomentum;
    JumpDirection jumpDirection;
}

@end

@implementation BTCCharacter

- (id)initWithFrame:(CGRect)frame displayName:(NSString *)displayName
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:[self bounds]];
        [label setText:displayName];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setMinimumFontSize:6];
        [self addSubview:label];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame displayName:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)jump {
    if (!jumping) {
        jumping = YES;
        jumpMomentum = 10;
        jumpDirection = JumpDirectionRising;
    }
}

- (void)update {
    CGRect currnetRect = [self frame];
    CGFloat newX =     currnetRect.origin.x + ([self direction] * ([self velocity] * 10));
    if (newX <= 0)
        newX = 0;
    if (newX >= 480 - currnetRect.size.width)
        newX = 480 - currnetRect.size.width;
    currnetRect.origin.x = newX;
    
    if (jumping) {
        CGFloat newY = currnetRect.origin.y - (jumpDirection * jumpMomentum);
        jumpMomentum -= jumpDirection;
        if (!jumpMomentum)
            jumpDirection = !jumpDirection;
        if (newY > 200) {
            newY = 200;
            jumping = NO;
        }
        currnetRect.origin.y = newY;
    }

    [self setFrame:currnetRect];
}

@end
