//
//  Settings.m
//  Bonk_v2
//
//  Created by Devan Dutta on 8/12/13.
//
//

#import "Settings.h"

@implementation Settings
+(id) scene
{
    CCScene *scene = [CCScene node];
    Settings *layer = [Settings node];
    [scene addChild:layer];
    return scene;
}
-(id) init
{
    if((self=[super init]))
    {
        gameVolume = [MPMusicPlayerController applicationMusicPlayer];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        background = [CCSprite spriteWithFile:@"background_grass-topdown.png"];
        background.anchorPoint = CGPointZero;
        background.position = ccp(10,0);
        [self addChild:background z:-1];
        
        CCLabelTTF *play_label = [CCLabelTTF labelWithString:@"Play" fontName:@"Helvetica" fontSize:72];
        play_label.color = ccc3(255,0,51);
        CCMenuItemLabel *play = [CCMenuItemLabel itemWithLabel: play_label target: self selector:@selector(reactToPlay:)];
        play.position = ccp(screenSize.width/2, screenSize.height/2+100);
        CCMenu *menu = [CCMenu menuWithItems:play, nil];
        menu.position = ccp(0,0);
        [self addChild:menu];
        
        
        /*CGRect numberQuestionFrame = CGRectMake(screenSize.width/2-125, screenSize.height/2, 250, 30);
         numberQuestionsUI = [[UISlider alloc] initWithFrame:numberQuestionFrame];
         [numberQuestionsUI addTarget:self action:@selector(numberQuestionValueChanged:) forControlEvents:UIControlEventValueChanged];
         [numberQuestionsUI setBackgroundColor:[UIColor clearColor]];
         numberQuestionsUI.minimumValue = 5;
         numberQuestionsUI.maximumValue = 25;
         numberQuestionsUI.continuous = YES;
         numberQuestionsUI.value = 5;
         numberQuestionsUI.minimumTrackTintColor = [UIColor greenColor];
         [[[CCDirector sharedDirector] view] addSubview:numberQuestionsUI];
         */
        
        
        numberQuestionsDisplayValueLabel = [CCLabelTTF labelWithString:@"Number of Questions: 5"
                                                              fontName:@"Marker Felt" fontSize:28];
        numberQuestionsDisplayValueLabel.color = ccc3(0, 0, 0);
        numberQuestionsDisplayValueLabel.position = ccp(screenSize.width/2, screenSize.height/2 + 40);
        [self addChild:numberQuestionsDisplayValueLabel z: 10];
        
        
        /*maxNumber = [[UISlider alloc] initWithFrame:CGRectMake(screenSize.width/2-125, screenSize.height/2+50, 250, 30)];
         [maxNumber addTarget:self action:@selector(maxNumberValueChanged:) forControlEvents:UIControlEventValueChanged];
         [maxNumber setBackgroundColor:[UIColor clearColor]];
         maxNumber.minimumValue=5;
         maxNumber.maximumValue = 30;
         maxNumber.continuous = YES;
         maxNumber.value = 5;
         maxNumber.minimumTrackTintColor = [UIColor purpleColor];
         [[[CCDirector sharedDirector] view] addSubview:maxNumber];
         */
        
        
        maxNumberDisplayValueLabel = [CCLabelTTF labelWithString:@"Max Number: 5" fontName:@"Marker Felt" fontSize:28];
        maxNumberDisplayValueLabel.color = ccc3(0,0,0);
        maxNumberDisplayValueLabel.position = ccp(screenSize.width/2, screenSize.height/2-15);
        [self addChild:maxNumberDisplayValueLabel];
        
        //The width and height parameters are ignored by initWithFrame so that the switch frame is optimized for itself
        
        /*negativeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenSize.width/2+100, screenSize.height/2+105, 0, 0)];
         [negativeSwitch addTarget:self action:@selector(switchActivated:) forControlEvents:UIControlEventValueChanged];
         negativeSwitch.on = NO;
         negativeSwitch.onTintColor = [UIColor redColor];
         negativeSwitch.tintColor = [UIColor greenColor];
         UIColor* thumbTint = [UIColor colorWithRed:131/255.0f green:150/255.0f blue:156/255.0f alpha:1.0f];
         negativeSwitch.thumbTintColor = thumbTint;
         [[[CCDirector sharedDirector] view] addSubview:negativeSwitch];
         */
        
        
        negativeDisplayValueLabel = [CCLabelTTF labelWithString:@"Negative answers: OFF" fontName:@"Marker Felt" fontSize:28];
        negativeDisplayValueLabel.color = ccc3(0,0,0);
        negativeDisplayValueLabel.position = ccp(150,40);
        [self addChild:negativeDisplayValueLabel];
        
        
        numberQuestions = [CCControlSlider sliderWithBackgroundFile:@"sliderTrack.png" progressFile:@"sliderProgress.png" thumbFile:@"sliderThumb.png"];
        numberQuestions.minimumValue = 5.0;
        numberQuestions.maximumValue = 10;
        numberQuestions.position = ccp(screenSize.width/2, screenSize.height/2 +15);
        [numberQuestions addTarget:self action:@selector(numberQuestionsValueChanged:) forControlEvents:CCControlEventValueChanged];
        [self addChild:numberQuestions z:10];
        numberQuestions.value = 5;
        
        maxNumberSlider = [CCControlSlider sliderWithBackgroundFile:@"sliderTrack.png" progressFile:@"sliderProgress.png" thumbFile:@"sliderThumb.png"];
        maxNumberSlider.minimumValue = 5;
        maxNumberSlider.maximumValue = 30;
        maxNumberSlider.position = ccp(screenSize.width/2, screenSize.height/2 - 40);
        [maxNumberSlider addTarget:self action:@selector(maxNumberValueChanged:) forControlEvents:CCControlEventValueChanged];
        [self addChild:maxNumberSlider z:10];
        maxNumberSlider.value = 5;
        
        gameVolumeSlider = [CCControlSlider sliderWithBackgroundFile:@"sliderTrack.png" progressFile:@"sliderProgress.png" thumbFile:@"sliderThumb.png"];
        gameVolumeSlider.position = ccp(screenSize.width/2, screenSize.height/2-85);
        [gameVolumeSlider addTarget:self action:@selector(gameVolumeChanged:) forControlEvents:CCControlEventValueChanged];
        [self addChild:gameVolumeSlider z:10];
        gameVolumeSlider.value = 0.5;
        
        gameVolumeLabel = [CCLabelTTF labelWithString:@"Game Volume" fontName:@"Marker Felt" fontSize:28];
        gameVolumeLabel.color = ccc3(0,0,0);
        gameVolumeLabel.position = ccp(screenSize.width/2, screenSize.height/2-60);
        [self addChild:gameVolumeLabel];
        
        negatives = [CCControlSwitch switchWithMaskFile:@"switch-mask.png" onFile:@"switch-on.png" offFile:@"switch-off.png" thumbFile:@"switch-thumb.png" onTitle:@"On" offTitle:@"Off"];
        [negatives addTarget:self action:@selector(negativeSwitch:) forControlEvents:CCControlEventValueChanged];
        negatives.on = NO;
        negatives.position = ccp(screenSize.width/2+110, screenSize.height/2-118);
        [self addChild:negatives];
        
        
        [self scheduleUpdate];
        
    }
    return self;
}

-(void) gameVolumeChanged: (CCControlSlider *) sender
{
    gameVolume.volume = sender.value;
}

-(void) numberQuestionsValueChanged: (CCControlSlider*) sender
{
    GameParameters *data = [GameParameters sharedData];
    NSString* valueLabelUpdate = [NSString stringWithFormat:@"Number of Questions: %d", (int)numberQuestions.value];
    [numberQuestionsDisplayValueLabel setString:valueLabelUpdate];
    data.numQuestions = (int)numberQuestions.value;
    NSLog(@"Number of Questions: %d", data.numQuestions);
}
-(void) maxNumberValueChanged: (CCControlSlider*) sender
{
    GameParameters* data = [GameParameters sharedData];
    NSString* maxNumberLabelUpdate = [NSString stringWithFormat:@"Max Number: %d", (int)maxNumberSlider.value];
    [maxNumberDisplayValueLabel setString:maxNumberLabelUpdate];
    data.maxNumber = (int)maxNumberSlider.value;
    NSLog(@"Max number: %d", data.maxNumber);
    
}
-(void) negativeSwitch: (CCControlSwitch*) sender
{
    GameParameters* data = [GameParameters sharedData];
    BOOL negativeOn = sender.on;
    NSString* updateNegativeDisplay;
    if(negativeOn==YES)
    {
        updateNegativeDisplay = [NSString stringWithFormat:@"Negative answers: ON"];
        [negativeDisplayValueLabel setString:updateNegativeDisplay];
        data.negativeAnswer = YES;
    }
    else
    {
        updateNegativeDisplay = [NSString stringWithFormat:@"Negative answers: OFF"];
        [negativeDisplayValueLabel setString:updateNegativeDisplay];
        data.negativeAnswer = NO;
    }
    NSLog(@"Negatives: %c", data.negativeAnswer);
}



/*-(void) numberQuestionValueChanged: (UISlider*) sender
 {
 GameParameters *data = [GameParameters sharedData];
 if(numberQuestionsUI.value<7.5)
 {
 numberQuestionsUI.value=5.0;
 }
 else if(numberQuestionsUI.value<=10 && numberQuestionsUI.value>=7.5)
 {
 numberQuestionsUI.value = 10;
 }
 else if(numberQuestionsUI.value<12.5 && numberQuestionsUI.value>=10)
 numberQuestionsUI.value = 10;
 else if(numberQuestionsUI.value<=15 && numberQuestionsUI.value>=12.5)
 numberQuestionsUI.value = 15;
 else if(numberQuestionsUI.value>=15 && numberQuestionsUI.value<17.5)
 numberQuestionsUI.value = 15;
 else if(numberQuestionsUI.value>=17.5 && numberQuestionsUI.value<=20)
 numberQuestionsUI.value = 20;
 else if(numberQuestionsUI.value>=20 && numberQuestionsUI.value<22.5)
 numberQuestionsUI.value = 20;
 else if(numberQuestionsUI.value>=22.5 && numberQuestionsUI.value<=25)
 numberQuestionsUI.value = 25;
 NSString* valueLabelUpdate = [NSString stringWithFormat:@"Number of Questions: %d", (int)numberQuestionsUI.value];
 [numberQuestionsDisplayValueLabel setString:valueLabelUpdate];
 data.numQuestions = (int)numberQuestionsUI.value;
 NSLog(@"Number of Questions: %d", data.numQuestions);
 }
 -(void) maxNumberValueChanged: (UISlider*) sender
 {
 GameParameters* data = [GameParameters sharedData];
 NSString* maxNumberLabelUpdate = [NSString stringWithFormat:@"Max Number: %d", (int) maxNumber.value];
 [maxNumberDisplayValueLabel setString:maxNumberLabelUpdate];
 data.maxNumber = maxNumber.value;
 NSLog(@"Max number: %d", data.maxNumber);
 }
 -(void) switchActivated: (UISwitch*) sender
 {
 GameParameters* data = [GameParameters sharedData];
 BOOL negatives = sender.on;
 NSString* updateNegativeDisplay;
 if(negatives==YES)
 {
 updateNegativeDisplay = [NSString stringWithFormat:@"Negative answers: ON"];
 [negativeDisplayValueLabel setString:updateNegativeDisplay];
 data.negativeAnswer = YES;
 }
 else
 {
 updateNegativeDisplay = [NSString stringWithFormat:@"Negative answers: OFF"];
 [negativeDisplayValueLabel setString:updateNegativeDisplay];
 data.negativeAnswer = NO;
 }
 NSLog(@"Negatives: %c", data.negativeAnswer);
 }
 */
-(void) dealloc
{
#ifndef KK_ARC_ENABLED
    [super dealloc];
#endif
}
-(void) reactToPlay:(CCMenuItem *)menuItem
{
    /*
     numberQuestionsUI.hidden = YES;
     maxNumber.hidden = YES;
     negativeSwitch.hidden = YES;
     
     
     [numberQuestionsUI removeFromSuperview];
     [maxNumber removeFromSuperview];
     [negativeSwitch removeFromSuperview];
     */
    
    CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.7 scene:(CCScene *) [[GameLayer alloc] init]];
    [[CCDirector sharedDirector] replaceScene: transition];
}
-(void) update:(ccTime)delta
{
    if(numberQuestions.value<7.5)
    {
        numberQuestions.value=5.0;
    }
    else if(numberQuestions.value<=10 && numberQuestions.value>=7.5)
    {
        numberQuestions.value = 10;
    }
    else if(numberQuestions.value<12.5 && numberQuestions.value>=10)
        numberQuestions.value = 10;
    else if(numberQuestions.value<=15 && numberQuestions.value>=12.5)
        numberQuestions.value = 15;
    else if(numberQuestions.value>=15 && numberQuestions.value<17.5)
        numberQuestions.value = 15;
    else if(numberQuestions.value>=17.5 && numberQuestions.value<=20)
        numberQuestions.value = 20;
    else if(numberQuestions.value>=20 && numberQuestions.value<22.5)
        numberQuestions.value = 20;
    else if(numberQuestions.value>=22.5 && numberQuestions.value<=25)
        numberQuestions.value = 25;
    
}

@end
