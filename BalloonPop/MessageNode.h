/*
 This work is licensed under the Creative Commons Attribution-Share Alike 3.0 United States License. 
 To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/us/ or 
 send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
 
 Jed Laudenslayer
 http://kwigbo.com
 
 */

#import "cocos2d.h"

// miss, perfect, correct 등의 메시지 정보를 보여주는 메시지 노드
@interface MessageNode : CCNode
{
    NSString *message;
    BOOL    upDirection;
    float   messageScale;
    
	// 각각의 정보를 보여주기 위한 스프라이트 노드의 사용 
	CCLabelTTF *messageLabel;
}

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) CCLabelTTF *messageLabel;
@property (readwrite) float   messageScale;

- (void)showMessage:(NSString *)mes;
- (void)showMessage:(NSString *)mes atPosition:(CGPoint)position;
- (void)showMessage:(NSString *)mes atPosition:(CGPoint)position upDirecion:(BOOL)dir;

@end
