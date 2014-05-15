//
//  GameLayer.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 23..
//  Copyright (c) 2013년 DongGyu Park. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "CCLayer+Touch.h"
#import "SimpleAudioEngine.h"
#import "Balloon.h"
#import "MessageNode.h"
#import "AppDelegate.h"

enum {
	kTagGameLayerBackground = 3500,
	kTagGame,
    kTagSpriteManager,
    kTagBalloonGroup,
    kTagCloud,
    kTagMessage,
    kTagScoreLabel,
    kTagScoreSprite,
    kTagLifeLabel,
    kTagLifeSprite,
    kTagLastBalloon = 8888,
    kTagNormalBalloon,
};

typedef enum {
    LAST_GEN_BALLOON_TOUCH,
    NORMAL_GEN_BALLOON_TOUCH,
    BACKGROUND_TOUCH,
} TouchObjectType;

@interface GameLayer : CCLayer
{
    BOOL    isPlaying;
    
    float   delayTime;
    NSInteger   comboCount;
    NSInteger numOfLife, gameScore;
    ccColor3B BP_STROKE_COLOR;
    ccColor3B BP_LABEL_COLOR;
    
    // 화면 크기와 중심좌표
    CGRect screenRect ;
    CGPoint centerPt;

    CCNode *balloonGroup;
    
    Balloon *lifeBalloon1, *lifeBalloon2, *lifeBalloon3, *lifeBalloon4;
    MessageNode *message;
    
    SimpleAudioEngine *sae;
    
    AppController<UIApplicationDelegate> *appDelegate;
    CCSprite *gameLayerBgSprite;
    CCLabelTTF *scoreLabel;
    CCRenderTexture* scoreStroke;
    CCLabelTTF *lifeLabel;
    
    CCProgressTimer *ptTimer;
    
    CCNode *cloudGroup;
}

@property (nonatomic, retain) MessageNode *message;
@property (nonatomic, retain) CCLabelTTF *scoreLabel;
@property (nonatomic, retain) CCLabelTTF *lifeLabel;
@property (nonatomic, retain) CCRenderTexture* scoreStroke;

@end
