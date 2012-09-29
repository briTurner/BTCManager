//
//  BTJoyStickPadView.h
//  BTJoyStick
//
//  Created by Brian Turner on 1/28/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BTCJoyStickViewDelegate;

@interface BTCJoyStickView : UIView {
    
}

@property (nonatomic, weak) id <BTCJoyStickViewDelegate> delegate;
@end

@protocol BTCJoyStickViewDelegate <NSObject>

- (void)joystick:(BTCJoyStickView *)js movedDistance:(CGFloat)d andgle:(CGFloat)a;

@end