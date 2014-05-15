//
//  IntroLayer.m
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 20..
//  Copyright DongGyu Park 2013년. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "MenuLayer.h"

extern float clampRandomNumber(int min, int max);
extern float clampRandomNumberf(float min, float max);

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

+(id) scene
{
	CCScene *scene = [CCScene node];
	IntroLayer *layer = [IntroLayer node];
	[scene addChild: layer];
    
	return scene;
}

//
- (id) init
{
	if( (self=[super init])) {
        
        appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        
        [self getScreenSize];
        
		// create and initialize a Label
		[self animateBackground];
        
        [self addAdLayer];
	}
	
	return self;
}

- (void) addAdLayer
{
//    AdLayer *myAd = [AdLayer node];
//    [self addChild:myAd z:6000];
}

- (void)getScreenSize
{
    // 화면 크기와 화면의 중심좌표를 얻는다
    screenRect = [[UIScreen mainScreen] bounds];
    centerPt = CGPointMake(CGRectGetMidX(screenRect),
                           CGRectGetMidY(screenRect));
}

#define INTRO_LAYER_BACKGROUND       (@"Default-568h.png")

- (void)animateBackground
{
    CCSprite *background;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
        background = [CCSprite spriteWithFile:INTRO_LAYER_BACKGROUND];
    }
    else {
        background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
    }
    background.position = centerPt;
    
    // add the label as a child to this Layer
    [self addChild:background z:0 tag:kTagIntroLayerBackground];
}

- (void) onEnter
{
	[super onEnter];

    [SceneManager goMenu];
    //[SceneManager goLevelSelect];
    //[SceneManager goShop];
    //[SceneManager goCredit];
    //[SceneManager goGameOver];
}

@end
