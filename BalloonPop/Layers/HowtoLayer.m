//
//  HowtoLayer.m
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 23..
//  Copyright (c) 2013년 DongGyu Park. All rights reserved.
//

#import "HowtoLayer.h"
#import "SceneManager.h"

#define BP_BG_MUSIC         (@"BP_gameBackground.mp3")
#define BP_POP_SOUND        (@"BP_pop_sound.wav")
#define BP_FAIL_SOUND        (@"BP_fail_sound.m4a")
#define BP_BG_MUSIC_VOL     (0.2)

#define BALLOON_GEN_INTERVAL (0.8f)

extern float clampRandomNumber(int min, int max);
extern float clampRandomNumberf(float min, float max);

@implementation HowtoLayer

// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        isMenuSelected = NO;
        appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        
        [self getScreenSize];
        
		// create and initialize a Label
		[self animateBackground];
        [self preloadSoundEffects];
        [self showMenu];
        
        // balloonGroup 노드 생성
        [self addBalloonGroup];
    }
	return self;
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

// 풍선을 저장할 arshape 배역을 만들고 풍선이 추가될 shapeGroup을 현재 레이어에 추가함
- (void)addBalloonGroup
{
    balloonGroup = [CCNode node];
    [self addChild:balloonGroup z:20 tag:kTagBalloonGroup];
    
    [self schedule:@selector(generateBalloon) interval:BALLOON_GEN_INTERVAL];
}

#define HOWTO_FONT           (@"Arial Rounded MT Bold")
#define HOWTO_FONT_SIZE     (18)


- (CCFontDefinition *)fontDefinition
{
    CCFontDefinition *tempDefinition = [[CCFontDefinition alloc]
                                        initWithFontName:HOWTO_FONT
                                        fontSize:HOWTO_FONT_SIZE];
    tempDefinition.dimensions    = CGSizeMake(0,0);
    tempDefinition.alignment     = kCCTextAlignmentLeft;
    tempDefinition.vertAlignment = kCCVerticalTextAlignmentTop;
    tempDefinition.lineBreakMode = kCCLineBreakModeWordWrap;
    
    [tempDefinition enableShadow:YES];
    
    // stroke
    [tempDefinition enableStroke:YES];
    [tempDefinition setStrokeColor:ccBLACK];
    [tempDefinition setStrokeSize:.5f];
    
    // fill color
    tempDefinition.fontFillColor = ccc3(250, 250, 9);
    
    return tempDefinition;
}

- (void)showInstuctions
{
    NSString *str = @"1. A simple and addictive memory\n train game\n\n2. On each level, a new Balloon\n will born and you have to find\n which and touch it.\n\n3. Higher level will show you a\n small number of colored \n Balloons";
    CCFontDefinition *fd = [self fontDefinition];
    
    CCLabelTTF *instruction = [CCLabelTTF labelWithString:str
                                           fontDefinition:fd];
//    CCLabelTTF *instruction = [CCLabelTTF labelWithString:str
//                                                 fontName:@"Arial Rounded MT Bold"
//                                                 fontSize:18];
    instruction.position = centerPt;
    instruction.color = ccWHITE;
    CCRenderTexture* stroke = [self createStroke:instruction size:2 color:ccBLUE];
    
    [self addChild:stroke z:200];
    [self addChild:instruction z:200];
}

- (void)showHowtoTitle
{
    CCSprite *howtoTitle = [CCSprite spriteWithFile:@"howto_title.png"];
    // 메인 배경의 초기위치와 z 값 설정
    [howtoTitle setPosition:ccpAdd(centerPt,ccp(0, 180))];
    howtoTitle.scale = 0.01;
    [self addChild:howtoTitle z:300 tag:kTagMenuLayerCloud];
    
    id scaleUp = [CCEaseElastic actionWithAction:[CCScaleTo actionWithDuration:0.2 scale:1.0]];
    [howtoTitle runAction:scaleUp];
    
    [self scheduleOnce:@selector(showInstuctions) delay:0.2];
}

#define HOWTO_LAYER_BACKGROUND    (@"bg_cloud.png")

// 메뉴 출력시 배경화면 설정
- (void)animateBackground
{
    CCSprite *bgSprite = [CCSprite spriteWithFile:HOWTO_LAYER_BACKGROUND];
    // 메인 배경의 초기위치와 z 값 설정
    [bgSprite setPosition:centerPt];
    [self addChild:bgSprite z:10 tag:kTagMenuLayerBackground];
    
    [self scheduleOnce:@selector(showHowtoTitle) delay:0.2];
}

// simple audio engine에서 이용한 사운드 효과를 미리 로딩함
- (void)preloadSoundEffects
{
    sae=[SimpleAudioEngine sharedEngine];
    [sae preloadBackgroundMusic:BP_BG_MUSIC];
    [sae preloadEffect:BP_POP_SOUND];
    [sae preloadEffect:BP_FAIL_SOUND];
}

// 메뉴 보이기
- (void)showMenu
{
    // 메뉴 출력 애니메이션
    // back 메뉴가 있음
    CCSprite *backNormalBtn = [CCSprite spriteWithFile:@"btn_back.png"];
    CCSprite *backSelectedBtn = [CCSprite spriteWithFile:@"btn_back_s.png"];
    CCMenuItem *backMenuItem = [CCMenuItemSprite itemWithNormalSprite:backNormalBtn
                                           selectedSprite:backSelectedBtn
                                                   target:self
                                                 selector:@selector(doClick:)];
    backMenuItem.scale = 0.01f;
    backMenuItem.tag = kTagBackToMainMenu;
    CCMenu *menu = [CCMenu menuWithItems:backMenuItem, nil];
    [menu setPosition:ccp(centerPt.x, centerPt.y-150)];
    
    // add scale up action for menu item1-itemPlayGame
    id action1 = [self showScaleUpWithDelay:0.8];
    [backMenuItem runAction:action1];
    
    // Add the menu to the layer
    [self addChild:menu z:100];
}

- (void)getScreenSize
{
    // 화면 크기와 화면의 중심좌표를 얻는다
    screenRect = [[UIScreen mainScreen] bounds];
    centerPt = CGPointMake(CGRectGetMidX(screenRect),
                           CGRectGetMidY(screenRect));
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
    if (isMenuSelected == YES) {
        return;
    }
    else {
        isMenuSelected = YES;
    }

    CCMenuItem *selectedMenu = (CCMenuItem *)sender;
    [sae playEffect:BP_POP_SOUND];
    
    [self removeAllBalloons];
    
    id menuSelectActions = [self menuSelectionAction];
    [selectedMenu runAction:menuSelectActions];
    
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
