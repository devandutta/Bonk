//
//  Settings.h
//  Bonk_v2
//
//  Created by Devan Dutta on 8/12/13.
//
//

#import "CCLayer.h"
#import "GameLayer.h"
#import "CCControlExtension.h"
#import "GameParameters.h"
#import "TextBox.h"
#import <MediaPlayer/MediaPlayer.h>
@interface Settings : CCLayer
{
    MPMusicPlayerController *gameVolume;
    CCControlSlider *gameVolumeSlider;
    CCLabelTTF *gameVolumeLabel;
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
