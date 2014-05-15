//
//  LevelSelecLayer.m
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2014. 1. 4..
//  Copyright (c) 2014년 DongGyu Park. All rights reserved.
//

#import "LevelSelecLayer.h"
#import "AppDelegate.h"
#import "SceneManager.h"
#import "Balloon.h"

// 배경사운드와 pop 사운드 효과
#define BP_BG_MUSIC         (@"BP_gameBackground.mp3")
#define BP_POP_SOUND        (@"BP_pop_sound.wav")
#define BP_BG_MUSIC_VOL     (0.2)

#define MENU_ITEM_OFFSET        (120)
#define MENU_ITEM_INIT_SCALE    (0.01f)

extern float clampRandomNumber(int min, int max);
extern float clampRandomNumberf(float min, float max);

#define BALLOON_GEN_INTERVAL    (1.0f)

@implementation LevelSelecLayer

// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        isMenuSelected = NO;
        appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        
        [self getScreenSize];
        
        // 사운드 효과음을 미리 로딩
		[self preloadSoundEffects];
        
        // balloonGroup 노드 생성
        [self addBalloonGroup];
        
        // create and initialize a Label
		[self animateBackground];
        [self scheduleOnce:@selector(showTitle) delay:0.4];
        
        [self schedule:@selector(generateBalloon) interval:BALLOON_GEN_INTERVAL];
    }
    
    return self;
}

- (void)getScreenSize
{
    // 화면 크기와 화면의 중심좌표를 얻는다
    screenRect = [[UIScreen mainScreen] bounds];
    centerPt = CGPointMake(CGRectGetMidX(screenRect),
                           CGRectGetMidY(screenRect));
}

// simple audio engine에서 이용한 사운드 효과를 미리 로딩함
- (void)preloadSoundEffects
{
    sae=[SimpleAudioEngine sharedEngine];
    [sae preloadBackgroundMusic:BP_BG_MUSIC];
    [sae preloadEffect:BP_POP_SOUND];
}

// 풍선을 저장할 노드를 만들고 이 노드 아래 생성된 풍선이 추가됨
- (void)addBalloonGroup
{
    balloonGroup = [CCNode node];
    [self addChild:balloonGroup z:200 tag:kTagBalloonGroup];
}

#define BALLOON_MIN_SIZE            (40/2)
#define BALLOON_OPACITY             (200)

// 화면 아내쪽에서 화면의 위쪽으로 이동하는 풍선을 만들어 본다
- (void)generateBalloon
{
    // 이를 위해 화면의 크기를 알아야 한다
    NSInteger   screenWidth = (NSInteger)screenRect.size.width;
    NSInteger   screenHeight = (NSInteger)screenRect.size.height;
    
    // get random position from current screen size
    float xPos = arc4random() % (screenWidth-BALLOON_MIN_SIZE) + BALLOON_MIN_SIZE/2;
    float yPos = -BALLOON_MIN_SIZE;
    
    // calculate random destination point
    // random range is (-screenWidth/4,screenWidth/4)
    float xPosRndOffset = clampRandomNumberf(-screenWidth/4.0f, screenWidth/4.0f);
    float dstXPos = xPos + xPosRndOffset;
    float dstYPos = screenHeight + 100; // outside of the screen
    
    Balloon *balloon = [[Balloon alloc] initWithLocation:CGPointMake(xPos, yPos)];
    balloon.delegate = self;
    balloon.opacity = clampRandomNumber(150, 250);  // 약간의 투명 설정
    balloon.scale = clampRandomNumberf(1.1f, 2.2f);
    [balloon moveWithRotation];
    [balloonGroup addChild:balloon z:100 tag:kTagBalloon];
    
    // moving time from bottom to top
    CGFloat moveDuration = clampRandomNumber(4,8);
    id moveToTop = [CCMoveTo actionWithDuration:moveDuration
                                       position:ccp(dstXPos, dstYPos)];
    
    CCCallBlock *removeFromLayer = [CCCallBlock actionWithBlock:^(void){
        [balloon removeFromParent];
    }];
    id moveSeq = [CCSequence actions:moveToTop, removeFromLayer, nil];
    [balloon runAction:moveSeq];
}

- (void)showTitle
{
    CCSprite *levelSelectLabel = [CCSprite spriteWithFile:@"levelselect.png"];
    // 메인 배경의 초기위치와 z 값 설정
    [levelSelectLabel setPosition:ccp(centerPt.x,centerPt.y+150)];
    levelSelectLabel.scale = 0.01;
    [self addChild:levelSelectLabel z:1000 tag:kTagLevelSelectTitle];
    
    id scaleUp1 = [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.3 scale:1.0]];
    [levelSelectLabel runAction:scaleUp1];
    
    id waitAction = [CCDelayTime actionWithDuration:4.5];
    id scaleUp2 = [CCScaleTo actionWithDuration:0.1 scale:1.1];
    id scaleDown1 = [CCScaleTo actionWithDuration:0.1 scale:0.92];
    id scaleUp3 = [CCScaleTo actionWithDuration:0.07 scale:1.05];
    id scaleDown2 = [CCScaleTo actionWithDuration:0.07 scale:0.96];
    
    id waitAndScale = [CCSequence actions:waitAction, scaleUp2, scaleDown1,
                       scaleUp3, scaleDown2, nil];
    id repeatWaitAndScale = [CCRepeatForever actionWithAction:waitAndScale];
    [levelSelectLabel runAction:repeatWaitAndScale];
    
    [self scheduleOnce:@selector(showMenu) delay:0.3];
}

#define LEVEL_SELECT_BACKGROUND     @"bg_cloud.png"

// 메뉴 출력시 애니메이션
- (void)animateBackground
{
    CCSprite *bgSprite = [CCSprite spriteWithFile:LEVEL_SELECT_BACKGROUND];
    
    // 메인 배경의 초기위치와 z 값 설정
    [bgSprite setPosition:centerPt];
    [self addChild:bgSprite z:0 tag:kTagLevelSelectBackground];
}

// 메뉴 보이기
- (void)showMenu
{
    // Level Select 장면의 메뉴 출력 애니메이션
    // Easy, Medium, Hard 기능이 있음
    CCSprite *easyNormalBtn = [CCSprite spriteWithFile:@"btn_easylevel.png"];
    CCSprite *easySelectedBtn = [CCSprite spriteWithFile:@"btn_easylevel_s.png"];
    itemEasyLevel = [CCMenuItemSprite itemWithNormalSprite:easyNormalBtn
                                            selectedSprite:easySelectedBtn
                                                    target:self
                                                  selector:@selector(doClick:)];
    itemEasyLevel.scale = MENU_ITEM_INIT_SCALE;
    //itemEasyLevel.color = ccc3(200, 200, 0);
    itemEasyLevel.tag = kTagEasyLevel;
    
    CCSprite *mediumNormalBtn = [CCSprite spriteWithFile:@"btn_mediumlevel.png"];
    CCSprite *mediumSelectedBtn = [CCSprite spriteWithFile:@"btn_mediumlevel_s.png"];
    itemMediumLevel = [CCMenuItemSprite itemWithNormalSprite:mediumNormalBtn
                                              selectedSprite:mediumSelectedBtn
                                                      target:self
                                                    selector:@selector(doClick:)];
    itemMediumLevel.scale = MENU_ITEM_INIT_SCALE;
    //itemMediumLevel.color = ccc3(200+10, 200+10, 0);
    itemMediumLevel.tag = kTagMediumLevel;
    
    CCSprite *hardNormalBtn = [CCSprite spriteWithFile:@"btn_hardlevel.png"];
    CCSprite *hardSelectedBtn = [CCSprite spriteWithFile:@"btn_hardlevel_s.png"];
    itemHardLevel = [CCMenuItemSprite itemWithNormalSprite:hardNormalBtn
                                            selectedSprite:hardSelectedBtn
                                                    target:self
                                                  selector:@selector(doClick:)];
    itemHardLevel.scale = MENU_ITEM_INIT_SCALE;
    //itemHardLevel.color = ccc3(200+20, 200+20, 0);
    itemHardLevel.tag = kTagHardLevel;
    
    CCSprite *expertNormalBtn = [CCSprite spriteWithFile:@"btn_expertlevel.png"];
    CCSprite *expertSelectedBtn = [CCSprite spriteWithFile:@"btn_expertlevel_s.png"];
    itemExpertLevel = [CCMenuItemSprite itemWithNormalSprite:expertNormalBtn
                                                selectedSprite:expertSelectedBtn
                                                        target:self
                                                      selector:@selector(doClick:)];
    itemExpertLevel.scale = MENU_ITEM_INIT_SCALE;
    //itemExpertLevel.color = ccc3(200+30, 200+30, 0);
    itemExpertLevel.tag = kTagExpertLevel;
    
    CCMenu *menu = [CCMenu menuWithItems:itemEasyLevel,
                    itemMediumLevel,
                    itemHardLevel,
                    itemExpertLevel, nil];
    [menu alignItemsVerticallyWithPadding:55];
    [menu setPosition:ccp(centerPt.x, centerPt.y-50)];
    
    // add scale up action for menu itemEasyLevel-itemExpertLevel
    // jump 액션의 애니메이션 시간들
    const ccTime jump1Time = 0.1f;
    const ccTime jump2Time = 0.08f;
    const ccTime jump3Time = 0.06f;
    const ccTime jump4Time = 0.04f;
    // 전체 애니메이션 시간의 합을 구한다
    const ccTime totalAnimationTime = jump1Time + jump2Time + jump3Time + jump4Time;
    // 애니메이션 루프를 도는데 소요되는 시간
    const ccTime totalTime = 2.5f;
    const ccTime waitBeforeAction1Time = 1.3f;
    const ccTime delayInterval = 0.1f;
    
    ccTime waitAfterAction1Time = totalTime-(waitBeforeAction1Time + totalAnimationTime);
    id jump1Action = [CCJumpBy actionWithDuration:jump1Time position:CGPointZero
                                           height:10 jumps:1];
    id jump2Action = [CCJumpBy actionWithDuration:jump2Time position:CGPointZero
                                           height:5 jumps:1];
    id jump3Action = [CCJumpBy actionWithDuration:jump3Time position:CGPointZero
                                           height:2 jumps:1];
    id seqAction = [CCSequence actions:jump1Action, jump2Action, jump3Action, nil];
    id waitBeforeAction1 = [CCDelayTime actionWithDuration:waitBeforeAction1Time];
    id waitAfterAction1 = [CCDelayTime actionWithDuration:waitAfterAction1Time];
    id repeatWaitAndMove1 = [CCRepeatForever actionWithAction:[CCSequence actions:waitBeforeAction1, seqAction, waitAfterAction1, nil]];
    [itemEasyLevel runAction:repeatWaitAndMove1];
    
    ccTime waitBeforeAction2Time = waitBeforeAction1Time+delayInterval;
    ccTime waitAfterAction2Time = totalTime-(waitBeforeAction2Time + totalAnimationTime);
    id waitBeforeAction2 = [CCDelayTime actionWithDuration:waitBeforeAction2Time];
    id waitAfterAction2 = [CCDelayTime actionWithDuration:waitAfterAction2Time];
    id repeatWaitAndMove2 = [CCRepeatForever actionWithAction:[CCSequence actions:waitBeforeAction2, [seqAction copy], waitAfterAction2, nil]];
    [itemMediumLevel runAction:repeatWaitAndMove2];
    
    ccTime waitBeforeAction3Time = waitBeforeAction2Time+delayInterval;
    ccTime waitAfterAction3Time = totalTime-(waitBeforeAction3Time + totalAnimationTime);
    id waitBeforeAction3 = [CCDelayTime actionWithDuration:waitBeforeAction3Time];
    id waitAfterAction3 = [CCDelayTime actionWithDuration:waitAfterAction3Time];
    id repeatWaitAndMove3 = [CCRepeatForever actionWithAction:[CCSequence actions:waitBeforeAction3, [seqAction copy], waitAfterAction3, nil]];
    [itemHardLevel runAction:repeatWaitAndMove3];
    
    ccTime waitBeforeAction4Time = waitBeforeAction3Time+delayInterval;
    ccTime waitAfterAction4Time = totalTime-(waitBeforeAction4Time + totalAnimationTime);
    id waitBeforeAction4 = [CCDelayTime actionWithDuration:waitBeforeAction4Time];
    id waitAfterAction4 = [CCDelayTime actionWithDuration:waitAfterAction4Time];
    id repeatWaitAndMove4 = [CCRepeatForever actionWithAction:[CCSequence actions:waitBeforeAction4, [seqAction copy], waitAfterAction4, nil]];
    [itemExpertLevel runAction:repeatWaitAndMove4];
    
    // Add the menu to the layer
    [self addChild:menu z:200 tag:kTagLevelSelectMenu];
    
    id action1 = [self showScaleUpWithDelay:0.2];
    [itemEasyLevel runAction:action1];
    
    id action2 = [self showScaleUpWithDelay:0.3];
    [itemMediumLevel runAction:action2];
    
    id action3 = [self showScaleUpWithDelay:0.4];
    [itemHardLevel runAction:action3];
    
    id action4 = [self showScaleUpWithDelay:0.5];
    [itemExpertLevel runAction:action4];
}

- (void)removeAllBalloons
{
    // 플레이 모드를 off 시킨다
    // 모든 arshape 배열의 객체를 invisible로 만든다.
    for(Balloon *balloon in [balloonGroup children]) {
        [sae playEffect:BP_POP_SOUND];
        [balloon pop];
    }
}

// 메뉴 클릭시의 애니메이션
- (void)doClick:(id)sender
{
    // prevent double selection
    if (isMenuSelected == YES)
        return;
    else
        isMenuSelected = YES;
    
    CCMenuItem *selectedMenu = (CCMenuItem *)sender;
    
    // pop all balloons
    [self removeAllBalloons];
    
    // stop generating balloons
    [self unschedule:@selector(generateBalloon)];
    
    id menuSelectActions = [self menuSelectionAction];
    [selectedMenu runAction:menuSelectActions];
    
    // 선택된 메뉴의 태그정보를 이용하여 어느 메뉴가 선택되었는지 식별
    switch (selectedMenu.tag) {
        case kTagExpertLevel:
            appDelegate.gameLevel = BP_LEVEL_EXPERT;
            break;
        case kTagHardLevel:
            appDelegate.gameLevel = BP_LEVEL_HARD;
            break;
        case kTagMediumLevel:
            appDelegate.gameLevel = BP_LEVEL_MEDIUM;
            break;
        case kTagEasyLevel:
        default:
            appDelegate.gameLevel = BP_LEVEL_EASY;
            break;
    }
    
    [self performSelector:@selector(goToGameCallback)
               withObject:nil
               afterDelay:0.9f];
}

- (void) goToGameCallback
{
    [SceneManager goGame];
}

@end
