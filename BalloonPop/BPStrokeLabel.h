//
//  BPStrokeLabel.h
//  BalloonPop-Memory
//
//  Created by DongGyu Park on 2014. 2. 9..
//  Copyright (c) 2014년 DongGyu Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelTTF.h"

@interface BPStrokeLabel : CCLabelTTF

- (void) addStrokeWithSize:(float)size color:(ccColor3B)color;

@end
