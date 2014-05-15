//
//  GameOverLayer.m
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 23..
//  Copyright (c) 2013년 DongGyu Park. All rights reserved.
//

#import "GameOverLayer.h"
#import "SceneManager.h"

#define BP_BG_MUSIC         (@"BP_gameBackground.mp3")
#define BP_POP_SOUND        (@"BP_pop_sound.wav")
#define BP_FAIL_SOUND        (@"BP_fail_sound.m4a")
#define BP_BG_MUSIC_VOL     (0.2)

#define BALLOON_GEN_INTERVAL (0.8f)

extern float clampRandomNumber(int min, int max);
extern float clampRandomNumberf(float min, float max);

extern BOOL isGameCenterAPIAvailable();

@implementation GameOverLayer

@synthesize scoreLabel;
@synthesize tryMenuItem, backMenuItem, rankMenuItem, submitScoreMenuItem;
@synthesize menu;

#pragma mark -
#pragma mark Game Center Support

@synthesize _localPlayer;
 
// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        isMenuSelected = NO;
        appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        
        [self getScreenSize];
		[self preloadSoundEffects];
        
        if (isGameCenterAPIAvailable()) {
            [self authenticatePlayer];
        }
        
        // balloonGroup 노드 생성
        [self addBalloonGroup];
       
		// create and initialize a Label
		[self animateBackground];
        [self showTitle];
        
        
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

// 풍선을 저장할 arshape 배역을 만들고 풍선이 추가될 shapeGroup을 현재 레이어에 추가함
- (void)addBalloonGroup
{
    balloonGroup = [CCNode node];
    [self addChild:balloonGroup z:200 tag:kTagBalloonGroup];
    
    [self schedule:@selector(generateBalloon) interval:BALLOON_GEN_INTERVAL];
}

#define BALLOON_MIN_SIZE            (40/2)

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
    CCSprite *titleSprite = [CCSprite spriteWithFile:@"score_title.png"];
    titleSprite.position = ccpAdd(centerPt, ccp(0.0f, 150.0f));
    [self addChild:titleSprite z:300 tag:kTagTitleSprite];
    
    [self scheduleOnce:@selector(showScore) delay:0.9];
}

#define BP_SCORE_LABEL_COLOR          ccc3(0, 40, 210)
#define BP_SCORE_FONT                 (@"ChalkboardSE-Bold")
#define BP_SCORE_FONT_SIZE            (48)

-(CCFontDefinition *)scoreFontDefinition
{
    CCFontDefinition *fd = [[CCFontDefinition alloc] init];
    [fd setFontName:BP_SCORE_FONT];
    [fd setFontSize:BP_SCORE_FONT_SIZE];
    [fd setDimensions:CGSizeMake(200,400)];
    [fd setFontFillColor:ccc3(255,255,255)];
    
    CGSize shadowOffset;
    shadowOffset.width  = 1;
    shadowOffset.height = -1;
    [fd enableShadow:true];
    [fd setShadowBlur:0.0];
    [fd setShadowOffset:shadowOffset];
    
    return fd;
}

- (void) showScore
{
    NSInteger gameScore = appDelegate.gameScore;
    CCNode *outlineLabelNode = [CCNode node];
    outlineLabelNode.position = centerPt;

    // 점수표시를 위하여 회색 배경을 화면에 깔아준다
    CCSprite *titleSprite = [CCSprite spriteWithFile:@"score_bg.png"];
    titleSprite.position = centerPt;
    titleSprite.opacity = 200;
    titleSprite.scale = 0.01;
    titleSprite.color = ccc3(70, 70, 60);
    [self addChild:titleSprite z:400 tag:kTagScoreBackground];
    id action1 = [self showScaleUpWithDelay:0.1];
    [titleSprite runAction:action1];
    
    CCFontDefinition *fd = [self scoreFontDefinition];
    NSString *scoreString = [NSString stringWithFormat:@"%05ld", (long)gameScore];
    self.scoreLabel = [CCLabelTTF labelWithString:scoreString
                                   fontDefinition:fd];
    [outlineLabelNode addChild:self.scoreLabel z:1000 tag:kTagGameOverScoreLabel];
    
    // 아웃라인 스코어 스트로크를 생성하여
    CCRenderTexture* scoreStroke = [self createStroke:self.scoreLabel
                                                 size:3
                                                color:ccc3(30, 40, 50)];
    [outlineLabelNode addChild:scoreStroke z:scoreLabel.zOrder-1];
    
    outlineLabelNode.scale = 0.01;
    id action2 = [self showScaleUpWithDelay:0.2];
    [outlineLabelNode runAction:action2];
    
    // 현재 Layer에 outlineLabel 노드를 추가하여 점수를 표시함
    [self addChild:outlineLabelNode z:1000];
}

#define GAME_OVER_LAYER_BACKGROUND      (@"bg_cloud.png")

// 메뉴 출력시 애니메이션
- (void)animateBackground
{
    CCSprite *bgSprite = [CCSprite spriteWithFile:GAME_OVER_LAYER_BACKGROUND];
    // 메인 배경의 초기위치와 z 값 설정
    [bgSprite setPosition:centerPt];
    [self addChild:bgSprite z:0 tag:kTagGameOverLayerBackground];
    
    [self scheduleOnce:@selector(showMenu) delay:0.6];
}

// simple audio engine에서 이용한 사운드 효과를 미리 로딩함
- (void)preloadSoundEffects
{
    sae=[SimpleAudioEngine sharedEngine];
    [sae preloadBackgroundMusic:BP_BG_MUSIC];
    [sae preloadEffect:BP_POP_SOUND];
    [sae preloadEffect:BP_FAIL_SOUND];
}

#define INITIAL_MENU_SCALE  (0.01)

// 메뉴 보이기
- (void)showMenu
{
    // 메뉴 출력 애니메이션
    // Play, Howto 메뉴가 있음
    CCSprite *tryNormalBtn = [CCSprite spriteWithFile:@"btn_tryagain.png"];
    CCSprite *trySelectedBtn = [CCSprite spriteWithFile:@"btn_tryagain_s.png"];
    tryMenuItem = [CCMenuItemSprite itemWithNormalSprite:tryNormalBtn
                                          selectedSprite:trySelectedBtn
                                                  target:self
                                                selector:@selector(doClick:)];
    tryMenuItem.position = ccp(-75.0f, -120.0f);
    tryMenuItem.scale = INITIAL_MENU_SCALE;
    tryMenuItem.tag = kTagTryAgainMenu;
    
    CCSprite *rankNormalBtn = [CCSprite spriteWithFile:@"btn_ranking.png"];
    CCSprite *rankSelectedBtn = [CCSprite spriteWithFile:@"btn_ranking_s.png"];
    rankMenuItem = [CCMenuItemSprite itemWithNormalSprite:rankNormalBtn
                                           selectedSprite:rankSelectedBtn
                                                   target:self
                                                 selector:@selector(doClick:)];
    rankMenuItem.position = ccp(75.0f, -120.0f);
    rankMenuItem.scale = INITIAL_MENU_SCALE;
    rankMenuItem.tag = kTagRankingMenu;

    CCSprite *submitScoreNormalBtn = [CCSprite spriteWithFile:@"btn_submit.png"];
    CCSprite *submitScoreSelectedBtn = [CCSprite spriteWithFile:@"btn_submit_s.png"];
    submitScoreMenuItem = [CCMenuItemSprite itemWithNormalSprite:submitScoreNormalBtn
                                           selectedSprite:submitScoreSelectedBtn
                                                   target:self
                                                 selector:@selector(doClick:)];
    submitScoreMenuItem.position = ccp(-75.0f, -170.0f);
    submitScoreMenuItem.scale = INITIAL_MENU_SCALE;
    submitScoreMenuItem.tag = kTagSubmitScoreMenu;
    
    CCSprite *backNormalBtn = [CCSprite spriteWithFile:@"btn_back.png"];
    CCSprite *backSelectedBtn = [CCSprite spriteWithFile:@"btn_back_s.png"];
    backMenuItem = [CCMenuItemSprite itemWithNormalSprite:backNormalBtn
                                            selectedSprite:backSelectedBtn
                                                    target:self
                                                  selector:@selector(doClick:)];
    backMenuItem.position = ccp(75.0f, -170.0f);
    backMenuItem.scale = INITIAL_MENU_SCALE;
    backMenuItem.tag = kTagBackToMainMenu;
    
    menu = [CCMenu menuWithItems:
            tryMenuItem, backMenuItem,
            submitScoreMenuItem, rankMenuItem, nil];
    [menu setPosition:ccp(centerPt.x, centerPt.y)];
    [self addChild:menu z:1000];
    
    // add scale up action for menu items
    id action1 = [self showScaleUpWithDelay:0.2];
    [tryMenuItem runAction:action1];
    
    id action2 = [self showScaleUpWithDelay:0.3];
    [rankMenuItem runAction:action2];
    
    id action3 = [self showScaleUpWithDelay:0.4];
    [submitScoreMenuItem runAction:action3];
    
    id action4 = [self showScaleUpWithDelay:0.5];
    [backMenuItem runAction:action4];
}

- (void) backtoMenuCallback: (id) sender
{
    //	[sae playEffect:HOWTO_MENU_TRANSITION_SOUND];
    //
    //	[[self appController] removeBannerAd];
	[SceneManager goMenu];
}

- (void) tryAgainMenuCallback: (id) sender
{
    //	[sae playEffect:HOWTO_MENU_TRANSITION_SOUND];
    //
    //	[[self appController] removeBannerAd];
	[SceneManager goGame];
}

- (void) presentLeaderboards
{
    __block id copy_self = self;

    GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gameCenterController.leaderboardIdentifier =[self gameCategory];
    gameCenterController.gameCenterDelegate = copy_self;
    [[[appDelegate window] rootViewController] presentViewController:gameCenterController
                                                            animated:YES
                                                          completion:nil];
}

- (void) submitScoreMenuCallback: (id) sender
{
    // send game score to game center
    [self sendScoreToGameCenter];
    
    [self presentLeaderboards];
}

- (void) rankingMenuCallback: (id) sender
{
    [self presentLeaderboards];
}

- (void)removeAllBalloons
{
    // 플레이 모드를 off 시킨다
    // 모든 arshape 배열의 객체를 invisible로 만든다.
    for(Balloon *balloon in [balloonGroup children]) {
        [balloon pop];
    }
}
// 메뉴 클릭시의 애니메이션
- (void)doClick:(id)sender
{
    CCMenuItem *selectedMenu = (CCMenuItem *)sender;
    [selectedMenu runAction:[self menuSelectionAction]];
    [sae playEffect:BP_POP_SOUND];
    
    if (isMenuSelected == YES) {
        return;
    }
    else {
        isMenuSelected = YES;
    }
    
    [self removeAllBalloons];
    
    // 선택된 메뉴의 태그정보를 이용하여 어느 메뉴가 선택되었는지 식별
    switch (selectedMenu.tag) {
        case kTagTryAgainMenu:
            [self performSelector:@selector(tryAgainMenuCallback:)
                       withObject:nil
                       afterDelay:0.2f];
            break;
        case kTagRankingMenu:
            [self performSelector:@selector(rankingMenuCallback:)
                       withObject:nil
                       afterDelay:0.2f];
            break;
        case kTagSubmitScoreMenu:
            [self performSelector:@selector(submitScoreMenuCallback:)
                       withObject:nil
                       afterDelay:0.2f];
            break;
        case kTagBackToMainMenu:
        default:
            [self performSelector:@selector(backtoMenuCallback:) withObject:nil
                       afterDelay:0.2f];
            break;
    }
}

#define     LEADERBD_ID_EASY    @"grp.balloonpop.memory.easy"
#define     LEADERBD_ID_MEDIUM  @"grp.balloonpop.memory.medium"
#define     LEADERBD_ID_HARD    @"grp.balloonpop.memory.hard"
#define     LEADERBD_ID_EXPERT  @"grp.balloonpop.memory.expert"

- (NSString *) gameCategory
{
    NSString *leaderboardID ;
    
    switch (appDelegate.gameLevel) {
        case BP_LEVEL_EXPERT:
            leaderboardID = LEADERBD_ID_EXPERT;
            break;
        case BP_LEVEL_HARD:
            leaderboardID = LEADERBD_ID_HARD;
            break;
        case BP_LEVEL_MEDIUM:
            leaderboardID = LEADERBD_ID_MEDIUM;
            break;
        case BP_LEVEL_EASY:
        default:
            leaderboardID = LEADERBD_ID_EASY;
            break;
    }
    
    return leaderboardID;
}

// 게임센터 서버로 점수를 보낸다.
- (void) sendScoreToGameCenter
{
    NSString *gameCategory = [self gameCategory];
    GKScore* score = [[GKScore alloc] initWithLeaderboardIdentifier:gameCategory];
    
    // 위에서 kPoint가 게임센터에서 설정한 Leaderboard ID
    int64_t gcScore = appDelegate.gameScore;
    score.value = gcScore;
    score.context = 0;
    
    NSArray *balloonPopMemoryScores = [NSArray arrayWithObjects:score, nil];
    
    // 아래는 게임에 score를 report하는 메소드이다.
    [GKScore reportScores:balloonPopMemoryScores withCompletionHandler:^(NSError *error){
        NSLog(@"score report error : %@", error.localizedDescription);
    }];
}

#pragma mark --
#pragma mark - Player Authentication

- (void)authenticatePlayer
{
    // localPlayer is the public GKLocalPlayer
    // 게임센터에 접속할 수 있는 플레이어 객체-한 번에 한 플레이어만 접속 가능함.
    // localPlayer 메소드는 클래스 메소드로 현재 player 객체를 반환함
    _localPlayer = [GKLocalPlayer localPlayer];
    GKLocalPlayer *weakPlayer = _localPlayer;
    __block id copy_self = self;
    
    // 게임 플레이어의 인증 요청이 들어올때 호출되는 핸들러
    weakPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if (viewController != nil)
        {
            // 인증 다이얼로그를 화면에 출력함
            [copy_self showAuthenticationDialogWhenReasonable:viewController];
        }
        else if (weakPlayer.isAuthenticated)
        {
            // 인증이 이루어지면 weakPlayer가 localPlayer가 된다
            [copy_self authenticatedPlayer:weakPlayer];
            
            // 인증을 받았을 경우 게임센터 뷰 컨트롤러를 present함
            GKGameCenterViewController* gcvc =[[GKGameCenterViewController alloc] init];
            gcvc.viewState = GKGameCenterViewControllerStateLeaderboards;
            gcvc.gameCenterDelegate = self;
            
            UIViewController *vc = [[appDelegate window] rootViewController];
			[vc presentViewController:gcvc animated:YES completion:nil];
            
			[gcvc release];
        }
        else
        {
            [copy_self disableGameCenter];
        }
    };
}

- (void)showAuthenticationDialogWhenReasonable:(UIViewController *)controller
{
    [[[appDelegate window] rootViewController] presentViewController:controller
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
    
    isMenuSelected = NO;
}

@end
