/*
 This work is licensed under the Creative Commons Attribution-Share Alike 3.0 United States License. 
 To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/us/ or 
 send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
 
 Jed Laudenslayer
 http://kwigbo.com
 
 */

#import "MessageNode.h"

#define MESSAGE_FONT           (@"Arial Rounded MT Bold")
#define MESSAGE_NODE_FONTSIZE    (20)

@implementation MessageNode

@synthesize message, messageLabel, messageScale;

- (CCFontDefinition *)messageFontDefinition
{
    // 메시지 노드의 폰트 속성정의
    CCFontDefinition *tempDefinition = [[CCFontDefinition alloc]
                                        initWithFontName:MESSAGE_FONT
                                        fontSize:MESSAGE_NODE_FONTSIZE];
    tempDefinition.dimensions    = CGSizeMake(0,0);
    tempDefinition.alignment     = kCCTextAlignmentCenter;
    tempDefinition.vertAlignment = kCCVerticalTextAlignmentTop;
    tempDefinition.lineBreakMode = kCCLineBreakModeWordWrap;
    
    [tempDefinition enableShadow:NO];
    
    // stroke
    [tempDefinition enableStroke:YES];
    [tempDefinition setStrokeColor:ccBLACK];
    [tempDefinition setStrokeSize:1];
    
    // fill color
    tempDefinition.fontFillColor = ccc3(255, 255, 15);
    return tempDefinition;
}

#define DEFAULT_MESSAGE     (@"COMBO")

- (id) init
{	
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGPoint centerPt = CGPointMake(CGRectGetMidX(screenRect),
                                   CGRectGetMidY(screenRect));
    
	self = [super init];
    
	if (self)
	{
        // default message
        message = DEFAULT_MESSAGE;
        upDirection = YES;
        
		CCFontDefinition *fontDefinition = [self messageFontDefinition];
        
        // 현재 노드에 miss, perfect, correct 스프라이트 노드를 자식 노드로 추가
		messageLabel = [CCLabelTTF labelWithString:message
                                 fontDefinition:fontDefinition];
        [self addChild:messageLabel];
		
        messageLabel.position = centerPt;
        messageLabel.visible = NO;
	}
	
	return self;
}

// showMessage 메소드는 mes 레이블을 받아서
- (void)showMessage:(NSString *)mes
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGPoint centerPt = CGPointMake(CGRectGetMidX(screenRect),
                                   CGRectGetMidY(screenRect));

	[self showMessage:mes atPosition:centerPt upDirecion:YES];
}

- (void)showMessage:(NSString *)mes atPosition:(CGPoint)pos upDirecion:(BOOL)upDir
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // 화면의 귀퉁이에 있어서 가려지지 않도록 message의 최소/최대 좌표 지정
    if (pos.y < 70) pos.y = 100;
    if (pos.x < 50) pos.x = 100;
    if (pos.x > screenRect.size.width-50) pos.x = screenRect.size.width-100;

    id      fadeInShow = [CCFadeTo actionWithDuration:0.3 opacity:250];
    id      scaleUpDown = [CCSequence actions:[CCScaleTo actionWithDuration:0.4 scale:1.5],
                           [CCScaleTo actionWithDuration:0.2 scale:1.0],
                           [CCScaleTo actionWithDuration:0.2 scale:1.5],
                           [CCScaleTo actionWithDuration:0.2 scale:1.0],
                           nil];
    id      moveToTop = [CCMoveTo actionWithDuration:0.15 position:ccp(pos.x,
                                                                       screenRect.size.height+50)];
    id      fadeOut = [CCFadeTo actionWithDuration:0.1 opacity:0];
    
    // 순차적인 액션을 보여줌, life Minus인 경우
    // 화면의 아래쪽으로 떨어진다..
    id downFadeAction = [CCSequence actions:
                         fadeInShow,
                         scaleUpDown,
                         [CCDelayTime actionWithDuration:0.3],
                         // 화면의 하단으로 사라지는 액션
                         [CCEaseBackIn actionWithAction:
                          [CCMoveTo actionWithDuration:0.3 position:ccp(pos.x,-50)]],
                         fadeOut,
                         nil];
	id upFadeAction = [CCSequence actions:
                       fadeInShow,
                       scaleUpDown,
                       [CCDelayTime actionWithDuration:0.3],
                       [CCSpawn actions:moveToTop, fadeOut, nil],
                       nil];
    [messageLabel setString:mes];
    
    messageLabel.opacity = 0.6;
    messageLabel.visible = YES;
    [messageLabel setPosition:pos];
    
    if( upDir == YES)
        [messageLabel runAction:upFadeAction];
    else
        [messageLabel runAction:downFadeAction];
    
	return;
}

// default up direction show message
- (void)showMessage:(NSString *)mes atPosition:(CGPoint)pos
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // 화면의 귀퉁이에 있어서 가려지지 않도록 message의 최소/최대 좌표 지정
    if (pos.y < 70) pos.y = 100;
    if (pos.x < 50) pos.x = 100;
    if (pos.x > screenRect.size.width-50) pos.x = screenRect.size.width-100;
    
    messageLabel.scale = 1.0f;
    
    id      fadeInShow = [CCFadeTo actionWithDuration:0.1 opacity:250];
    id      scaleUpDown = [CCSequence actions:
                           [CCScaleTo actionWithDuration:0.2 scale:1.5],
                           [CCScaleTo actionWithDuration:0.15 scale:1.0],nil];
    id      scaleUp = [CCScaleTo actionWithDuration:0.3 scale:1.8];
    id      fadeOut = [CCFadeTo actionWithDuration:0.3 opacity:0];
    id      scaledFadeAction = [CCSpawn actionOne:scaleUp two:fadeOut];
    
	id fadeAction = [CCSequence actions:
                       fadeInShow,
                       scaleUpDown,
                       [CCDelayTime actionWithDuration:0.2],
                       scaledFadeAction,
                       nil];
    [messageLabel setString:mes];
    
    messageLabel.opacity = 0.6;
    messageLabel.visible = YES;
    [messageLabel setPosition:pos];
    
    [messageLabel runAction:fadeAction];
	return;
}

@end
