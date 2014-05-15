//
//  MenuLayer.m
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 20..
//  Copyright DongGyu Park 2013년. All rights reserved.
//

#import "MenuLayer.h"
#import "SceneManager.h"

#define BP_BG_MUSIC         (@"BP_gameBackground.mp3")
#define BP_POP_SOUND        (@"BP_pop_sound.wav")
#define BP_FAIL_SOUND        (@"BP_fail_sound.m4a")
#define BP_BG_MUSIC_VOL     (0.2)

extern float clampRandomNumber(int min, int max);
extern float clampRandomNumberf(float min, float max);

extern BOOL isGameCenterAPIAvailable();

#define BALLOON_GEN_INTERVAL    (1.0f)

#pragma mark - MenuLayer

// HelloWorldLayer implementation
@implementation MenuLayer

@synthesize menuSelected, allItemPurchased;
@synthesize startMenuItem, howtoMenuItem, infoMenuItem;
@synthesize _localPlayer;

- (void)getScreenSize
{
    // 화면 크기와 화면의 중심좌표를 얻는다
    screenRect = [[UIScreen mainScreen] bounds];
    centerPt = CGPointMake(CGRectGetMidX(screenRect),
                           CGRectGetMidY(screenRect));
}

// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		menuSelected = NO;
        
        appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        
        [self getScreenSize];
        
        // balloonGroup 노드 생성
        [self addBalloonGroup];
		// create and initialize a Label
		[self animateBackground];
        [self preloadSoundEffects];
        
        // Test가 끝나면 uncomment
        if (isGameCenterAPIAvailable()) {
            [self authenticatePlayer];
        }

        [self schedule:@selector(generateBalloon) interval:BALLOON_GEN_INTERVAL];

        // 게임신 시작후 2초 경과한 다음 배경음이 시작된다-배경음이 바로 시작되면 이상함..
        [self performSelector:@selector(playBackgroundMusic)
                   withObject:nil
                   afterDelay:2];

	}
	return self;
}

// 풍선을 저장할 노드를 만들고 이 노드 아래 생성된 풍선이 추가됨
- (void)addBalloonGroup
{
    balloonGroup = [CCNode node];
    [self addChild:balloonGroup z:200 tag:kTagBalloonGroup];
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

-(void)onEnter
{
    [super onEnter];
    
}

#pragma mark --
#pragma mark - Player Authentication

- (void)authenticatePlayer
{
    // localPlayer is the public GKLocalPlayer
    // 게임센터에 접속할 수 있는 플레이어 객체-한 번에 한 플레이어만 접속 가능함.
    // localPlayer 메소드는 클래스 메소드로 현재 player 객체를 반환함
    _localPlayer = [[GKLocalPlayer localPlayer] retain];
    GKLocalPlayer *weakPlayer = _localPlayer; // removes retain cycle error
    //__block id copy_self = self;
    
    // 게임 플레이어의 인증 요청이 들어올때 호출되는 핸들러
    weakPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if (viewController != nil)
        {
            // 인증 다이얼로그를 화면에 출력함
            [self showAuthenticationDialogWhenReasonable:viewController];
        }
        else if (weakPlayer.isAuthenticated)
        {
            // 인증이 이루어지면 weakPlayer가 localPlayer가 된다
            [self authenticatedPlayer:weakPlayer];
        }
        else
        {
            [self disableGameCenter];
        }
    };
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

- (void)showAuthenticationDialogWhenReasonable:(UIViewController *)controller
{
//    [[[appDelegate window] rootViewController] presentViewController:controller
//                                                            animated:YES
//                                                          completion:nil];
    [appDelegate.navController presentViewController:controller
                                            animated:YES
                                          completion:nil];
}

- (void)authenticatedPlayer:(GKLocalPlayer *)player
{
    player = _localPlayer;
}

- (void)disableGameCenter
{
    
}

- (void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    UIViewController *vc = [[appDelegate window] rootViewController];
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --
#pragma mark - preloading game sound effects

// simple audio engine에서 이용한 사운드 효과를 미리 로딩함
- (void)preloadSoundEffects
{
    sae=[SimpleAudioEngine sharedEngine];
    [sae preloadBackgroundMusic:BP_BG_MUSIC];
    [sae preloadEffect:BP_POP_SOUND];
    [sae preloadEffect:BP_FAIL_SOUND];
}

- (void) playBackgroundMusic
{
    // test 중에는 off
    [sae playBackgroundMusic:BP_BG_MUSIC];
    sae.backgroundMusicVolume = BP_BG_MUSIC_VOL;
}

// 메뉴 클릭시의 애니메이션
- (void)doClick:(id)sender
{
    // prevent double selection
    if (self.isMenuSelected == YES)
        return;
    else
        self.menuSelected = YES;
    
    CCMenuItem *selectedMenu = (CCMenuItem *)sender;
    [selectedMenu runAction:[self menuSelectionAction]];
    [sae playEffect:BP_POP_SOUND];
    
    // stop generating balloons
    [self unschedule:@selector(generateBalloon)];
    [self removeAllBalloons];
    
    // 선택된 메뉴의 태그정보를 이용하여 어느 메뉴가 선택되었는지 식별
    switch (selectedMenu.tag) {
        case kTagPlayGameMenu:
            [self performSelector:@selector(levelSelectCallback) withObject:nil
                       afterDelay:0.4f];
            break;
        case kTagCreditMenu:
            [self performSelector:@selector(creditCallback) withObject:nil
                       afterDelay:0.4f];
            break;
        case kTagHowtoMenu:
        default:
            [self performSelector:@selector(howtoCallback) withObject:nil
                       afterDelay:0.4f];
            break;
    }
}

- (void) levelSelectCallback
{
	[SceneManager goLevelSelect];
}

- (void) creditCallback
{
	[SceneManager goCredit];
}

- (void) howtoCallback
{
	[SceneManager goHowto];
}

#define MENU_ITEM_OFFSET        (120)
#define MENU_ITEM_INIT_SCALE    (0.01f)

- (void)showTitle
{
    CCSprite *mainLabelSprite = [CCSprite spriteWithFile:@"main_balloon_pop.png"];
    [mainLabelSprite setPosition:ccpAdd(centerPt,ccp(0, MENU_ITEM_OFFSET))];
    mainLabelSprite.scale = MENU_ITEM_INIT_SCALE;
    [self addChild:mainLabelSprite z:500];
    
    id scaleUp1 = [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.3 scale:0.8]];
    [mainLabelSprite runAction:scaleUp1];
    
    id waitAction = [CCDelayTime actionWithDuration:4.5];
    id scaleUp2 = [CCScaleTo actionWithDuration:0.1 scale:1.1];
    id scaleDown1 = [CCScaleTo actionWithDuration:0.1 scale:0.92];
    id scaleUp3 = [CCScaleTo actionWithDuration:0.07 scale:1.05];
    id scaleDown2 = [CCScaleTo actionWithDuration:0.07 scale:0.8];
    
    id waitAndScale = [CCSequence actions:waitAction, scaleUp2, scaleDown1,
                       scaleUp3, scaleDown2, nil];
    id repeatWaitAndScale = [CCRepeatForever actionWithAction:waitAndScale];
    [mainLabelSprite runAction:repeatWaitAndScale];
    
    [self scheduleOnce:@selector(showMemoryTestBanner) delay:0.2];
    [self scheduleOnce:@selector(showMenu) delay:0.2];
}

- (void)showMainClouds
{
    CCSprite *cloudBgSprite = [CCSprite spriteWithFile:@"main_cloud.png"];
    // 메인 배경의 초기위치와 z 값 설정
    [cloudBgSprite setPosition:ccpAdd(centerPt,ccp(0, MENU_ITEM_OFFSET))];
    cloudBgSprite.scale = MENU_ITEM_INIT_SCALE;
    [self addChild:cloudBgSprite z:300];
    
    id scaleUp = [CCEaseElastic actionWithAction:[CCScaleTo actionWithDuration:0.2 scale:1.0]];
    [cloudBgSprite runAction:scaleUp];
    
    [self scheduleOnce:@selector(showTitle) delay:0.2];
}

- (void)showBalloons
{
    CCSprite *mainBalloonSprite = [CCSprite spriteWithFile:@"main_balloon.png"];
    // 메인 배경의 초기위치와 z 값 설정
    [mainBalloonSprite setPosition:ccpAdd(centerPt,ccp(0, MENU_ITEM_OFFSET))];
    mainBalloonSprite.scale = MENU_ITEM_INIT_SCALE;
    [self addChild:mainBalloonSprite z:400];
    
    id scaleUp = [CCEaseElastic actionWithAction:[CCScaleTo actionWithDuration:0.16 scale:1.0]];
    [mainBalloonSprite runAction:scaleUp];
    
    [self move:mainBalloonSprite withOffsetPt:ccp(2,4)];
    [self scheduleOnce:@selector(showTitle) delay:0.2];
}

- (void) showMemoryTestBanner
{
    CCSprite *memoryTestSprite = [CCSprite spriteWithFile:@"memorytrain.png"];
    // 메인 배경의 초기위치와 z 값 설정
    [memoryTestSprite setPosition:ccpAdd(centerPt,ccp(90, 60))];
    memoryTestSprite.scale = 0.01;
    [self addChild:memoryTestSprite z:700];
    
    id scaleUp = [CCEaseElastic actionWithAction:[CCScaleTo actionWithDuration:0.16 scale:1.4]];
    [memoryTestSprite runAction:scaleUp];
    
    [self move:memoryTestSprite withOffsetPt:ccp(2,4)];
}

#define MENU_LAYER_BACKGROUND       (@"bg_cloud.png")

// 메뉴 출력시 배경화면 설정
- (void)animateBackground
{
    CCSprite *bgSprite = [CCSprite spriteWithFile:MENU_LAYER_BACKGROUND];
    // 메인 배경의 초기위치와 z 값 설정
    [bgSprite setPosition:centerPt];
    [self addChild:bgSprite z:0 tag:kTagMenuLayerBackground];

    [self scheduleOnce:@selector(showMainClouds) delay:0.4];
}

// 메뉴 보이기
- (void)showMenu
{
    // 메뉴 출력 애니메이션
    // Play, Howto 메뉴가 있음
    CCSprite *playNormalBtn = [CCSprite spriteWithFile:@"btn_start.png"];
    CCSprite *playSelectedBtn = [CCSprite spriteWithFile:@"btn_start_s.png"];
    startMenuItem = [CCMenuItemSprite itemWithNormalSprite:playNormalBtn
                                            selectedSprite:playSelectedBtn
                                                    target:self
                                                  selector:@selector(doClick:)];
    startMenuItem.scale = MENU_ITEM_INIT_SCALE;
    startMenuItem.tag = kTagPlayGameMenu;
    
    CCSprite *howtoNormalBtn = [CCSprite spriteWithFile:@"btn_howto.png"];
    CCSprite *howtoSelectedBtn = [CCSprite spriteWithFile:@"btn_howto_s.png"];
    howtoMenuItem = [CCMenuItemSprite itemWithNormalSprite:howtoNormalBtn
                                            selectedSprite:howtoSelectedBtn
                                                    target:self
                                                  selector:@selector(doClick:)];
    howtoMenuItem.scale = MENU_ITEM_INIT_SCALE;
    howtoMenuItem.tag = kTagHowtoMenu;
    
    // premiumPurchased and extraLifePurchased then just Start and Howto Menu
    if (self.isAllItemPurchased == YES) {
        CCMenu *menu = [CCMenu menuWithItems:startMenuItem,
                        howtoMenuItem,
                        nil];
        [menu alignItemsVerticallyWithPadding:60];
        [menu setPosition:ccp(centerPt.x, centerPt.y-100)];
        [self addChild:menu z:1000];
    }
    else {
        CCMenu *menu = [CCMenu menuWithItems:startMenuItem,
                howtoMenuItem,
                nil];
        [menu alignItemsVerticallyWithPadding:55];
        [menu setPosition:ccp(centerPt.x, centerPt.y-100)];
        [self addChild:menu z:1000];
    }
    
    CCSprite *infoNormalBtn = [CCSprite spriteWithFile:@"btn_i.png"];
    CCSprite *infoSelectedBtn = [CCSprite spriteWithFile:@"btn_i_s.png"];
    infoMenuItem = [CCMenuItemImage itemWithNormalSprite:infoNormalBtn
                                          selectedSprite:infoSelectedBtn
                                                  target:self
                                                selector:@selector(doClick:)];
    infoMenuItem.tag = kTagCreditMenu;
    CCMenu *infoMenu = [CCMenu menuWithItems:infoMenuItem, nil];
    [infoMenu setPosition:ccpAdd(centerPt, ccp(140, 210))];
    [self addChild:infoMenu z:1000];

    // jump 액션의 애니메이션 시간들
    const ccTime jump1Time = 0.1f;
    const ccTime jump2Time = 0.08f;
    const ccTime jump3Time = 0.03f;
    
    // 전체 애니메이션 시간의 합을 구한다
    const ccTime totalAnimationTime = jump1Time + jump2Time + jump3Time;
    // 애니메이션 루프를 도는데 소요되는 시간
    const ccTime totalTime = 4.5f;
    const ccTime waitBeforeAction1Time = 2.0f;
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
    [startMenuItem runAction:repeatWaitAndMove1];
    
    ccTime waitBeforeAction2Time = waitBeforeAction1Time + delayInterval;
    ccTime waitAfterAction2Time = totalTime-(waitBeforeAction2Time + totalAnimationTime);
    id waitBeforeAction2 = [CCDelayTime actionWithDuration:waitBeforeAction2Time];
    id waitAfterAction2 = [CCDelayTime actionWithDuration:waitAfterAction2Time];
    id repeatWaitAndMove2 = [CCRepeatForever actionWithAction:[CCSequence actions:waitBeforeAction2, [seqAction copy], waitAfterAction2, nil]];
    [howtoMenuItem runAction:repeatWaitAndMove2];
    
    // add scale up action for menu item1-itemPlayGame
    id action1 = [self showScaleUpWithDelay:0.2];
    [startMenuItem runAction:action1];
    
    id action2 = [self showScaleUpWithDelay:0.3];
    [howtoMenuItem runAction:action2];
    
    id action4 = [self showScaleUpWithDelay:0.4];
    [infoMenuItem runAction:action4];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
