//
//  AppDelegate.h
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2013. 12. 20..
//  Copyright DongGyu Park 2013년. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

typedef enum {
    BP_LEVEL_EASY,
    BP_LEVEL_MEDIUM,
    BP_LEVEL_HARD,
    BP_LEVEL_EXPERT,
} PLAY_LEVEL;

//// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;
    
	CCDirectorIOS	*director_;							// weak ref
    NSInteger   gameScore;
    PLAY_LEVEL  gameLevel;
    
    SimpleAudioEngine *sae;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;

@property (readonly) CCDirectorIOS *director;

@property (readwrite) NSInteger gameScore;
@property (readwrite) PLAY_LEVEL gameLevel;

@end
