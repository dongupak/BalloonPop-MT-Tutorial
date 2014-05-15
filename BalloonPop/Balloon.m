//
//  Balloon.m
//  Memory Train
//
//  Created by DongGyu Park on 2013. 12. 11..
//  Copyright (c) 2013년 DongGyu Park. All rights reserved.
//

#import "Balloon.h"
#import "AppDelegate.h"

#define BALLOON_WIDTH       (70)
#define BALLOON_HEIGHT      (70)

#define DEFAULT_BALLOON_NAME        (@"balloon_red")
#define EXPERT_LEVEL_BALLOON_NAME   (@"balloon_blue")

extern float clampRandomNumber(int min, int max);
extern float clampRandomNumberf(float min, float max);

@implementation Balloon

@synthesize balloonIndex;
@synthesize spriteFileName;
@synthesize popAnimate;
@synthesize delegate;
@synthesize balloonRect;

- (id)init
{
    if ((self = [super init]))
	{
        isHit = NO;
        popAnimate = nil;
        
        // default balloon name
        NSString *balloonName = DEFAULT_BALLOON_NAME;
        self.spriteFileName = [NSString stringWithFormat:@"%@0001.png",
                               balloonName];
        
        [self showSpriteTexture];
        [self popAnimationWithName:balloonName];
    }
    return self;
}

- (id)initWithLocation:(CGPoint)location
{
    if ((self = [super init]))
	{
        isHit = NO;
        popAnimate = nil;
        
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication]
                                                       delegate];
        NSInteger gameLevel = appDelegate.gameLevel;
        
        // balloon sprite를 결정하는 메소드로 game level에 따라 정해짐
        [self initBalloonSprite:gameLevel];
        self.position = location;
    }
    return self;
}

#define NUM_OF_MED_LEVEL_BALLOON    (3)

- (void)initBalloonSprite: (NSInteger) gameLevel
{
    NSArray *balloons = [NSArray arrayWithObjects:@"balloon_red", @"balloon_yellow",
                         @"balloon_navy", @"balloon_brown", @"balloon_green",
                         @"balloon_pink", @"balloon_orange",@"balloon_mint",
                         @"balloon_purple",@"balloon_yellgreen",@"balloon_gray", nil];
    NSInteger numOfBalloons = [balloons count];
    NSString *balloonName;
    
    switch (gameLevel) {
        case BP_LEVEL_EXPERT:
            balloonIndex = 0;
            balloonName = EXPERT_LEVEL_BALLOON_NAME;
            break;
        case BP_LEVEL_HARD:
            balloonIndex = 0;
            balloonName = [balloons objectAtIndex:balloonIndex];
            break;
        case BP_LEVEL_MEDIUM:
            balloonIndex = arc4random() % NUM_OF_MED_LEVEL_BALLOON;
            balloonName = [balloons objectAtIndex:balloonIndex];
            break;
        case BP_LEVEL_EASY:
        default:
            balloonIndex = arc4random() % numOfBalloons;
            balloonName = [balloons objectAtIndex:balloonIndex];
            break;
    }
    
    self.spriteFileName = [NSString stringWithFormat:@"%@0001.png",
                           balloonName];
    
    [self showSpriteTexture];
    [self popAnimationWithName:balloonName];
}

- (void)playPopSound
{
//    [sae playEffect:BONG_BOMB_FIRE_SOUND];
}

- (void) popComplete
{
    // pop가 완료되었으므로 모든 액션을 중지하고 visible 속성을 NO로 하여 화면에서 숨긴다
//    [self stopAllActions];
}

// show Ballon sprite texture

- (void) showSpriteTexture
{
    CCSprite *sprite = [CCSprite spriteWithFile:spriteFileName];
    self.balloonRect = CGRectMake(0, 0,
                                  sprite.boundingBox.size.width,
                                  sprite.boundingBox.size.height);
    [self setTexture:sprite.texture];
    [self setTextureRect:self.balloonRect];
}

// run popping animation
- (void) pop
{
    isHit = YES;
    
    if(popAnimate == nil)
        return;
    
    if (![popAnimate isDone])
        [self stopAction:popAnimate];
    
    id popDone = [CCCallFunc actionWithTarget:self
                                     selector:@selector(popComplete)];
    [self runAction:[CCSequence actions:popAnimate, popDone, nil]];
}

#pragma mark -
#pragma mark Balloon pop animation

#define BALLOON_POP_FRAME    (6)

- (void)popAnimationWithName:(NSString *)nameOfLogo
{
    NSMutableArray *frames = [NSMutableArray array];
    
    for(NSInteger idx = 1; idx <= BALLOON_POP_FRAME; idx++) {
        NSString *nameOfFile = [nameOfLogo stringByAppendingFormat:@"%04ld.png",(long)idx];
        CCSprite *sprite = [CCSprite spriteWithFile:nameOfFile];
        sprite.anchorPoint = ccp(0.5f, 0.5f);
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:sprite.texture
                                                          rect:sprite.textureRect];
        [frames addObject:frame];
    }

    CCAnimation *popAnimation = [[CCAnimation alloc] initWithSpriteFrames:frames
                                                                    delay:0.1];
    popAnimation.restoreOriginalFrame = NO;
    popAnimate = [[CCAnimate alloc] initWithAnimation:popAnimation];
    [[CCAnimationCache sharedAnimationCache] addAnimation:popAnimation
                                                     name:@"popAnim"];
}

#pragma mark -
#pragma mark Balloon moving action during waiting time

// 기다리는 동안 작은 풍선 움직임을 만들어준다.

#define DEFAULT_MOVING_OFFSET     (7.0f)

- (void) moveRandomUpDown
{
    [self moveRandomUpDownOffset:DEFAULT_MOVING_OFFSET];
}

// 아래위, 좌우회전하며 움직이는 풍선모양을 만들어 본다
- (void) moveRandomUpDownOffset:(CGFloat)offset
{
    float movingDuration1 = clampRandomNumberf(0.5f, 2.0f);
    float movingDuration2 = clampRandomNumberf(0.5f, 2.0f);
    float offsetX = clampRandomNumberf(-offset, offset);
    float offsetY = clampRandomNumberf(-offset, offset);
    float posX = self.position.x + offsetX;
    float posY = self.position.y + offsetY;
    float negX = self.position.x - offsetX;
    float negY = self.position.y - offsetY;
    
    // 아래 위 랜덤 이동
    CCMoveTo *moveTo1 = [CCMoveTo actionWithDuration:movingDuration1
                                            position:ccp(posX, posY)];
    CCMoveTo *moveTo2 = [CCMoveTo actionWithDuration:movingDuration1
                                            position:ccp(negX, negY)];
    // 랜덤값으로 회전 변이를 준다
    CCRotateTo *rot1 = [CCRotateTo actionWithDuration:movingDuration2 angle:offsetY*2.0];
    CCRotateTo *rot2 = [CCRotateTo actionWithDuration:movingDuration2 angle:-offsetY*2.0];
    
    // 이동+회전 동시 액션
    id act1 = [CCSequence actions:moveTo1, moveTo2, nil];
    id act2 = [CCSequence actions:rot1, rot2, nil];
    CCSpawn *spawnAction = [CCSpawn actions:act1, act2, nil];
    id repeatAction = [CCRepeatForever actionWithAction:spawnAction];
    
    [self runAction:repeatAction];
}

// 좌우 회전액션
- (void) moveWithRotation
{
    [self moveWithRotationOffset:DEFAULT_MOVING_OFFSET];
}

- (void) moveWithRotationOffset:(CGFloat)offset
{
    float movingDuration1 = clampRandomNumberf(0.5f, 2.0f);
    float movingDuration2 = clampRandomNumberf(0.5f, 2.0f);
    float offsetX = clampRandomNumberf(-offset, offset);
    float offsetY = clampRandomNumberf(-offset, offset);
    
    // 랜덤한 시간동안 랜덤 값으로 회전 변이를 준다
    CCRotateTo *rot1 = [CCRotateTo actionWithDuration:movingDuration1
                                                angle:offsetX*2.0];
    CCRotateTo *rot2 = [CCRotateTo actionWithDuration:movingDuration2
                                                angle:-offsetY*2.0];
    
    // 회전 액션
    id rotAction = [CCSequence actions:rot1, rot2, nil];
    id repeatAction = [CCRepeatForever actionWithAction:rotAction];
    
    [self runAction:repeatAction];
}

@end
