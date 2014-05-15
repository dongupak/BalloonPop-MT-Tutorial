//
//  Balloon.h
//  Memory Train
//
//  Created by DongGyu Park on 2013. 12. 11.
//  Copyright (c) 2013년 DongGyu Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "CCLayer+Touch.h"

@interface Balloon : CCSprite
{
    NSInteger balloonIndex;
    
    NSString *spriteFileName;
    CCAnimate *popAnimate;
    
    CGRect  balloonRect;
    BOOL    isHit;
    id      delegate;
}

@property (readwrite) NSInteger balloonIndex;
@property (readwrite) CGRect  balloonRect;

@property (nonatomic, retain) NSString *spriteFileName;
@property (nonatomic, retain) CCAnimate *popAnimate;
@property (nonatomic, assign) id delegate;

- (id) initWithLocation:(CGPoint)location;
- (void) popAnimationWithName:(NSString *)nameOfLogo;
- (void) pop;
- (void) showSpriteTexture;
- (void) playPopSound;
- (void) moveRandomUpDown;
- (void) moveWithRotation;

@end
