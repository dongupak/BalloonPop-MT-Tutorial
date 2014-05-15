//
//  LevelSelecLayer.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2014. 1. 4..
//  Copyright (c) 2014년 DongGyu Park. All rights reserved.
//

#import "CCLayer.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"

enum {
	kTagLevelSelectBackground = 8500,
	kTagLevelSelectMenu,
    kTagBalloon,
    kTagLevelSelectTitle,
    kTagEasyLevel,
    kTagMediumLevel,
    kTagHardLevel,
    kTagExpertLevel,
};

// Easy, Medium, Hard, Export 레벨중 하나를 선택하는 기능이 있는
// 레이어
@interface LevelSelecLayer : CCLayer
{
    // 메뉴를 연속터치 했을 경우 연속 화면전환을 방지하는 BOOL 값
    BOOL isMenuSelected;
    
    CCMenuItemSprite *itemEasyLevel;
    CCMenuItemSprite *itemMediumLevel;
    CCMenuItemSprite *itemHardLevel;
    CCMenuItemSprite *itemExpertLevel;
    
    // 배경으로 풍선들이 올라간다. 이 풍선들을 위한 그룹
    CCNode *balloonGroup;
    SimpleAudioEngine *sae;
    
    // 화면 크기와 중심좌표
    CGRect screenRect ;
    CGPoint centerPt;
    
    AppController<UIApplicationDelegate> *appDelegate;
}

@end
