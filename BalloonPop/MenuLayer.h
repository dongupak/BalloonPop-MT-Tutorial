//
//  MenuLayer.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 20..
//  Copyright DongGyu Park 2013년. All rights reserved.
//

#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "CCLayer+Touch.h"
#import "AppDelegate.h"

// Preferred method for testing for Game Center
// 외부 함수를 이용하여 게임센터가 이용가능한가 검사한다
BOOL isGameCenterAvailable();

enum {
	kTagMenuLayerBackground = 3100,
	kTagMenuLayerCloud,
    kTagMenuLayerText,
    kTagMenu,
    kTagPlayGameMenu,
    kTagHowtoMenu,
    kTagShopMenu,
    kTagCreditMenu,
};

// MenuLayer
@interface MenuLayer : CCLayer <GKGameCenterControllerDelegate>
{
    BOOL menuSelected;
    BOOL allItemPurchased;
    
    // 배경으로 풍선들이 올라간다. 이 풍선들을 위한 그룹
    CCNode *balloonGroup;
    
    SimpleAudioEngine *sae;
    
    CCMenuItemSprite *startMenuItem;
    CCMenuItemSprite *howtoMenuItem;
    CCMenuItemSprite *infoMenuItem;

    GKLocalPlayer *_localPlayer;
    
    // 화면 크기와 중심좌표
    CGRect screenRect ;
    CGPoint centerPt;
    
    AppController<UIApplicationDelegate> *appDelegate;
}

@property (nonatomic, retain) CCMenuItem *startMenuItem;
@property (nonatomic, retain) CCMenuItem *howtoMenuItem;
@property (nonatomic, retain) CCMenuItem *infoMenuItem;

@property (readwrite, getter = isAllItemPurchased) BOOL allItemPurchased;
@property (readwrite, getter = isMenuSelected) BOOL menuSelected;

@property (strong, nonatomic) GKLocalPlayer *_localPlayer;

@end
