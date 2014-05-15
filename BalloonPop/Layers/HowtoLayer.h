//
//  HowtoLayer.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 23..
//  Copyright (c) 2013년 DongGyu Park. All rights reserved.
//

#import "CCLayer.h"
#import "SimpleAudioEngine.h"
#import "CCLayer+Touch.h"
#import "AppDelegate.h"

enum {
	kTagHowtoLayerBackground = 7500,
    kTagBackToMenu,
};

@interface HowtoLayer : CCLayer
{
    BOOL isMenuSelected;
    
    // 화면 크기와 중심좌표
    CGRect screenRect ;
    CGPoint centerPt;

    SimpleAudioEngine *sae;

    CCNode *balloonGroup;
    
    AppController<UIApplicationDelegate> *appDelegate;
}

@end
