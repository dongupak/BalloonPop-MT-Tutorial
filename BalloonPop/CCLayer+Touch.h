//
//  CCLayer+Touch.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2014. 1. 30..
//  Copyright 2014년 DongGyu Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCLayer (Touch)

- (id) showScaleUp:(CGPoint)position;
- (id) showScaleUpWithDelay:(CGFloat)delayTime;

- (void) moveLeftRight:(id)sender withOffset:(int)offset;
- (void) move:(id)sender withOffsetPt:(CGPoint)offsetPt;
- (void) moveLeftRight5:(id)sender;
- (void) moveLeftRight10:(id)sender;

- (id) menuSelectionAction;

- (CCRenderTexture*) createStroke:(CCLabelTTF*) label
                            size:(float)size
                           color:(ccColor3B)cor;

- (CGPoint)convertedTouchPoint:(UITouch *)touch;
- (BOOL) isTouchInside:(CCSprite *)sprite withTouch:(UITouch *)touch;

@end
