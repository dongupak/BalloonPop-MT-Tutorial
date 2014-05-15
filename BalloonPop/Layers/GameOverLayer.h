//
//  GameOverLayer.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 23..
//  Copyright (c) 2013년 DongGyu Park. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "CCLayer.h"
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "CCLayer+Touch.h"
#import "AppDelegate.h"

// Preferred method for testing for Game Center
// 외부 함수를 이용하여 게임센터가 이용가능한가 검사한다
BOOL isGameCenterAvailable();

enum {
	kTagGameOverLayerBackground = 6300,
	kTagGameOverScoreLabel,
    kTagTitleSprite,
    kTagScoreBackground,
    kTagBackToMainMenu,
    kTagSubmitScoreMenu,
    kTagTryAgainMenu,
    kTagRankingMenu
};

// 게임센터와 리더보드 기능을 사용하기 위한 두 개의 delegate를 프로토콜로 선언
@interface GameOverLayer : CCLayer <GKGameCenterControllerDelegate>
{
    BOOL isMenuSelected;
    
    // 화면 크기와 중심좌표
    CGRect screenRect ;
    CGPoint centerPt;

    CCLabelTTF *scoreLabel; // 점수를 화면에 출력하기 위한 속성
    
    CCMenuItemSprite *tryMenuItem;
    CCMenuItemSprite *rankMenuItem;
    CCMenuItemSprite *submitScoreMenuItem;
    CCMenuItemSprite *backMenuItem;
    CCMenu *menu;
    
    CCNode *balloonGroup;
    
    SimpleAudioEngine *sae;
    
    AppController<UIApplicationDelegate> *appDelegate;
}

@property (nonatomic, retain) CCLabelTTF *scoreLabel;

@property (nonatomic, retain) CCMenuItemSprite *tryMenuItem;
@property (nonatomic, retain) CCMenuItemSprite *rankMenuItem;
@property (nonatomic, retain) CCMenuItemSprite *backMenuItem;
@property (nonatomic, retain) CCMenuItemSprite *submitScoreMenuItem;
@property (nonatomic, retain) CCMenu *menu;

@property (strong, nonatomic) GKLocalPlayer *_localPlayer;

@end
