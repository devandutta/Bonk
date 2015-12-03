//
//  TextBox.h
//  Bonk_v2
//
//  Created by Devan Dutta on 8/5/13.
//
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "GameLayer.h"
#import "StartMenuLayer.h"
#import "GameOver.h"
#import "GameParameters.h"
#import "CCControlExtension.h"
#import "cocos2d.h"
@interface TextBox : NSObject
@property (nonatomic) CCSprite* roundedBlueRect;
@property (nonatomic) CCLabelTTF* text;
-(id) init;
@end
