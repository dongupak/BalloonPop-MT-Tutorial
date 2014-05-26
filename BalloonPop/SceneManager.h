//
//  SceneManager.h
//  SceneManager
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MenuLayer.h"
#import "GameLayer.h"
#import "HowtoLayer.h"
#import "CreditLayer.h"
#import "GameOverLayer.h"
#import "LevelSelecLayer.h"

@interface SceneManager : NSObject {
}

+(void) goMenu;
+(void) goGame;
+(void) goHowto;
+(void) goGameOver;
+(void) goLevelSelect;
//+(void) goShop;   // reserved for shop scene
+(void) goCredit;

@end
