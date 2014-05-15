//
//  CCLayer+Touch.m
//  BalloonPop-Memory Train
//
//  Created by DongGyu Park on 2014. 1. 30.
//  Copyright 2014년 DongGyu Park. All rights reserved.
//

#import "CCLayer+Touch.h"

// int 값 min에서 max 사이의 난수를 생성하여 float로 반환하는 기능
float clampRandomNumber(int min, int max)
{
	int t = arc4random()%(max-min);
	
	return (t+min)*1.0f; // 실수로 바꾸어서 반환함
}

// float 값 min에서 max 사이의 난수를 생성하여 float로 반환하는 기능
float clampRandomNumberf(float min, float max)
{
	int t = arc4random()%(int)((max-min)*1000.0f);
	float newT = t/1000.0f;
    
	return (min + newT);
}

#pragma mark -
#pragma mark Game Center Support

// Check for the availability of Game Center API.
BOOL isGameCenterAPIAvailable()
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

@implementation CCLayer (Touch)

- (id) showScaleUp:(CGPoint)position
{
	id showScaleUpAction = [CCSequence actions:	// 화면안으로 나타나는 애니메이션
                            [CCEaseBackOut actionWithAction:
                             [CCScaleTo actionWithDuration:0.9 scale:1.0]],
                            nil];
	
	return showScaleUpAction;
}

- (id) showScaleUpWithDelay:(CGFloat)delayTime
{
	id showScaleUpAction = [CCSequence actions:	// 화면안으로 나타나는 애니메이션
                            [CCDelayTime actionWithDuration:delayTime],
                            [CCEaseBackOut actionWithAction:
                             [CCScaleTo actionWithDuration:0.2 scale:1.0]],
                            nil];
	
	return showScaleUpAction;
}

// sender 객체가 최종적으로 좌우로 움직이는 애니메이션을 위한 메소드
- (void) moveLeftRight:(id)sender withOffset:(int)offset
{
	// CCMoveBy에 의해 상대적인 위치로 이동한다
	id move1 = [CCMoveBy actionWithDuration:0.9 position:ccp(offset, 0)];
	id move2 = [CCMoveBy actionWithDuration:0.9 position:ccp(-offset, 0)];
	// 아래위 움직임을 반복한다
	id moveUpDown = [CCSequence actions:move1, move2, nil];
	
	[sender runAction:[CCRepeatForever actionWithAction:moveUpDown]];
}

// sender 객체가 최종적으로 좌우로 움직이는 애니메이션을 위한 메소드
- (void) moveUpDown:(id)sender withOffset:(int)offset
{
	// CCMoveBy에 의해 상대적인 위치로 이동한다
	id move1 = [CCMoveBy actionWithDuration:0.9 position:ccp(0, offset)];
	id move2 = [CCMoveBy actionWithDuration:0.9 position:ccp(0, -offset)];
	// 아래위 움직임을 반복한다
	id moveUpDown = [CCSequence actions:move1, move2, nil];
	
	[sender runAction:[CCRepeatForever actionWithAction:moveUpDown]];
}

// 메뉴가 최종적으로 아래위로 움직이는 애니메이션을 위한 메소드
- (void) move:(id)sender withOffsetPt:(CGPoint)offsetPt
{
	// CCMoveBy에 의해 상대적인 위치로 이동한다
	id move1 = [CCMoveBy actionWithDuration:0.9 position:offsetPt];
	id move2 = [CCMoveBy actionWithDuration:0.7 position:offsetPt];
	// 아래위 움직임을 반복한다
	id moveSeq = [CCSequence actions:move1, move2, [move1 reverse], [move2 reverse], nil];
	
	[sender runAction:[CCRepeatForever actionWithAction:moveSeq]];
}

- (void)moveLeftRight5:(id)sender
{
	//	NSLog(@"menuMove1 sender=%@", sender);
	[self moveLeftRight:sender withOffset:5];
}

- (void)moveLeftRight10:(id)sender
{
	//	NSLog(@"menuMove2 sender=%@", sender);
	[self moveLeftRight:sender withOffset:10];
}

- (id) menuSelectionAction
{
    id action1 = [CCScaleTo actionWithDuration:0.09f scale:1.1f];
    id action2 = [CCScaleTo actionWithDuration:0.09f scale:0.9f];
    id action3 = [CCScaleTo actionWithDuration:0.08f scale:1.1f];
    id action4 = [CCScaleTo actionWithDuration:0.09f scale:0.9f];
    id action5 = [CCScaleTo actionWithDuration:0.09f scale:1.1f];
    id allActions = [CCSequence actions:action1,action2,action3,action4,action5,nil];
    
    return allActions;
}

- (CGPoint)convertedTouchPoint:(UITouch *)touch
{
    // Cocoa 좌표를 cocos2d 좌표로 변환합니다
    CGPoint touchPt = [touch locationInView: [touch view]];
    CGPoint convertedTouchPt = [[CCDirector sharedDirector] convertToGL:touchPt];
    
    return convertedTouchPt;
}

// 터치가 버튼 Sprite안에서 이루어졌는지 확인합니다.
- (BOOL) isTouchInside:(CCSprite *)sprite withTouch:(UITouch *)touch
{
    CGPoint convertedLocation = [self convertedTouchPoint:touch];
    CGFloat halfSpriteWidth = sprite.contentSize.width/2.0;
    CGFloat halfSpriteHeight = sprite.contentSize.height/2.0;
    
    if(convertedLocation.x > (sprite.position.x + halfSpriteWidth) ||
       convertedLocation.x < (sprite.position.x - halfSpriteWidth) ||
       convertedLocation.y < (sprite.position.y - halfSpriteHeight) ||
       convertedLocation.y > (sprite.position.y + halfSpriteHeight) ) {
        return NO;
    }
    
    return YES;
}

-(CCRenderTexture*) createStroke:(CCLabelTTF *) label
                            size:(float)size
                           color:(ccColor3B)cor
{
    CGSize labelSize = label.texture.contentSize;
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:labelSize.width+size*2
                                                           height:labelSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	BOOL originalVisibility = [label visible];
    
	[label setColor:cor];
	[label setVisible:YES];
    
	ccBlendFunc originalBlend = [label blendFunc];
    [label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    
    CGPoint bottomLeft = ccp(labelSize.width * label.anchorPoint.x+size,
                             labelSize.height * label.anchorPoint.y + size);
    CGPoint positionOffset = ccp(labelSize.width * label.anchorPoint.x - labelSize.width/2,
                                 labelSize.height * label.anchorPoint.y - labelSize.height/2);
    // new positionOffset
//    CGPoint positionOffset = ccp(-labelSize.width/2, -labelSize.height/2);
    CGPoint position = ccpSub(originalPos, positionOffset);
    
    [rt begin];
    for (int i=0; i<360; i+=30) // you should optimize that for your needs
    {
        [label setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*size,
                               bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
        [label visit];
    }
    [rt end];
    
    [label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[label setVisible:originalVisibility];
	[rt setPosition:position];
	
    return rt;
}

@end
