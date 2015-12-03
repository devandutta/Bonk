//
//  GameOver.h
//  Bonk_v2
//
//  Created by Devan Dutta on 6/28/13.
//
//
#import "StartMenuLayer.h"
#import "CCLayer.h"
#import "GameLayer.h"
#import "StartMenuLayer.h"
#import "cocos2d.h"
#import "CCControlExtension.h"
#import "CCScrollLayer.h"
#import "TextBox.h"

@interface GameOver : CCLayer
{
    CCMenu* results;
    CCMenu* results2;
    CCMenu* results3;
    CCScrollLayer *scrollResults;
    CCLayer *layer1;
    CCLayer *layer2;
    CCLayer *layer3;
}
+(id) scene;
-(void) reactToRestart: (CCMenuItem *) menuItem;
@end
