//
//  IntroLayer.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 20..
//  Copyright DongGyu Park 2013년. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "SceneManager.h"
#import "AppDelegate.h"

enum {
	kTagIntroLayerBackground = 2700,
	kTagIntro,
};

// IntroLayer
@interface IntroLayer : CCLayer
{
    // 화면 크기와 중심좌표
    CGRect screenRect ;
    CGPoint centerPt;

    AppController<UIApplicationDelegate> *appDelegate;
}

+(id) scene;

@end
