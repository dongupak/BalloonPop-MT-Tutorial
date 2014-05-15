//
//  GameLayer.m
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 23..
//  Copyright (c) 2013년 DongGyu Park. All rights reserved.
//

#import "GameLayer.h"
#import "SceneManager.h"
#import "BPStrokeLabel.h"

#define BALLOON_OPACITY     (210)
#define BALLOON_INIT_SCALE  (0.01f)

#define BALLOON_MIN_SIZE        (48/2)
#define BALLOON_SCALE_FACTOR    (1.5f)

#define NUM_OF_PLAYER_LIFE  (3)     // 게임 플레이어의 라이프 수
#define INIT_SCORE          (0)

#define BP_BG_MUSIC         (@"BP_gameBackground.mp3")
#define BP_POP_SOUND        (@"BP_pop_sound.wav")
#define BP_FAIL_SOUND       (@"BP_fail_sound2.m4a")
#define BP_GAMEOVER_SOUND   (@"BP_gameover.m4a")

#define BP_BG_MUSIC_VOL     (0.2)

extern float clampRandomNumber(int min, int max);
extern float clampRandomNumberf(float min, float max);

@implementation GameLayer

@synthesize scoreLabel, lifeLabel, scoreStroke;
@synthesize message;

// on "init" you need to initialize your instance
- (id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if((self=[super init])) {
        
        appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        BP_STROKE_COLOR = ccBLACK;
        BP_LABEL_COLOR = ccWHITE;
        
        [self getScreenSize];
        [self initGameScore];
                
        // init gamelayer vars
        [self initGameVars];
        
        // 현재 layer를 touch 가능한 상태로 활성화 함
        [self setTouchEnabled:YES];
        // Balloon group 객체를 장면에 추가함
        [self addBalloonGroup];
        [self createClouds];

		[self animateBackground];
        [self preloadSoundEffects];

        [self initBalloon];
        [self createMessageNode];
        
        // create and initialize Labels
        [self createScoreAndLife];
        [self createCloudBackground];
        [self createEnergyBar];
        
        // 게임신 시작후 2초 경과한 다음 배경음이 시작된다-배경음이 바로 시작되면 이상함..
        [self performSelector:@selector(playBackgroundMusic)
                   withObject:nil
                   afterDelay:2];
        
        // 2.0초 지난 후 부터 타이머를 갱신한다.
        // 타이머를 통해 게임에서 풍선 터치 시간을 측정한다.
        [self scheduleOnce:@selector(startTimer) delay:2.0f];
	}
	return self;
}


// 풍선을 저장할 arshape 배역을 만들고 풍선이 추가될 shapeGroup을 현재 레이어에 추가함
- (void)createClouds
{
    cloudGroup = [CCNode node];
    [self addChild:cloudGroup z:200];
    
    // 일정 시간 간격으로 배경 구름을 생성함
    [self schedule:@selector(generateCloud) interval:7.0];
}

- (void) startTimer
{
    [self schedule:@selector(updateTimer:)
          interval:0.1
            repeat:kCCRepeatForever
             delay:0.0];
}

#pragma mark -
#pragma mark initGameVars

// appdelegate의 gameScore를 0으로 초기화한다
- (void)initGameScore
{
    // AppController의 gameScore도 동시에 초기화시킨다.
    appDelegate.gameScore = gameScore = INIT_SCORE;
}

// 현재 레이어에서 사용할 변수들을 초기화 한다
- (void)initGameVars
{
    comboCount = 0;
    numOfLife = NUM_OF_PLAYER_LIFE;

    isPlaying = YES;
    delayTime = 0.0f;
}

// 풍선을 저장할 balloonArray 배열을 만들고 풍선이 추가될 balloonGroup을 현재 레이어에 추가함
- (void)addBalloonGroup
{
//    balloonArray = [[NSMutableArray alloc] init];
    balloonGroup = [CCNode node];
    [self addChild:balloonGroup z:2000 tag:kTagBalloonGroup];
}

- (void)getScreenSize
{
    // 화면 크기와 화면의 중심좌표를 얻는다
    screenRect = [[UIScreen mainScreen] bounds];
    centerPt = CGPointMake(CGRectGetMidX(screenRect),
                           CGRectGetMidY(screenRect));
}

#pragma mark -
#pragma mark GameLayer Score font description

#define BP_LABEL_TOP_OFFSET     (20)
#define BP_SCORE_FONT           (@"ChalkboardSE-Bold")
#define BP_SCORE_FONT_SIZE      (18)

- (void) createScoreAndLife
{
    CGFloat yPos = screenRect.size.height-BP_LABEL_TOP_OFFSET;
    
    // static "SCORE : " text
    CCLabelTTF *scoreDisplay= [CCLabelTTF labelWithString:@"SCORE :"
                                         fontName:BP_SCORE_FONT
                                         fontSize:BP_SCORE_FONT_SIZE];
    scoreDisplay.color = BP_LABEL_COLOR;
    scoreDisplay.position = ccp(40, yPos);
    CCRenderTexture* stroke = [self createStroke:scoreDisplay
                                            size:1.0f
                                           color:BP_STROKE_COLOR];
    [self addChild:scoreDisplay z:1000];
    [self addChild:stroke z:scoreDisplay.zOrder-1];
    
    // 점수를 표시할 레이블(CCLabel)을 만듭니다.
    // 처음에 보일 스트링으로 Score: 000000을 사용합니다.
    NSString *scoreString = [NSString stringWithFormat:@"%05d", gameScore];
    self.scoreLabel = [CCLabelTTF labelWithString:scoreString
                                         fontName:BP_SCORE_FONT
                                         fontSize:BP_SCORE_FONT_SIZE];
    self.scoreLabel.position = ccp(110, yPos);
    self.scoreLabel.color = BP_LABEL_COLOR;
    self.scoreStroke = [self createStroke:self.scoreLabel
                                     size:1.0f
                                    color:BP_STROKE_COLOR];
    [self addChild:self.scoreLabel z:1000];
    [self addChild:scoreStroke z:scoreLabel.zOrder-1];
    
    CCSprite *scoreLabelBgSprite = [CCSprite spriteWithFile:@"score_bg.png"];
    scoreLabelBgSprite.scaleX = 0.60f;
    scoreLabelBgSprite.scaleY = 0.27f;
    scoreLabelBgSprite.color = ccc3(70, 70, 60);
    scoreLabelBgSprite.position = ccp(self.scoreLabel.position.x-40, yPos-2);
    [self addChild:scoreLabelBgSprite z:self.scoreLabel.zOrder-1];
    
    // 풍선 2-4개를 life 표시용으로 사용함
    CGPoint lifeBalloonInitPos = ccp(165, yPos);
    
    lifeBalloon1 = [[Balloon alloc] init];
    lifeBalloon1.position = ccpAdd(lifeBalloonInitPos, ccp(0,-3));
    lifeBalloon1.scale = 0.7f;
    [self addChild:lifeBalloon1 z:1000];
    
    lifeBalloon2 = [[Balloon alloc] init];
    lifeBalloon2.position = ccpAdd(lifeBalloonInitPos, ccp(15,-3));
    lifeBalloon2.scale = 0.7f;
    [self addChild:lifeBalloon2 z:1001];
    
    lifeBalloon3 = [[Balloon alloc] init];
    lifeBalloon3.position = ccpAdd(lifeBalloonInitPos, ccp(30,-3));;
    lifeBalloon3.scale = 0.7f;
    [self addChild:lifeBalloon3 z:1002];
}

- (void) playBackgroundMusic
{
    // test 중에는 off
    [sae playBackgroundMusic:BP_BG_MUSIC];
    sae.backgroundMusicVolume = BP_BG_MUSIC_VOL;
}

#pragma mark -
#pragma mark Add messageNode to current layer

- (void) createMessageNode
{
    // 메시지 노드를 만들어 장면에 추가시킨다
    self.message = [MessageNode node];
    [self addChild:self.message z:3200 tag:kTagMessage];
}

#define BP_AD_OFFSET   (50)

- (void)initBalloon
{
    // get random position from current screen size
    float xPos = clampRandomNumber(BALLOON_MIN_SIZE,
                                   screenRect.size.width-BALLOON_MIN_SIZE);
    float yPos = clampRandomNumber(BP_AD_OFFSET,
                                   screenRect.size.height - BP_AD_OFFSET);
    
    // 최초 랜덤 위치에 balloon 객체를 생성하여 배열객체에 멤버로 삽입한 후
    // balloonGroup의 하위 노드로 추가한다
    Balloon *balloon = [[Balloon alloc] initWithLocation:CGPointMake(xPos, yPos)];
    balloon.scale = BALLOON_SCALE_FACTOR;  // 약간 크게하여 난이도에 따라 축소시킨다.
    balloon.opacity = BALLOON_OPACITY;
    balloon.tag = kTagLastBalloon;
    [balloon moveRandomUpDown];                 // moving left and right
    [balloonGroup addChild:balloon];
    
    [self resetGameTimer];
}

#define GAME_LAYER_BACKGROUND   (@"bg_empty.png")

// 메뉴 출력시 애니메이션
- (void)animateBackground
{
    gameLayerBgSprite = [CCSprite spriteWithFile:GAME_LAYER_BACKGROUND];
    // 메인 배경의 위치는 화면이 중앙으로 설정
    [gameLayerBgSprite setPosition:centerPt];
    [self addChild:gameLayerBgSprite z:0 tag:kTagGameLayerBackground];
}

// simple audio engine에서 이용한 사운드 효과를 미리 로딩함
- (void)preloadSoundEffects
{
    sae=[SimpleAudioEngine sharedEngine];
    [sae preloadBackgroundMusic:BP_BG_MUSIC];
    [sae preloadEffect:BP_POP_SOUND];
    [sae preloadEffect:BP_FAIL_SOUND];
    [sae preloadEffect:BP_GAMEOVER_SOUND];
}

#pragma mark -
#pragma mark Touch Event Handling

// 사용자 입력이 들어올 경우, 마지막 풍선인지, 그냥 풍선인지, 바탕화면 터치인지를 구별함

-(TouchObjectType)getTouchObjectType:(UITouch *)touch
{
    CGPoint convertedTouchPt = [self convertedTouchPoint:touch];
    
    // 모든 풍선에 대해서 조사해서 ...
    for (Balloon *balloon in [balloonGroup children]) {
        if (CGRectContainsPoint(balloon.boundingBox, convertedTouchPt))
        {
            if (balloon.tag == kTagLastBalloon)
                return LAST_GEN_BALLOON_TOUCH;
            else
                return NORMAL_GEN_BALLOON_TOUCH;
        }
    }

    // 풍선이 없는 배경 부분을 터치함
    return BACKGROUND_TOUCH;
}

- (void) showLastBalloonWithEffects
{
    // 마지막 풍선을 구해서 그 풍선에 효과를 준다.
    Balloon *balloon = [self findLastBalloon];
    
    // 마지막 풍선을 화면에서 알려주는 효과
    CCSequence *seqAction = [CCSequence actions:
                             [CCScaleTo actionWithDuration:0.3 scale:1.3],
                             [CCScaleTo actionWithDuration:0.2 scale:0.8],
                             [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:0],
                             [CCScaleTo actionWithDuration:0.3 scale:2.5],
                             [CCScaleTo actionWithDuration:0.2 scale:0.7],
                             [CCScaleTo actionWithDuration:0.3 scale:1.3],
                             [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:255],
                             [CCScaleTo actionWithDuration:0.2 scale:0.8],
                             [CCScaleTo actionWithDuration:0.3 scale:2.5],
                             [CCScaleTo actionWithDuration:0.2 scale:0.7],
                             [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:0],
                             [CCScaleTo actionWithDuration:0.2 scale:BALLOON_SCALE_FACTOR],
                             [CCTintTo actionWithDuration:0.1f red:255 green:255 blue:255],
                             nil];
    CCEaseBackInOut *showDown = [CCEaseBackInOut actionWithAction:seqAction];
    [balloon runAction:showDown];
}

#define BALLOON_WIDTH       (20)
#define BALLOON_HEIGHT      (20)

// 풍선이 무한히 많이 생기는 것을 방지하기 위해 최대 200개의 풍선만 허용
#define MAX_BALLOON_COUNT   (200)

- (void)addNewBalloon
{
    float xPos, yPos;
    BOOL isOverlapped = YES;
    CGRect newBalloonRect;
    
    if ([[balloonGroup children] count] > MAX_BALLOON_COUNT) {
        Balloon *ball = [[balloonGroup children] objectAtIndex:0];
        [ball removeFromParent];
    }
    
    while(isOverlapped == YES) {
        // generate random position
        xPos = clampRandomNumber(BALLOON_MIN_SIZE,
                                 screenRect.size.width-BALLOON_MIN_SIZE);
        yPos = clampRandomNumber(BP_AD_OFFSET,
                                 screenRect.size.height-BP_AD_OFFSET);
        
        // balloon이 그려질 사각영역을 미리 구한다
        newBalloonRect = CGRectMake(xPos-BALLOON_WIDTH/2,yPos-BALLOON_HEIGHT/2,
                                    BALLOON_WIDTH, BALLOON_HEIGHT);
        // 겹치지 않는다고 가정함
        isOverlapped = NO;
        
        
        // 기존 balloon의 영역과 겹치는가 검사한다
        for (Balloon *bal in [balloonGroup children]) {
            // 기존 balloon의 태그는 모두 kTagNormalBalloon으로 변경한다
            bal.tag = kTagNormalBalloon;
            // 기존 객체와 겹쳐지면 새 좌표를 구한다
            if (CGRectIntersectsRect(bal.boundingBox, newBalloonRect)) {
                // for문을 중단하고 break 한다
                // 겹쳐졌으므로 newRectOverlapped = YES;가 되어 바깥의 while loop은 반복됨
                isOverlapped = YES;
                break;
            }
        }
    }
    
    // randomize Z order
    // otherwise, new balloon will hide old balloon
    NSInteger randZOrder = (NSInteger)clampRandomNumber(100, 500);
    
    // x, y는 검사를 통해 중복되지 않음이 확인되었으므로 이 것을 새 balloon의 좌표로 사용
    Balloon *balloon = [[Balloon alloc] initWithLocation:CGPointMake(xPos, yPos)];
    balloon.scale = BALLOON_INIT_SCALE;
    balloon.opacity = BALLOON_OPACITY;
    balloon.visible = NO;  // 생성시점에는 눈에 안보임
    // 새 balloon은 tag를 kTagLastBalloon으로 설정한다
    balloon.tag = kTagLastBalloon;
    // 장면그래프에 balloonGroup의 자식으로 balloon을 삽입함
    [balloonGroup addChild:balloon z:randZOrder];
    
    [balloon moveRandomUpDown];
    
    [self scheduleOnce:@selector(redrawAllBalloons) delay:0.0f];
}

- (void)removeAllBalloons
{
    // 플레이 모드를 off 시킨다
    isPlaying = NO;
    
    // 모든 arballoon 배열의 객체를 pop시킨다.
    for(Balloon *balloon in [balloonGroup children]) {
        [balloon pop];
    }
    
    // 1.2초 후에는 새 balloon을 생성한다
    [self scheduleOnce:@selector(addNewBalloon) delay:1.0f];
}

- (void)resetGameTimer
{
    // 게임 타이머가 reset되어 게임이 시작됨
    isPlaying = YES;
    
    // delayTime이 0이 되면 게임 타이머가 다시 리셋됨
    delayTime = 0.0f;
    [self updateTimerBar:100];
}

- (void)redrawAllBalloons
{
    // 모든 balloon 객체를 모두 안보이게 매우 작은 스케일로 만들었다가
    // 잠시후 화면에 scale up 시킨다
    for (Balloon *balloon in [balloonGroup children]) {
        // balloon의 displayFrame을 첫 프레임으로 설정하기 위해
        // 스프라이트와 스프라이트 프레임을 읽어온다 - 효율적인 코드로 수정요..
        CCSprite *sprite = [CCSprite spriteWithFile:balloon.spriteFileName];
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:sprite.texture
                                                          rect:balloon.balloonRect];
        [balloon setDisplayFrame:frame];
        balloon.scale = BALLOON_INIT_SCALE;
        balloon.visible = YES;
        
        CCSequence *seqAction = [CCSequence actions:
                                 [CCScaleTo actionWithDuration:0.2 scale:1.9],
                                 [CCScaleTo actionWithDuration:0.2 scale:0.9],
                                 [CCScaleTo actionWithDuration:0.1 scale:BALLOON_SCALE_FACTOR],
                                 nil];
        CCEaseBackInOut *showUp = [CCEaseBackInOut actionWithAction:seqAction];
        
        [balloon runAction:showUp];
    }
    
    [self resetGameTimer];
}

#pragma mark - gameOver

- (void)gotoGameOverLayer
{
    [SceneManager goGameOver];
}

- (void) gameOver
{
    // 배경음악 종료
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	
    // 더 이상 사용되지않는 그래픽 캐시를 지웁니다.
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
    // 점수가 -가 되지 않도록 검사하고 값을 appDelegate에게 전달한다
    if ( gameScore < 0) gameScore = 0;
    
    appDelegate.gameScore = gameScore;
    
    // 약간의 지연을 두고 게임 종료 장면으로 이동한다
    [self performSelector:@selector(gotoGameOverLayer)
			   withObject:nil
               afterDelay:4.1];
}

#define CLOUD_MIN_SIZE          (90)
#define CLOUD_OPACITY           (200)

- (void)generateCloud
{
    NSInteger   screenWidth = (NSInteger)screenRect.size.width;
    NSInteger   screenHeight = (NSInteger)screenRect.size.height;
    
    // get random position from current screen size
    float xPos = screenWidth + CLOUD_MIN_SIZE;
    float yPos = clampRandomNumber(screenHeight/6, screenHeight-screenHeight/6);
    float dstXPos = -CLOUD_MIN_SIZE;
    float dstYPos = yPos + clampRandomNumber(-50, 50); // outside of the screen
    
    NSInteger randIndex = clampRandomNumberf(1, 4);
    NSString *str = [NSString stringWithFormat:@"bg_cloud%d.png",randIndex];
    CCSprite *cloudSprite = [CCSprite spriteWithFile:str];
    cloudSprite.scale = clampRandomNumberf(0.5, 1.2);
    cloudSprite.position = ccp(xPos, yPos);
    cloudSprite.opacity = clampRandomNumber(200, 220);  // 약간의 투명 설정
    [cloudGroup addChild:cloudSprite z:100 tag:kTagCloud];
    
    // moving time from bottom to top
    CGFloat moveDuration = clampRandomNumber(14,38);
    id moveToTop = [CCMoveTo actionWithDuration:moveDuration
                                       position:ccp(dstXPos, dstYPos)];
    CCCallBlock *removeFromLayer = [CCCallBlock actionWithBlock:^(void){
        [cloudSprite removeFromParent];
    }];
    id moveSeq = [CCSequence actions:moveToTop, removeFromLayer, nil];
    [cloudSprite runAction:moveSeq];
}

- (void)timeOver
{
    isPlaying = NO;
    [sae playEffect:BP_FAIL_SOUND];
    [self wrongBalloonTouch];
}

// 일정시간마다 타이머를 업데이트 시킴
- (void)updateTimer:(ccTime)delta
{
    const float speedControl = 10.0f;
    
    // 게임이 플레이 모드이면 에너지 바를 감소시킨다.
    if (isPlaying) {
        delayTime += (delta*speedControl);
        
        float energy = 100.0f - delayTime;
        [self updateTimerBar:energy];
        
        // 주어진 시간내에 마지막 풍선을 찾지 못함
        if (energy <= 0.0f) {
            delayTime = 0.0f;   // reset delayTime
            [self timeOver];
        }
    }
}

- (void)updateGameScore
{
    // 기본 점수를 더하고
    gameScore += 100;
    // delay Time이 적을수록 고득점을 추가 획득
    gameScore += (100 - delayTime);
    
    NSString *str = [NSString stringWithFormat:@" %05d", gameScore];
    [self.scoreLabel setString:str];
    self.scoreLabel.color = BP_LABEL_COLOR;
    [self removeChild:self.scoreStroke];
    
    self.scoreStroke = [self createStroke:self.scoreLabel
                                     size:1.0f
                                    color:BP_STROKE_COLOR];
    [self addChild:self.scoreStroke];
    
    CCLabelTTF *tmpScoreLabel = [CCLabelTTF labelWithString:str
                                              fontName:BP_SCORE_FONT
                                              fontSize:20];
    tmpScoreLabel.color = ccWHITE;
    tmpScoreLabel.position = self.scoreLabel.position;
    [self addChild:tmpScoreLabel z:self.scoreLabel.zOrder+1 tag:kTagScoreLabel];
    
    // 점수가 업데이트 되면서 Scale & FadeOut 액션을 수행
    id scaleActionWithFade = [CCSpawn actions:
                              [CCScaleTo actionWithDuration:0.5 scale:2.3],
                              [CCFadeOut actionWithDuration:0.5],
                                                            nil];
    id seqAction = [CCSequence actions:scaleActionWithFade,
                    [CCCallBlock actionWithBlock:^(void){
                        [tmpScoreLabel removeFromParent];
                    }],
                    nil];

    [tmpScoreLabel runAction:seqAction];
}

#pragma mark -
#pragma mark Cloud generation

- (void)createCloudWithSize:(int)imgSize top:(int)imgTop fileName:(NSString*)fileName interval:(int)interval z:(int)z
{
    id enterRight	= [CCMoveTo actionWithDuration:interval
                                        position:ccp(0, imgTop)];
    id enterRight2	= [CCMoveTo actionWithDuration:interval
                                         position:ccp(0, imgTop)];
    id exitLeft		= [CCMoveTo actionWithDuration:interval
                                       position:ccp(-imgSize, imgTop)];
    id exitLeft2	= [CCMoveTo actionWithDuration:interval
                                       position:ccp(-imgSize, imgTop)];
    id reset		= [CCMoveTo actionWithDuration:0
                                    position:ccp(imgSize, imgTop)];
    id reset2		= [CCMoveTo actionWithDuration:0
                                     position:ccp(imgSize, imgTop)];
    id seq1			= [CCSequence actions: exitLeft, reset, enterRight, nil];
    id seq2			= [CCSequence actions: enterRight2, exitLeft2, reset2, nil];
    
    CCSprite *spCloud1 = [CCSprite spriteWithFile:fileName];
    [spCloud1 setAnchorPoint:ccp(0,1)];
    [spCloud1.texture setAliasTexParameters];
    [spCloud1 setPosition:ccp(0, imgTop)];
    [spCloud1 runAction:[CCRepeatForever actionWithAction:seq1]];
    spCloud1.opacity = 200;
    [self addChild:spCloud1 z:z ];
    
    CCSprite *spCloud2 = [CCSprite spriteWithFile:fileName];
    [spCloud2 setAnchorPoint:ccp(0,1)];
    [spCloud2.texture setAliasTexParameters];
    [spCloud2 setPosition:ccp(imgSize, imgTop)];
    spCloud2.opacity = 210;
    [spCloud2 runAction:[CCRepeatForever actionWithAction:seq2]];
    [self addChild:spCloud2 z:z ];
}

#define FRONT_CLOUD_SIZE 1000
#define FRONT_CLOUD_TOP   380
#define BACK_CLOUD_SIZE 800
#define BACK_CLOUD_TOP   220

- (void)createCloudBackground
{
    [self createCloudWithSize:FRONT_CLOUD_SIZE top:FRONT_CLOUD_TOP
                     fileName:@"cloud_group1.png" interval:70 z:31];
    [self createCloudWithSize:BACK_CLOUD_SIZE  top:BACK_CLOUD_TOP
                     fileName:@"cloud_group2.png"  interval:90 z:30];
}

- (Balloon *)findLastBalloon
{
    for (Balloon *balloon in [balloonGroup children]) {
        if (balloon.tag == kTagLastBalloon) {
            return [balloon retain];
        }
    }
    return nil;
}

- (void)decreaseGamerLife
{
    numOfLife--;
    id scaleUp = [CCScaleBy actionWithDuration:0.2 scale:2.5];
    
    if (numOfLife == 2) {
        [lifeBalloon3 runAction:[scaleUp copy]];
        [lifeBalloon3 pop];
    }
    else if(numOfLife == 1) {
        [lifeBalloon2 runAction:[scaleUp copy]];
        [lifeBalloon2 pop];
    }
    else {
        [lifeBalloon1 runAction:[scaleUp copy]];
        [lifeBalloon1 pop];
        [self scheduleOnce:@selector(playGameOverSound) delay:1.0];
        //
    }
    
    //Balloon *lastBalloon = [balloonArray lastObject];
    Balloon *lastBalloon = [self findLastBalloon];
    if (lastBalloon != nil) {
        // lifer가 줄었다는 메시지를 보여준다
        [message showMessage:@"LIFE -1" atPosition:lastBalloon.position upDirecion:NO];
    }
    
    // life가 줄었으므로 lifeLabel을 갱신하여 보여준다
    [self updateLifeLabel];
}

- (void)playGameOverSound
{
    [sae playEffect:BP_GAMEOVER_SOUND];
}

- (void)resetComboCount
{
    comboCount = 0;
}

// 잘못된 풍선 터치시의 벌칙 모듈
- (void) wrongBalloonTouch
{
    // 플레이 모드를 off 시킨다. 효과가 나타나는 중의 터치를 방지함.
    isPlaying = NO;
    [self resetComboCount];
    
    // 게이머 life가 1 감소하고, 마지막 풍선을 화면에 보여줌
    [self decreaseGamerLife];
    [self showLastBalloonWithEffects];
    
    // 게임 life가 0이 되면 game over 장면으로 이동
    if (numOfLife <= 0)
        [self gameOver];
    else
        [self scheduleOnce:@selector(removeAllBalloons) delay:2.0];
}

- (void) updateTimerBar: (float)timer
{
    if (timer < 0) {
        timer = 0.0f;
    }
    ptTimer.percentage = timer;
}

- (void) createEnergyBar
{
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // 배경으로 깔리는 풍선 그림 - empty 이미지
    CCSprite *ptTimerEmpty = [CCSprite spriteWithFile:@"pole_em.png"];
    ptTimerEmpty.anchorPoint = ccp(0, 0);
    ptTimerEmpty.position = ccp(screenWidth-90, screenHeight-BP_LABEL_TOP_OFFSET-10);
    [self addChild:ptTimerEmpty z:20];
    
    // 같은 위치에 풍선이 나타나게됨
    CCSprite *timerBarSprite = [CCSprite spriteWithFile:@"pole_en.png"];
    ptTimer = [CCProgressTimer progressWithSprite:timerBarSprite];
    ptTimer.type = kCCProgressTimerTypeBar;
    ptTimer.barChangeRate = ccp(1, 0);
    ptTimer.midpoint = ccp(1.0f, 0.0f);
    ptTimer.anchorPoint = ccp(0, 0);
    ptTimer.position = ptTimerEmpty.position;
    ptTimer.percentage=100;
    [self addChild:ptTimer z:21];
}

// life label이 갱신됨
- (void)updateLifeLabel
{
    // life가 -가 되면 안됨
    if ( numOfLife < 0) numOfLife = 0;
    
    NSString *str = [NSString stringWithFormat:@"x%1d", numOfLife];
    [self.lifeLabel setString:str];
    
    id scaleAction = [CCSequence actions:
                      [CCScaleTo actionWithDuration:0.2 scale:1.40],
                      [CCScaleTo actionWithDuration:0.1 scale:1.05],
                      nil];
    
    [self.lifeLabel runAction:scaleAction];
}

- (void) calcTimeAndShowCombo
{
    // calculate delayTime and increase combo count
    if (delayTime < 20.0f)
        comboCount++;
    else
        comboCount = 0;
    
    if (comboCount >= 2) {
        NSString *mes = [NSString stringWithFormat:@"COMBO %d", comboCount];
        [message showMessage:mes atPosition:ccpAdd(centerPt, ccp(0,200))];
        gameScore += 100*comboCount;
    }
}

// 손가락이 닫는 순간 호출됩니다.
- (void) ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // play 중이 아니면 터치 처리를 하지 않음
    if (isPlaying == NO)
        return;
    
    UITouch *touch = [touches anyObject];
    
    // 터치가 왼쪽 또는 오른쪽 화살표 안에 들어왔는지 확인합니다.
    switch ([self getTouchObjectType:touch]) {
        // 마지막 오브젝트 터치이면
        case LAST_GEN_BALLOON_TOUCH:
            [self calcTimeAndShowCombo];
            [sae playEffect:BP_POP_SOUND];
            [self removeAllBalloons];
            [self updateGameScore];
            break;
        case NORMAL_GEN_BALLOON_TOUCH :
            [sae playEffect:BP_FAIL_SOUND];
            [self wrongBalloonTouch];
            break;
        case BACKGROUND_TOUCH:
        default:
            break;
    }
}

// 손가락을 떼는 순간 호출됩니다.
- (void)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    // 배경화면을 멈춥니다.
}

// 손가락을 움직일 때 계속해서 호출됩니다.
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
