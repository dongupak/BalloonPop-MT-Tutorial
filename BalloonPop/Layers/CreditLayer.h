//
//  CreditLayer.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2014. 1. 20..
//  Copyright (c) 2014년 DongGyu Park. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "SimpleAudioEngine.h"
#import "CCLayer+Touch.h"
#import "AppDelegate.h"

enum {
	kTagCreditLayerBackground = 4700,
    kTagCreditTitle,
    kTagCreditDesc,
};

@interface CreditLayer : CCLayer
{
    BOOL isMenuSelected;
    
    CCNode *balloonGroup;
    
    SimpleAudioEngine *sae;
    // 화면 크기와 중심좌표
    CGRect screenRect ;
    CGPoint centerPt;
    
    AppController<UIApplicationDelegate> *appDelegate;
}

@end
