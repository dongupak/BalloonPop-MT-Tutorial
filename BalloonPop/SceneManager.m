//
//  SceneManager.m
//  SceneManager
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "SceneManager.h"

#define TRANSITION_DURATION (0.9f)

@interface FadeWhiteTransition : CCTransitionFade 
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end

@interface FadeBlackTransition : CCTransitionFade 
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end

@interface ZoomFlipXLeftOver : CCTransitionFlipX 
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end

@interface FlipYDownOver : CCTransitionFlipY 
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end

@implementation FadeWhiteTransition
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s 
{
	return [self transitionWithDuration:t scene:s withColor:ccWHITE];
}
@end

@implementation FadeBlackTransition
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s 
{
	return [self transitionWithDuration:t scene:s withColor:ccBLACK];
}
@end

@implementation ZoomFlipXLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s 
{
	return [self transitionWithDuration:t
                                  scene:s
                            orientation:kCCTransitionOrientationLeftOver];
}
@end

@implementation FlipYDownOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s 
{
	return [self transitionWithDuration:t
                                  scene:s
                            orientation:kCCTransitionOrientationDownOver];
}
@end

static int sceneIdx=0;
static NSString *transitions[] = {
	@"FadeWhiteTransition",
	@"FadeBlackTransition",
};

Class nextTransition()
{	
	// HACK: else NSClassFromString will fail
	//[CCTransitionRadialCCW node];
    [CCTransitionProgressRadialCCW node];
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	
	return c;
}

@interface SceneManager ()
+(void) go: (CCLayer *) layer;
+(CCScene *) wrap: (CCLayer *) layer;
@end


@implementation SceneManager

+(void) goMenu
{
	CCLayer *layer = [MenuLayer node];
	[SceneManager go:layer];
}

//+(void) goShop
//{
//    // In APP 구매를 위한 코드임
////	CCLayer *layer = [ShopLayer node];
////	[SceneManager go:layer];
//}

+(void) goGame
{
	CCLayer *layer = [GameLayer node];
	[SceneManager go:layer];
}

+(void) goHowto
{
	CCLayer *layer = [HowtoLayer node];
	[SceneManager go:layer];
}

+(void) goGameOver
{
	CCLayer *layer = [GameOverLayer node];
	[SceneManager go:layer];
}

+(void) goLevelSelect
{
	CCLayer *layer = [LevelSelecLayer node];
	[SceneManager go:layer];
}

+(void) goCredit
{
	CCLayer *layer = [CreditLayer node];
	[SceneManager go:layer];
}

+(void) go:(CCLayer *)layer
{
	CCDirector *director = [CCDirector sharedDirector];
	CCScene *newScene = [SceneManager wrap:layer];
	
	Class transition = nextTransition();
	
	// 이미 실행중인 Scene이 있을 경우 replaceScene을 호출
	if ([director runningScene]) {
		[director replaceScene:[transition transitionWithDuration:TRANSITION_DURATION 
															scene:newScene]];
	} // 최초의 Scene은 runWithScene으로 구동시킴
	else {
		[director runWithScene:newScene];		
	}
}

// 매개변수인 CCLayer형 layer를 CCScene으로 wrapping하여 반환함.
+(CCScene *) wrap:(CCLayer *)layer
{
	// newScene 객체를 만들어서 layer를 자식노드로 추가한 후 반환
	CCScene *newScene = [CCScene node];
	[newScene addChild: layer];
	return newScene;
}

@end
