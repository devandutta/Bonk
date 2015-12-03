/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "Box2D.h"
#import "ContactListener.h"
#import "StartMenuLayer.h"
#import "GameOver.h"
#import "QuestionInfo.h"
#import "GameParameters.h"
#import "CCControlExtension.h"
#import "TextBox.h"
enum
{
	kTagBatchNode,
};

@interface GameLayer : CCLayer <UITextFieldDelegate>
{
    CCSprite *starsExplosion;
    NSMutableArray* starsExplosionFrames;
    CCSpriteBatchNode *starsExplosionSheet;
    int numDigits;
    NSString* completionDisplayText;
    int questionsToGo;
    CCLabelTTF* completionDisplay;
    CCMenuItem* minusSign;
    CCMenuItem* backSpace;
    int positionInTextBoxesArray;
    NSMutableArray *textBoxes;
    NSString* userEntered;
    CCMenu* numPad;
    CCMenuItem* nine_button;
    CCMenuItem* eight_button;
    CCMenuItem* seven_button;
    CCMenuItem* six_button;
    CCMenuItem* five_button;
    CCMenuItem* four_button;
    CCMenuItem* three_button;
    CCMenuItem* two_button;
    CCMenuItem* one_button;
    CCMenuItem *zero_button;
    CCLabelTTF* timerDisplay;
    int questionTimer;
    int resultToCompare;
    UITextField* userResponse;
    int number1;
    int number2;
    int result;
    CCLabelTTF* questionPrompt;
    CCLabelTTF* questionTitle;
    NSString *question;
    CCLabelTTF* Game_Paused_Text;
    bool pauseScreenUp;
    CCLayer *pauseLayer;
    CCMenu *pauseScreenMenu;
    CCMenu *restartMenuButton;
    CCProgressTimer *progressTimer;
    id easeForward;
    id easeBack;
    CCSequence *coconutseq;
    id followArrow;
    //will be used to hide fireButton when necessary
    BOOL gameHasStarted;
    CCMenu *fireButton;
    CCSprite *background;
    id swipeRight;
    id swipeLeft;
    id easeRight;
    id easeLeft;
    CCMenuItemImage *fire;
    int coconutcount;
    int bombCount;
    CCParticleExplosion *bombExplosion;
    id followBomb;
    CCSprite *bomb;
    int bombDelay;
    CCSprite *invisible_arrow;
    CCSprite *arrow;
    CCSprite *man2;
    bool arrowshot;
    int arrowdelay;
	b2World* world;
    int currentBullet;
    NSMutableArray *bullets;
    ContactListener *contactListener;
    b2Body *screenBorderBody;
    b2Fixture *arrowFixture;
    b2Body *arrowBody;
    b2RevoluteJoint *arrowJoint;
    b2MouseJoint *mouseJoint;

}
+(id) scene;
- (void)createBullets;
-(void) sendBullet: (CCMenuItem *)menuItem;
//@property (nonatomic, retain) CCProgressTimer *progressTimer;


@end
