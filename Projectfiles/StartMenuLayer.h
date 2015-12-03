//
//  StartMenuLayer.h
//  Bonk!
//
//  Created by Devan Dutta on 6/21/13.
//
//

#import "CCLayer.h"
#import "CCLayer.h"
#import "GameLayer.h"
#import "CCControlExtension.h"
#import "GameParameters.h"
#import "TextBox.h"
@interface StartMenuLayer : CCLayer
{
    CCSprite *background;
    CCControlSlider* numberQuestions;
    CCLabelTTF *numberQuestionsDisplayValueLabel;
    CCControlSlider* maxNumberSlider;
    CCLabelTTF* maxNumberDisplayValueLabel;
    CCControlSwitch *negatives;
    CCLabelTTF* negativeDisplayValueLabel;
    UISlider *numberQuestionsUI;
    UISlider *maxNumber;
    UISwitch *negativeSwitch;
}
+(id) scene;
-(void) reactToPlay: (CCMenuItem *) menuItem;
@end
