//
//  CreditLayer.m
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2014. 1. 20..
//  Copyright (c) 2014년 DongGyu Park. All rights reserved.
//

#import "CreditLayer.h"
#import "SceneManager.h"

#define BP_BG_MUSIC         (@"BP_gameBackground.mp3")
#define BP_POP_SOUND        (@"BP_pop_sound.wav")
#define BP_FAIL_SOUND       (@"BP_fail_sound.m4a")
#define BP_BG_MUSIC_VOL     (0.2f)

extern float clampRandomNumber(int min, int max);
extern float clampRandomNumberf(float min, float max);

#define BALLOON_GEN_INTERVAL    (1.0f)

@implementation CreditLayer

// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        isMenuSelected = NO;
        appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        
        [self getScreenSize];
        
        // balloonGroup 노드 생성
        [self addBalloonGroup];
        
		// create and initialize a Label
		[self animateBackground];
        [self preloadSoundEffects];
        
        [self scheduleOnce:@selector(showTitle) delay:0.6];
        
        // 게임신 시작후 2초 경과한 다음 배경음이 시작된다-배경음이 바로 시작되면 이상함..
        [self performSelector:@selector(playBackgroundMusic)
                   withObject:nil
                   afterDelay:2];
        
        [self schedule:@selector(generateBalloon) interval:BALLOON_GEN_INTERVAL];
    }
    
    return self;
}
#define BP_CREDIT_TITLE_COLOR   (ccBlack)
#define BP_CREDIT_TITLE_FONT    (@"ChalkboardSE-Bold")
#define BP_CREDIT_TITLE_SIZE    (48)

- (void)showTitle
{
    CCLabelTTF *creditLabel = [CCLabelTTF labelWithString:@"CREDIT"
                                                 fontName:BP_CREDIT_TITLE_FONT
                                                 fontSize:BP_CREDIT_TITLE_SIZE];
    creditLabel.color = ccYELLOW;
    creditLabel.position = ccp(centerPt.x, centerPt.y+170);
    CCRenderTexture* stroke = [self createStroke:creditLabel
                                            size:1.0f
                                           color:ccBLACK];
    [self addChild:creditLabel z:1000];
    [self addChild:stroke z:creditLabel.zOrder-1];
    
    CCSprite *creditDesc = [CCSprite spriteWithFile:@"credit_desc.png"];
    // 메인 배경의 초기위치와 z 값 설정
    [creditDesc setPosition:ccp(centerPt.x,centerPt.y)];
    creditDesc.scale = 0.01;
    [self addChild:creditDesc z:999 tag:kTagCreditDesc];
    
    id scaleUp2 = [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.3
                                                                          scale:0.8]];
    [creditDesc runAction:scaleUp2];
    
    [self scheduleOnce:@selector(showMenu) delay:0.1];
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

#define CREDIT_LAYER_BACKGROUND    (@"bg_cloud.png")

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

// 메뉴 출력시 배경화면 설정
- (void)animateBackground
{
    CCSprite *bgSprite = [CCSprite spriteWithFile:CREDIT_LAYER_BACKGROUND];
    
    // 메인 배경의 초기위치와 z 값 설정
    [bgSprite setPosition:centerPt];
    [self addChild:bgSprite z:0 tag:kTagMenuLayerBackground];
}

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

// 메뉴 보이기
- (void)showMenu
{
    // 메뉴 출력 애니메이션
    // back 메뉴가 있음
    CCSprite *normalBackBtn = [CCSprite spriteWithFile:@"btn_back.png"];
    CCSprite *selectedBackBtn = [CCSprite spriteWithFile:@"btn_back_s.png"];
    CCMenuItem *backMenuItem = [CCMenuItemSprite itemWithNormalSprite:normalBackBtn
                                                       selectedSprite:selectedBackBtn
                                                               target:self
                                                             selector:@selector(doClick:)];
    backMenuItem.scale = 0.01f;
    backMenuItem.tag = kTagBackToMainMenu;
    
    CCMenu *menu = [CCMenu menuWithItems:backMenuItem, nil];
    [menu setPosition:ccp(centerPt.x, centerPt.y-160)];
    
    // add scale up action for menu item1-itemPlayGame
    id action1 = [self showScaleUpWithDelay:0.4];
    [backMenuItem runAction:action1];
    
    // Add the menu to the layer
    [self addChild:menu z:1000];
}

// 메뉴 클릭시의 애니메이션
- (void)doClick:(id)sender
{
    // prevent multiple selection
    if (isMenuSelected == YES)
        return;
    else
        isMenuSelected = YES;
    
    [self unschedule:@selector(generateBalloon)];
    [self removeAllBalloons];
    
    CCMenuItem *selectedMenu = (CCMenuItem *)sender;
    [selectedMenu runAction:[self menuSelectionAction]];
    [sae playEffect:BP_POP_SOUND];
    
    // 선택된 메뉴의 태그정보를 이용하여 어느 메뉴가 선택되었는지 식별
    switch (selectedMenu.tag) {
        case kTagBackToMenu:
        default:
            [self performSelector:@selector(backtoMenuCallback)
                       withObject:nil
                       afterDelay:0.4f];
            break;
    }
}

- (void) backtoMenuCallback
{
	[SceneManager goMenu];
}


@end
