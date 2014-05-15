//
//  BPStrokeLabel.m
//  BalloonPop-Memory
//
//  Created by DongGyu Park on 2014. 2. 9..
//  Copyright (c) 2014년 DongGyu Park. All rights reserved.
//

#import "BPStrokeLabel.h"

@implementation BPStrokeLabel

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

- (void) addStrokeWithSize:(float)size color:(ccColor3B)color
{
    CCRenderTexture* scoreStroke = [self createStroke:self
                                                 size:size
                                                color:color];
    [self addChild:scoreStroke z:self.zOrder-1];
}


@end
