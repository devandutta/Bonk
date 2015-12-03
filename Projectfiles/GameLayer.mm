/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "CCCamera.h"
#import "GameOver.h"
#import "CCScheduler.h"
#import "GameParameters.h"
const float PTM_RATIO = 32.0f;


CCSprite *projectile;
CCSprite *block;
CCSprite *arrow;
CCSprite *coconut;
CCSprite *coconut2;
CGRect firstrect;
CGRect secondrect;
NSMutableArray *blocks = [[NSMutableArray alloc] init];
//NSMutableArray for already shown animations
NSMutableArray *shownAnimations;

@interface GameLayer (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;
@end

@implementation GameLayer
//@synthesize progressTimer;

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        //User swipe motions
        
        swipeRight = [CCMoveTo actionWithDuration:.5 position:ccp(self.position.x - 60, self.position.y)];
        easeRight = [CCEaseIn actionWithAction:swipeRight rate:1];
        swipeLeft = [CCMoveTo actionWithDuration:.5 position:ccp(self.position.x + 30, self.position.y)];
        easeLeft = [CCEaseIn actionWithAction:swipeLeft rate:1];
        
        //End user swipe motions
        bullets = [[NSMutableArray alloc] init];
        
        //Configure pause button on game layer
        
        pauseScreenUp = FALSE;
        CCMenuItem *pauseMenuItem = [CCMenuItemImage itemWithNormalImage:@"button_pausebutton.png" selectedImage:@"button_pausebutton.png" target:self selector:@selector(PauseButtonActivated:)];
        pauseMenuItem.scale=0.3;
        pauseMenuItem.position = ccp(430,290);
        CCMenu *pause = [CCMenu menuWithItems:pauseMenuItem, nil];
        pause.position = CGPointZero;
        [self addChild: pause z:2];
        
        //End configuration of pause button on game layer
        
        // Construct a world object, which will hold and simulate the rigid bodies.
		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
		world = new b2World(gravity);
		world->SetAllowSleeping(YES);
		//world->SetContinuousPhysics(YES);
        
        //create an object that will check for collisions
		contactListener = new ContactListener();
		world->SetContactListener(contactListener);
        
		glClearColor(0.1f, 0.0f, 0.2f, 1.0f);
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSLog(@"%f",self.position.x);
        
        b2Vec2 lowerLeftCorner =b2Vec2(0,0);
		b2Vec2 lowerRightCorner = b2Vec2(screenSize.width*2.0f/PTM_RATIO,0);
		b2Vec2 upperLeftCorner = b2Vec2(0,screenSize.height/PTM_RATIO);
		b2Vec2 upperRightCorner = b2Vec2(screenSize.width*2.0f/PTM_RATIO,screenSize.height/PTM_RATIO);
		
		// Define the static container body, which will provide the collisions at screen borders.
		b2BodyDef screenBorderDef;
		screenBorderDef.position.Set(0, 0);
        screenBorderBody = world->CreateBody(&screenBorderDef);
		b2EdgeShape screenBorderShape;
        
        screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
        screenBorderBody->CreateFixture(&screenBorderShape, 0);
        
        screenBorderShape.Set(lowerRightCorner, upperRightCorner);
        screenBorderBody->CreateFixture(&screenBorderShape, 0);
        
        screenBorderShape.Set(upperRightCorner, upperLeftCorner);
        screenBorderBody->CreateFixture(&screenBorderShape, 0);
        
        screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
        screenBorderBody->CreateFixture(&screenBorderShape, 0);
        
        
        //Add the background
        
        background = [CCSprite spriteWithFile:@"Background_white.png"];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        [self addChild:background z:-1];
        
        //Left player
        
        CCSprite *tree = [CCSprite spriteWithFile:@"palmtree.png"];
        tree.anchorPoint = ccp(0,0);
        tree.position = ccp(10,0);
        [self addChild:tree z:0];
        
        coconut = [CCSprite spriteWithFile:@"coconut_transparent.png"];
        coconut.scale = 0.1;
        coconut.anchorPoint=ccp(0,0);
        coconut.position = ccp(115,155);
        coconut.visible = NO;
        [self addChild:coconut z:1];
        
        CCSprite *man = [CCSprite spriteWithFile:@"manFigure.png"];
        man.anchorPoint = ccp(0,0);
        man.position = ccp(120,10);
        [self addChild:man z:1];
        
        //Right player
        
        CCSprite *tree_2 = [CCSprite spriteWithFile:@"palmtree.png"];
        tree_2.position = ccp(900,140);
        [self addChild:tree_2 z:0];
        
        coconut2 = [CCSprite spriteWithFile:@"coconut_transparent.png"];
        coconut2.scale = 0.1;
        coconut2.anchorPoint=ccp(0,0);
        coconut2.position = ccp(875,170);
        coconut2.visible = NO;
        [self addChild:coconut2 z:1];

        man2 = [CCSprite spriteWithFile:@"manFigure.png"];
        man2.anchorPoint=ccp(0,0);
        man2.position = ccp(820,25);
        [self addChild:man2 z:1];
        
       /* //Put in right player's health bar
        
        CCSprite *health = [CCSprite spriteWithFile:@"green_health.png"];
        
        self.progressTimer = [CCProgressTimer progressWithSprite:health];
        self.progressTimer.type = kCCProgressTimerTypeBar;
        self.progressTimer.percentage = 100.0;
        self.progressTimer.position = ccp(850,300);
        [self addChild:self.progressTimer];
        */
        
        //Put in fire button
        
        fire = [CCMenuItemImage
                                       itemWithNormalImage:@"button_play.png"
                                       selectedImage:@"button_play.png"
                                       target: self selector:@selector(sendBullet:)];
        
        fireButton = [CCMenu menuWithItems: fire,nil];
        fireButton.position = ccp(140,-40);
        fireButton.scale = .5;
        [self addChild: fireButton z: 3];
        gameHasStarted = NO;
        [followArrow setTag: 1];
        
        // Setting the properties of our definition
        b2BodyDef arrowBodyDef;
        arrowBodyDef.type = b2_dynamicBody;
        //other types of bodies include static (immovable) bodies and kinematic bodies
        arrowBodyDef.linearDamping = 1;
        //linear damping affects how much the velocity of an object slows over time - this is in addition to friction
        arrowBodyDef.angularDamping = 1;
        //causes rotations to slow down. A value of 0 means there is no slowdown
        arrowBodyDef.position.Set(150.0f/PTM_RATIO,80.f/PTM_RATIO);
        arrowBodyDef.userData = (__bridge void*)arrow; //this tells the Box2D body which sprite to update.
        
        //create a body with the definition we just created
        arrowBody = world->CreateBody(&arrowBodyDef);
        //the -> is C++ syntax; it is like calling an object's methods (the CreateBody "method")
        
        //Create a fixture for the arm
        b2PolygonShape arrowBox;
        b2FixtureDef arrowBoxDef;
        arrowBoxDef.shape = &arrowBox; //geometric shape
        arrowBoxDef.density = 0.3F; //affects collision momentum and inertia
        arrowBox.SetAsBox(15.0f/PTM_RATIO, 140.0f/PTM_RATIO);
        //this is based on the dimensions of the arm which you can get from your image editing software of choice
        arrowFixture = arrowBody->CreateFixture(&arrowBoxDef);
        
        // Create a joint to fix the arrow to the position it's at.
        b2RevoluteJointDef arrowJointDef;
        arrowJointDef.Initialize(screenBorderBody, arrowBody, b2Vec2(150.0f/PTM_RATIO, 80.0f/PTM_RATIO));
        
        arrowJointDef.enableMotor = true; // the motor will fight against our motion, sort of like a spring
        arrowJointDef.motorSpeed  = -5; // this sets the motor to move the arm clockwise, so when you pull it back it springs forward
        arrowJointDef.maxMotorTorque = 300; //this limits the speed at which the arrow will shoot forward
        arrowJointDef.enableLimit = true;
        arrowJoint = (b2RevoluteJoint*)world->CreateJoint(&arrowJointDef);
        
        //NSMutableArray for already shown animations
        shownAnimations = [[NSMutableArray alloc] init];
        
        //Load the arrow shot sound, coconut artillery sound, uh oh sound, boing, funny high giggle, fireworks, glass breaking, comedy male laugh, balloon inflating,
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"arrowDamage.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"incoming-artillery"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"55001__stib__uh-oh.aiff"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Boing.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"funny-high-giggle.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Fireworks_lower_quality.aif"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"crash_glass.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"comedy_male_cartoon_character_laughing.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Balloon_Inflating.wav"];
        //schedules a call to the update method every frame
		[self scheduleUpdate];
        //Load relevant data
        GameParameters* data = [GameParameters sharedData];
        questionsToGo = data.numQuestions;
        completionDisplayText = [NSString stringWithFormat:@"%d more", questionsToGo];
        completionDisplay = [CCLabelTTF labelWithString:completionDisplayText fontName:@"Marker Felt" fontSize:30];
        [completionDisplay setColor:ccc3(51, 204, 255)];
		completionDisplay.position = ccp(320,90);
		[self addChild:completionDisplay];

	}
    
	return self;
}

-(void) PauseButtonActivated: (id) sender
{
    if(pauseScreenUp==FALSE)
    {
        if(gameHasStarted==NO)
        {
            fireButton.visible = NO;
        }
        pauseScreenUp=TRUE;
        //If I have background music, uncomment this line to pause the music as well
        //[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        [[CCDirector sharedDirector] pause];
        CGSize size = [[CCDirector sharedDirector] winSize];
        pauseLayer = [CCLayerColor layerWithColor: ccc4(150, 150, 150, 125) width: size.width height: size.width];
        pauseLayer.position = CGPointZero;
        [self addChild:pauseLayer z:8];
        CCMenuItem *resumeMenuItem = [CCMenuItemImage itemWithNormalImage:@"button_playbutton.png" selectedImage:@"button_playbutton.png" target:self selector:@selector(ResumeButtonActivated:)];
        resumeMenuItem.position = ccp(250,170);
        pauseScreenMenu = [CCMenu menuWithItems:resumeMenuItem, nil];
        pauseScreenMenu.position = ccp(0,0);
        [self addChild: pauseScreenMenu z:10];
        
        CCMenuItem *restartMenuItem = [CCMenuItemImage itemWithNormalImage:@"restart.png" selectedImage:@"restart.png" target:self selector:@selector(reactToRestart:)];
        restartMenuItem.position = ccp(45,50);
        restartMenuItem.scale = 0.5;
        restartMenuButton = [CCMenu menuWithItems:restartMenuItem, nil];
        restartMenuButton.position = ccp(0,0);
        [self addChild:restartMenuButton z:10];
        
        Game_Paused_Text = [CCLabelTTF labelWithString:@"Game Paused" fontName:@"Marker Felt" fontSize:48];
        [Game_Paused_Text setColor:ccc3(255, 0, 0)];
		Game_Paused_Text.position = ccp(250,270);
		[self addChild:Game_Paused_Text];
        questionTitle.visible = NO;
        questionPrompt.visible = NO;
        userResponse.hidden = YES;
        numPad.visible = NO;
        for(TextBox* textBox in textBoxes)
        {
            textBox.roundedBlueRect.visible = NO;
            textBox.text.visible = NO;
        }
    }
}

-(void) reactToRestart: (CCMenuItem *) menuItem;
{
    GameParameters *data = [GameParameters sharedData];
    [self removeChild:pauseScreenMenu cleanup:YES];
    [self removeChild:pauseLayer cleanup:YES];
    [self removeChild:Game_Paused_Text cleanup:YES];
    [self removeChild:restartMenuButton cleanup:YES];
    if([data.responseData count]>0)
    {
        [data.responseData removeAllObjects];
    }
    pauseScreenUp = FALSE;
    [[CCDirector sharedDirector] resume];
    CCTransitionSlideInL *transition = [CCTransitionSlideInL transitionWithDuration:0.7 scene:(CCScene *) [[StartMenuLayer alloc] init]];
    [[CCDirector sharedDirector] replaceScene: transition];
    
    
}

-(void) ResumeButtonActivated: (id) sender
{
    if(gameHasStarted==NO)
    {
        fireButton.visible = YES;
    }
    [self removeChild: pauseScreenMenu cleanup:YES];
    [self removeChild:pauseLayer cleanup: YES];
    [self removeChild:Game_Paused_Text cleanup:YES];
    [self removeChild:restartMenuButton cleanup:YES];
    [[CCDirector sharedDirector] resume];
    pauseScreenUp = FALSE;
    questionTitle.visible = YES;
    questionPrompt.visible = YES;
    //userResponse.hidden = NO;
    numPad.visible = YES;
    for(TextBox* textBox in textBoxes)
    {
        textBox.roundedBlueRect.visible = YES;
        textBox.text.visible = YES;
    }

}

//Question will be asked in here

-(void) sendBullet: (id) sender
{
    gameHasStarted = YES;
    [self generateQuestion];
    //hide the play button after the user taps it the first time
    fireButton.visible = NO;
}
-(void) generateQuestion
{
    GameParameters* data = [GameParameters sharedData];
    NSLog(@"Fire");
    userEntered = @"";
    //Create the numpad
    zero_button = [CCMenuItemImage itemWithNormalImage:@"0_smaller.png" selectedImage:@"0_smaller.png" target:self selector:@selector(editTextBox:)];
    zero_button.scale = 0.4;
    zero_button.position = ccp(390,230);
    zero_button.tag = 0;
    one_button = [CCMenuItemImage itemWithNormalImage:@"one_smaller.png" selectedImage:@"one_smaller.png" target:self selector:@selector(editTextBox:)];
    one_button.scale = 0.4;
    one_button.position = ccp(453,230);
    one_button.tag = 1;
    two_button = [CCMenuItemImage itemWithNormalImage:@"two_smaller.png" selectedImage:@"two_smaller.png" target:self selector:@selector(editTextBox:)];
    two_button.scale = 0.4;
    two_button.position = ccp(390,190);
    two_button.tag = 2;
    three_button = [CCMenuItemImage itemWithNormalImage:@"three_smaller.png" selectedImage:@"three_smaller.png" target:self selector:@selector(editTextBox:)];
    three_button.scale = 0.4;
    three_button.position = ccp(453,190);
    three_button.tag = 3;
    four_button = [CCMenuItemImage itemWithNormalImage:@"four_smaller.png" selectedImage:@"four_smaller.png" target:self selector:@selector(editTextBox:)];
    four_button.scale = 0.4;
    four_button.position = ccp(390,150);
    four_button.tag = 4;
    five_button = [CCMenuItemImage itemWithNormalImage:@"five_smaller.png" selectedImage:@"five_smaller.png" target:self selector:@selector(editTextBox:)];
    five_button.scale = 0.4;
    five_button.position = ccp(453,150);
    five_button.tag = 5;
    six_button = [CCMenuItemImage itemWithNormalImage:@"six_smaller.png" selectedImage:@"six_smaller.png" target:self selector:@selector(editTextBox:)];
    six_button.scale = 0.4;
    six_button.position = ccp(390,110);
    six_button.tag = 6;
    seven_button = [CCMenuItemImage itemWithNormalImage:@"seven_smaller.png" selectedImage:@"seven_smaller.png" target:self selector:@selector(editTextBox:)];
    seven_button.scale = 0.4;
    seven_button.position = ccp(453,110);
    seven_button.tag = 7;
    eight_button = [CCMenuItemImage itemWithNormalImage:@"eight_smaller.png" selectedImage:@"eight_smaller.png" target:self selector:@selector(editTextBox:)];
    eight_button.scale = 0.4;
    eight_button.position = ccp(390,70);
    eight_button.tag = 8;
    nine_button = [CCMenuItemImage itemWithNormalImage:@"nine_smaller.png" selectedImage:@"nine_smaller.png" target:self selector:@selector(editTextBox:)];
    nine_button.scale = 0.4;
    nine_button.position = ccp(453,70);
    nine_button.tag = 9;
    backSpace = [CCMenuItemImage itemWithNormalImage:@"backArrow.png" selectedImage:@"backArrow.png" target:self selector:@selector(editTextBox:)];
    backSpace.scale = 0.4;
    backSpace.position = ccp(390,30);
    backSpace.tag = 10;
    minusSign = [CCMenuItemImage itemWithNormalImage:@"minus_sign.png" selectedImage:@"minus_sign.png" target:self selector:@selector(editTextBox:)];
    minusSign.scale = 0.4;
    minusSign.position = ccp(453,30);
    minusSign.tag = 11;
    numPad = [CCMenu menuWithItems:zero_button, one_button, two_button, three_button, four_button, five_button,
              six_button, seven_button, eight_button, nine_button, backSpace, minusSign, nil];
    numPad.position = ccp(0,0);
    [self addChild: numPad z:10];
    
    BOOL negativeAnswers = data.negativeAnswer;
    int questionType = arc4random_uniform(2);
    number1 = arc4random_uniform(data.maxNumber+1);
    number2 = arc4random_uniform(data.maxNumber+1);
    fire.visible = NO;
    //set up the timer for each question by using schedule
    [self schedule:@selector(increaseTimerDisplay:) interval:1.0f];
    questionTimer = 0;
    timerDisplay = [CCLabelTTF labelWithString:@"0 sec" fontName:@"Marker Felt" fontSize:28];
    [timerDisplay setColor:ccc3(51, 0, 153)];
    timerDisplay.position = ccp(50,270);
    [self addChild:timerDisplay];
    if(questionType==0)
    {
        result = number1+number2;
        if(number1<10)
        {
            question = [NSString stringWithFormat:@"%7d\n + %3d", number1,number2];
            
        }
        else
        {
            question = [NSString stringWithFormat:@"%5d\n + %3d", number1,number2];
        }
        questionTitle = [CCLabelTTF labelWithString:@"Addition!" fontName:@"Marker Felt" fontSize:48];
        [questionTitle setColor:ccc3(255, 0, 0)];
        questionTitle.position = ccp(250,290);
        [self addChild:questionTitle];
    }
    else if(questionType==1)
    {
        result = number1-number2;
        if(result<0 && negativeAnswers==NO)
        {
            [self generateSubtractionQuestionNoNegative];
        }
        if(number1<10)
        {
            question = [NSString stringWithFormat:@"%7d\n - %3d", number1, number2];
        }
        else
        {
            question = [NSString stringWithFormat:@"%5d\n - %3d", number1,number2];
        }
        questionTitle = [CCLabelTTF labelWithString:@"Subtraction!" fontName:@"Marker Felt" fontSize:48];
        [questionTitle setColor:ccc3(255, 0, 0)];
        questionTitle.position = ccp(250,290);
        [self addChild:questionTitle];
    }
    
    questionPrompt = [CCLabelTTF labelWithString:question fontName:@"Marker Felt" fontSize:36];
    [questionPrompt setColor:ccc3(0, 0, 204)];
    questionPrompt.position = ccp(290,210);
    [self addChild:questionPrompt];
    [self schedule:@selector(rotateQuestionPrompt:) interval:2.0f];
    
    positionInTextBoxesArray = 0;
    textBoxes = [[NSMutableArray alloc] init];
    if(result<=-10)
    {
        numDigits = 3;
    }
    else if(result<0 && result>-10)
    {
        numDigits = 2;
    }
    else if(result>=0 && result<10)
    {
        numDigits = 1;
    }
    else if(result>=10)
    {
        numDigits = 2;
    }
    
    if(numDigits == 1)
    {
        TextBox* text = [[TextBox alloc] init];
        text.roundedBlueRect.position = ccp(315,140);
        text.text.position = ccp(260 + text.roundedBlueRect.size.width/2 + 55, 140 + text.roundedBlueRect.size.height/2);
        [self addChild:text.roundedBlueRect];
        [self addChild:text.text z:3];
        [textBoxes addObject:text];
    }
    else if(numDigits==2)
    {
        for(int x=0; x<numDigits; x++)
        {
            TextBox* text = [[TextBox alloc] init];
            text.roundedBlueRect.position = ccp(280 + (text.roundedBlueRect.contentSize.width)*x,140);
            if(x == 0){
            text.text.position = ccp(280 + text.roundedBlueRect.size.width/2 +(text.roundedBlueRect.size.width)*x, 140 + text.roundedBlueRect.size.height/2);
            }
            if(x == 1){
                text.text.position = ccp(280 + text.roundedBlueRect.size.width/2 +(text.roundedBlueRect.size.width)*x + 50, 140 + text.roundedBlueRect.size.height/2);

            }
            [self addChild:text.roundedBlueRect];
            [self addChild:text.text z:3];
            [textBoxes addObject:text];
        }
    }
    else if(numDigits==3)
    {
        for(int x=0; x<numDigits; x++)
        {
            TextBox* text = [[TextBox alloc] init];
            text.roundedBlueRect.position = ccp(250 + (text.roundedBlueRect.contentSize.width)*x,140);
            if(x == 0 ){
            text.text.position = ccp(250 + text.roundedBlueRect.size.width/2 +(text.roundedBlueRect.size.width)*x, 140 + text.roundedBlueRect.size.height/2);
            }
            if(x ==1){
                 text.text.position = ccp(250 + text.roundedBlueRect.size.width/2 +(text.roundedBlueRect.size.width)*x + 50, 140 + text.roundedBlueRect.size.height/2);
            }
            if(x == 2){
                 text.text.position = ccp(250 + text.roundedBlueRect.size.width/2 +(text.roundedBlueRect.size.width)*x + 100, 140 + text.roundedBlueRect.size.height/2);
            }
            [self addChild:text.roundedBlueRect];
            [self addChild:text.text z:3];
            [textBoxes addObject:text];
        }

    }
    userResponse = [[UITextField alloc] initWithFrame:CGRectMake(270, 155, 80, 50)];
    userResponse.delegate = self;
    userResponse.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    userResponse.textAlignment = UITextAlignmentCenter;
    userResponse.placeholder = @"Ans.";
    userResponse.borderStyle = UITextBorderStyleRoundedRect;
    userResponse.enabled = NO;
    userResponse.hidden = YES;
    [userResponse setBackgroundColor:[UIColor blueColor]];
    UIColor* textColor = [UIColor colorWithRed:255/255.0f green:234/255.0f blue:40/255.0f alpha:1.0f];
    userResponse.textColor = textColor;
    //[userResponse setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    //userResponse.returnKeyType = UIReturnKeyGo;
    [[[CCDirector sharedDirector] view] addSubview:userResponse];
}
-(void) generateSubtractionQuestionNoNegative
{
    GameParameters* data = [GameParameters sharedData];
    number1 = arc4random_uniform(data.maxNumber + 1);
    number2 = arc4random_uniform(data.maxNumber + 1);
    result = number1-number2;
    if(result<0)
        [self generateSubtractionQuestionNoNegative];
}
-(void) putCharInTextBox
{
    TextBox* text = [textBoxes objectAtIndex:positionInTextBoxesArray];
    [text.text setString:[NSString stringWithFormat:@"%c", [userEntered characterAtIndex:positionInTextBoxesArray]]];
    positionInTextBoxesArray++;
    NSLog(@"Position in textBoxesArray: %i", positionInTextBoxesArray);
}

-(void) editTextBox: (CCMenuItem *) menuItem
{
    //NSLog(@"%d",menuItem.tag);
    if(menuItem.tag==0)
    {
        userEntered = [NSString stringWithFormat:@"%@0",userEntered];
        NSLog(@"%@", userEntered);
        [self putCharInTextBox];
    }
    else if (menuItem.tag==1)
    {
        userEntered = [NSString stringWithFormat:@"%@1", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==2)
    {
        userEntered = [NSString stringWithFormat:@"%@2", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==3)
    {
        userEntered = [NSString stringWithFormat:@"%@3", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==4)
    {
        userEntered = [NSString stringWithFormat:@"%@4", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==5)
    {
        userEntered = [NSString stringWithFormat:@"%@5", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==6)
    {
        userEntered = [NSString stringWithFormat:@"%@6", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==7)
    {
        userEntered = [NSString stringWithFormat:@"%@7", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==8)
    {
        userEntered = [NSString stringWithFormat:@"%@8", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==9)
    {
        userEntered = [NSString stringWithFormat:@"%@9", userEntered];
        [self putCharInTextBox];
    }
    else if (menuItem.tag==10)
    {
        if([userEntered length]==0)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"Boing.wav"];
        }
        else
        {
            TextBox *text;
            userEntered = [userEntered substringToIndex:[userEntered length]-1];
            if(positionInTextBoxesArray>0)
            {
                text = [textBoxes objectAtIndex:positionInTextBoxesArray-1];
                [text.text setString:@""];
                positionInTextBoxesArray--;
            }
            NSLog(@"Position in TextBoxesArray: %i \n CCLabelTTF value: %@", positionInTextBoxesArray,text.text.string);
        }
    }
    else if (menuItem.tag == 11)
    {
        userEntered = [NSString stringWithFormat:@"%@-", userEntered];
        [self putCharInTextBox];
    }
    
    CCSequence *growAndShrinkNumSeq = [CCSequence actions: [CCCallFuncN actionWithTarget:self selector:@selector(growItem:)], [CCDelayTime actionWithDuration:0.1], [CCCallFuncN actionWithTarget:self selector:@selector(shrinkItemBack:)], nil];
    [menuItem runAction:growAndShrinkNumSeq];
    userResponse.text = userEntered;
    
    if(result<10 && result>=0)
    {
        if([userEntered length]==1)
        {
            [self checkAnswer];
        }
            
    }
    else if (result>=10)
    {
        if ([userEntered length]==2)
        {
            [self checkAnswer];
        }
    }
    else if (result<0 && result>-10)
    {
        if([userEntered length]==2)
        {
            [self checkAnswer];
        }
    }
    else if(result<=-10)
    {
        if([userEntered length]==3)
            [self checkAnswer];
    }
}
-(void) growItem: (CCMenuItem *) menuItem
{
    menuItem.scale = 1;
}

-(void) shrinkItemBack: (CCMenuItem *) menuItem
{
    menuItem.scale = 0.4;
}

-(void) checkAnswer
{
    /*
    // dismiss the keyboard
    [textField resignFirstResponder];
    // if the text is empty, remove the text field
    if (textField.text.length == 0)
    {
        [textField removeFromSuperview];
    }
    //NSString* userEntered = textField.text;
     */
    GameParameters *data = [GameParameters sharedData];
    resultToCompare = [userEntered intValue];
    if(resultToCompare==result)
    {
        QuestionInfo* element = [[QuestionInfo alloc] initWithCorrect:YES andTime:questionTimer];
        NSLog(@"Was it Correct: %hhd  andTime: %d", element.correct, element.timeToResponse);
        [data.responseData addObject:element];
        
        CCSprite* checkMark = [CCSprite spriteWithFile:@"Check_mark.png"];
        checkMark.anchorPoint = ccp(0,0);
        checkMark.scale = 0.3;
        checkMark.position = ccp(10,0);
        [self addChild:checkMark z:0];
        id delay = [CCDelayTime actionWithDuration:0.5];
        id hideCheckMark = [CCHide action];
        id hideCheckMarkSequence = [CCSequence actions:delay,hideCheckMark, nil];
        [checkMark runAction:hideCheckMarkSequence];
        questionTimer = 0;
        [self unschedule:@selector(increaseTimerDisplay:)];
        CCLabelTTF* GreatJob = [CCLabelTTF labelWithString:@"Great job!" fontName:@"Marker Felt" fontSize:40.0f];
        [GreatJob setColor:ccc3(255, 0, 0)];
        GreatJob.position = ccp(300,125);
        GreatJob.visible = NO;
        [self addChild:GreatJob];
        id showGreatJob = [CCShow action];
        id showGreatJobSeq = [CCSequence actions:[CCDelayTime actionWithDuration:1.3f], showGreatJob, nil];
        [GreatJob runAction:showGreatJobSeq];
        
        id GreatJobDelay = [CCDelayTime actionWithDuration:1.3f];
        id hideGreatJob = [CCHide action];
        int weaponToSelect = arc4random_uniform(3);
        NSNumber* weaponToSelectObject = [NSNumber numberWithInt:weaponToSelect];
        id hideGreatJobSeq;
        
        if([shownAnimations count]==3)
        {
            [shownAnimations removeAllObjects];
        }
        while([shownAnimations containsObject:weaponToSelectObject]==YES)
        {
            weaponToSelect = arc4random_uniform(3);
            weaponToSelectObject = [NSNumber numberWithInt:weaponToSelect];
        }
        [shownAnimations addObject:weaponToSelectObject];
        
        if(weaponToSelect==0)
        {
            data.weapon = @"Bomb";
            hideGreatJobSeq = [CCSequence actions: [CCCallFuncN actionWithTarget:self selector:@selector(removeNumPad)],[CCDelayTime actionWithDuration:1.1f],[CCCallFuncN actionWithTarget:self selector:@selector(cleanQuestion)],GreatJobDelay, hideGreatJob, [CCCallFuncN actionWithTarget:self selector:@selector(createBomb)], nil];
        }
        else if(weaponToSelect==1)
        {
            data.weapon = @"Coconut";
            hideGreatJobSeq = [CCSequence actions: [CCCallFuncN actionWithTarget:self selector:@selector(removeNumPad)],[CCDelayTime actionWithDuration:1.1f],[CCCallFuncN actionWithTarget:self selector:@selector(cleanQuestion)],GreatJobDelay, hideGreatJob, [CCCallFuncN actionWithTarget:self selector:@selector(createBullets)], nil];
        }
        else if(weaponToSelect==2)
        {
            data.weapon = @"Stars";
            hideGreatJobSeq = [CCSequence actions: [CCCallFuncN actionWithTarget:self selector:@selector(removeNumPad)],[CCDelayTime actionWithDuration:1.1f],[CCCallFuncN actionWithTarget:self selector:@selector(cleanQuestion)],GreatJobDelay, hideGreatJob, [CCCallFuncN actionWithTarget:self selector:@selector(starsExplosionEffect)], nil];
        }
        
        [GreatJob runAction:hideGreatJobSeq];

    }
    else
    {
        [self unschedule:@selector(increaseTimerDisplay:)];
        QuestionInfo *element = [[QuestionInfo alloc] initWithCorrect:NO andTime:questionTimer];
        NSLog(@"Was it Correct: %hhd andTime: %d", element.correct, element.timeToResponse);
        [data.responseData addObject:element];
        
        CCSprite* crossMark = [CCSprite spriteWithFile:@"Cross_mark.png"];
        crossMark.anchorPoint = ccp(0,0);
        crossMark.scale=0.8;
        crossMark.position = ccp(10,70);
        [self addChild:crossMark z:0];
        id delay = [CCDelayTime actionWithDuration:0.5];
        id hideCrossMark = [CCHide action];
        id hideCrossMarkSequence = [CCSequence actions:[CCCallFuncN actionWithTarget:self selector:@selector(removeNumPad)],delay,hideCrossMark, [CCCallFuncN actionWithTarget:self selector:@selector(cleanQuestion)], nil];
        [crossMark runAction:hideCrossMarkSequence];
        questionTimer = 0;
        CCLabelTTF* tryAgain = [CCLabelTTF labelWithString:@"Try again!" fontName:@"Marker Felt" fontSize:40.0f];
        [tryAgain setColor:ccc3(255, 0, 0)];
        tryAgain.position = ccp(300,125);
        id showTryAgain = [CCShow action];
        tryAgain.visible = NO;
        [self addChild:tryAgain];
        id showTryAgainSeq = [CCSequence actions: delay, showTryAgain, nil];
        [tryAgain runAction:showTryAgainSeq];
        id tryAgainDelay = [CCDelayTime actionWithDuration:1.3f];
        id hideTryAgain = [CCHide action];
        id hideTryAgainSeq = [CCSequence actions: tryAgainDelay, hideTryAgain, nil];
        [tryAgain runAction:hideTryAgainSeq];
        [[SimpleAudioEngine sharedEngine] playEffect:@"55001__stib__uh-oh.aiff"];
    }
    NSLog(@"You entered %@", userResponse.text);
    questionsToGo--;
    completionDisplayText = [NSString stringWithFormat:@"%d more", questionsToGo];
    [completionDisplay setString:completionDisplayText];
}

-(void) removeNumPad
{
    [self removeChild:numPad cleanup:YES];
}

-(void) cleanQuestion
{
    [self removeChild: questionTitle cleanup: YES];
    [self removeChild:questionPrompt cleanup:YES];
    //fire.visible = YES;
    [self removeChild:timerDisplay cleanup:YES];
    //[self removeChild:numPad cleanup:YES];
    [self unschedule:@selector(rotateQuestionPrompt:)];
    for(int x=0; x<numDigits; x++)
    {
        TextBox *text = [textBoxes objectAtIndex:x];
        [self removeChild:text.roundedBlueRect];
        [self removeChild:text.text];
    }
    [textBoxes removeAllObjects];
    [userResponse removeFromSuperview];
    [self continueAnalysis];
    
}
-(void) increaseTimerDisplay: (ccTime)dt
{
    questionTimer++;
    NSString* updatedTime = [NSString stringWithFormat:@"%d sec", questionTimer];
    [timerDisplay setString:updatedTime];
    id grow = [CCScaleTo actionWithDuration:0.1f scale:2.0f];
    id shrink = [CCScaleTo actionWithDuration:0.1f scale:1.0f];
    id growShrinkSeq = [CCSequence actions: grow, shrink, nil];
    [timerDisplay runAction:growShrinkSeq];
}
-(void) rotateQuestionPrompt: (ccTime)dt
{
    id rotateLeft = [CCRotateTo actionWithDuration:0.5 angle:-5];
    id rotateBackLeftCenter = [CCRotateTo actionWithDuration:0.5 angle:0];
    id rotateRight = [CCRotateTo actionWithDuration:0.5 angle:5];
    id rotateBackRightCenter = [CCRotateTo actionWithDuration:0.5 angle:0];
    id rotationSeq = [CCSequence actions: rotateLeft, rotateBackLeftCenter, rotateRight, rotateBackRightCenter, nil];
    [questionPrompt runAction:rotationSeq];
}

+(id) scene
{
    CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
    GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)createBomb
{
    bombCount = 0;
    bomb = [CCSprite spriteWithFile:@"black_bomb_smaller.png"];
    [self addChild:bomb];
    //Start point for bezier path
    bomb.position = ccp(100,40);
    NSMutableArray *bezierArray = [NSMutableArray array];
    //Add beziers
    //Bezier 0
    ccBezierConfig bzConfig_0;
    bzConfig_0.controlPoint_1 = ccp(480,500);
    bzConfig_0.controlPoint_2 = ccp(360,400);
    bzConfig_0.endPosition = ccp(830,70);
    CCBezierTo *bezierTo_0 = [CCBezierTo actionWithDuration:2 bezier:bzConfig_0];
    [bezierArray addObject:bezierTo_0];
    //create action sequence and run action
    CCSequence *bezierSeq = [CCSequence actionWithArray:bezierArray];
    [bomb runAction:bezierSeq];
    
    CCSprite *smiley = [CCSprite spriteWithFile:@"face-grin_smaller.png"];
    smiley.position = ccp(135,80);
    smiley.scale = 0.3;
    [self addChild:smiley z:4];
    CCFadeOut *fadeSmiley = [CCFadeOut actionWithDuration:1.5];
    CCScaleTo *growSmiley = [CCScaleTo actionWithDuration:0.5 scale:1];
    [smiley runAction:growSmiley];
    [smiley runAction:fadeSmiley];
    followBomb = [CCFollow actionWithTarget:bomb worldBoundary: CGRectMake(0, 0, 960, 320)];
    [self runAction: followBomb];
    CCSequence *fireworksSoundEffect = [CCSequence actions:[CCCallFuncN actionWithTarget:self selector:@selector(giggleAudioEffect)],[CCDelayTime actionWithDuration:2],[CCCallFuncN actionWithTarget:self selector:@selector(fireworksEffect)], nil];
    [self runAction:fireworksSoundEffect];
    CCSequence *yeeHa = [CCSequence actions:[CCDelayTime actionWithDuration:1.1],[CCCallFuncN actionWithTarget:self selector:@selector(yeeHaSoundEffect)], nil];
    [self runAction:yeeHa];
}

-(void) yeeHaSoundEffect
{
    /*SystemSoundID yeeHaAudioEffect;
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"comedy_male_yelling_yee_ha" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &yeeHaAudioEffect);
    AudioServicesPlaySystemSound(yeeHaAudioEffect);
     */
     
    [[SimpleAudioEngine sharedEngine] playEffect:@"comedy_male_yelling_yee_ha.mp3"];

}
-(void) giggleAudioEffect
{
    SystemSoundID giggleAudioEffect;
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"funny-high-giggle" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &giggleAudioEffect);
    AudioServicesPlaySystemSound(giggleAudioEffect);

    //[[SimpleAudioEngine sharedEngine] playEffect:@"funny-high-giggle.wav"];
}

-(void) fireworksEffect
{
    SystemSoundID fireWorksAudioEffect;
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"Fireworks_lower_quality" ofType:@"aif"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &fireWorksAudioEffect);
    AudioServicesPlaySystemSound(fireWorksAudioEffect);
}

-(void) detectBombImpact
{
    id actionHide = [CCHide action];
    CGRect bombBox = [bomb boundingBox];
    CGRect personBox = [man2 boundingBox];
    if(CGRectIntersectsRect(bombBox, personBox))
    {
        id startBombParticleExplosion = [CCCallFuncN actionWithTarget:self selector:@selector(bombParticleExplosion)];
        id bombSeq = [CCSequence actions:actionHide, startBombParticleExplosion,nil];
        [bomb runAction:bombSeq];
    }

}

-(void) bombParticleExplosion
{
    bombExplosion = [[CCParticleExplosion alloc] initWithTotalParticles:3];
    //bombExplosion = [[CCParticleExplosion alloc] init];

    //bombExplosion.autoRemoveOnFinish = YES;
    bombExplosion.texture = [[CCTextureCache sharedTextureCache] addImage: @"newnhamm_MultiColored_Sparkle_smaller.png"];
    bombExplosion.speed=100;
    bombExplosion.duration = 1.3;
    bombExplosion.life = 0.3;
    bombExplosion.position = ccp(835,85);
    
    ccColor4F startColor, startColorVar, endColor, endColorVar;
    startColor.r = 1.0f;
    startColor.g = 1.0f;
    startColor.b = 1.0f;
    startColor.a = 1.0f;
    
    startColorVar.r = 0.0f;
    startColorVar.g = 0.0f;
    startColorVar.b = 0.0f;
    startColorVar.a = 0.0f;
    
    endColor.r = 1.0f;
    endColor.g = 1.0f;
    endColor.b = 1.0f;
    endColor.a = 1.0f;
    
    endColorVar.r = 0.0f;
    endColorVar.g = 0.0f;
    endColorVar.b = 0.0f;
    endColorVar.a = 0.0f;
    
    bombExplosion.startColor = startColor;
    bombExplosion.startColorVar = startColorVar;
    bombExplosion.endColor = endColor;
    bombExplosion.endColorVar = endColorVar;

    [self addChild:bombExplosion];
}
-(void) starsExplosionEffect
{
    invisible_arrow = [CCSprite spriteWithFile:@"arrow.png"];
    invisible_arrow.position = ccp(0,100);
    invisible_arrow.visible = NO;
    [self addChild: invisible_arrow];
    id goForwardAction = [CCMoveTo actionWithDuration:2 position:ccp(960,200)];
    //id delay = [CCDelayTime actionWithDuration:1.5];
    easeForward = [CCEaseIn actionWithAction:goForwardAction rate:2];
    [invisible_arrow runAction:[CCSequence actions:easeForward,nil]];
    followArrow = [CCFollow actionWithTarget: invisible_arrow worldBoundary: CGRectMake(0,0,960,320)];
    [self runAction: followArrow];
    
    //This loads an image of the same name (but ending in png), and goes through the plist to add definitions of each
    //frame to the cache.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Explosion.plist"];
    
    //Create a sprite sheet with the explosion images
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"Explosion.png"];
    [self addChild:spriteSheet];
    
    //Load up the frames of the animation
    NSMutableArray *explosionAnimFrames = [NSMutableArray array];
    for(int i=1; i<=125; ++i)
    {
        [explosionAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Explosion_%03i.png", i]]];
    }
    //CCAnimation* explosionAnim = [CCAnimation animationWithFrames:explosionAnimFrames delay:0.0166667f];
    CCAnimation *explosionAnim = [CCAnimation animationWithSpriteFrames:explosionAnimFrames delay:0.0166667f];
    
    //Create a sprite for the explosion
    starsExplosion = [CCSprite spriteWithSpriteFrameName:@"Explosion_001.png"];
    starsExplosion.position = ccp(830,80);
    starsExplosion.scale = 2.3;
    //CCAction* starAction = [CCAnimate actionWithAnimation:explosionAnim restoreOriginalFrame:NO];
    CCAction *starAction = [CCAnimate actionWithAnimation:explosionAnim];
    [self addChild:starsExplosion z:4];
    starsExplosion.visible = NO;
    
    //Laughing man at beginning of animation
    CCSprite *laughingMan = [CCSprite spriteWithFile:@"Laughing_man_smaller.png"];
    laughingMan.position = ccp(205,80);
    laughingMan.scale = 0.8;
    [self addChild:laughingMan z:2];
    //Laughing man fade
    CCFadeOut *laughingManFade = [CCFadeOut actionWithDuration:2.2f];
    [laughingMan runAction:laughingManFade];
    
    //Laughing man sound effect
    [[SimpleAudioEngine sharedEngine] playEffect:@"comedy_male_cartoon_character_laughing.mp3"];
    
    //Create the balloon
    CCSprite *balloon = [CCSprite spriteWithFile:@"balloon_smaller.png"];
    balloon.position = ccp(835,120);
    balloon.visible = NO;
    [self addChild:balloon z:3];
    
    CCSequence* balloonInflating = [CCSequence actions:[CCDelayTime actionWithDuration:2], [CCShow action], [CCCallFuncN actionWithTarget:self selector:@selector(balloonSoundEffect)], nil];
    [balloon runAction:balloonInflating];
    
    //Make the balloon grow and then disappear
    CCScaleTo *growBalloon = [CCScaleTo actionWithDuration:2 scale:2];
    CCHide *hideBalloon = [CCHide action];
    CCSequence *balloonGrowHideSeq = [CCSequence actions: [CCDelayTime actionWithDuration:2],growBalloon, hideBalloon, nil];
    [balloon runAction:balloonGrowHideSeq];
    
    //Show angry cartoon man
    CCSprite *angryDude = [CCSprite spriteWithFile:@"Anonymous_blueman_304.png"];
    angryDude.position = ccp(720,130);
    angryDude.scale = 0.3;
    angryDude.visible = NO;
    [self addChild:angryDude];
    CCSequence *angryDudeAppearAndDisappear = [CCSequence actions: [CCDelayTime actionWithDuration:4.9],[CCShow action], [CCFadeOut actionWithDuration:3], nil];
    [angryDude runAction:angryDudeAppearAndDisappear];
    
    CCShow *showExplosion = [CCShow action];
    id explosionSeq = [CCSequence actions: [CCDelayTime actionWithDuration:4], [CCCallFuncN actionWithTarget:self selector:@selector(cleanFollowInvisibleArrow)], showExplosion, [CCCallFuncN actionWithTarget:self selector:@selector(glassSoundEffect)], starAction, [CCCallFuncN actionWithTarget:self selector:@selector(moveback)], nil];
    [starsExplosion runAction:explosionSeq];
    id fadeExplosionSeq = [CCSequence actions: [CCDelayTime actionWithDuration:5],[CCFadeOut actionWithDuration:1.3], [CCHide action], nil];
    [starsExplosion runAction:fadeExplosionSeq];
}

-(void) balloonSoundEffect
{
   [[SimpleAudioEngine sharedEngine] playEffect:@"Balloon_Inflating.wav"]; 
}

-(void) glassSoundEffect
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"crash_glass.wav"];
}

-(void) cleanFollowInvisibleArrow
{
    [self stopAction:followArrow];
    followArrow = nil;
    [self removeChild:invisible_arrow];
    invisible_arrow = nil;
}


//Create the bullets, add them to the list of bullets so they can be referred to later
- (void)createBullets
{
    //GameParameters *data = [GameParameters sharedData];
    arrowdelay = 0;
    //invisible_arrow.position = ccp(960,100);
    arrow = [CCSprite spriteWithFile:@"arrow.png"];
    id action = [CCMoveTo actionWithDuration:2 position:ccp(960,200)];
    id ease = [CCEaseIn actionWithAction:action rate:2];
    arrow.position = ccp(150,80);
    [self addChild:arrow z:1];
    [arrow runAction: ease];
    [self runAction:[CCFollow actionWithTarget:arrow worldBoundary: CGRectMake(0, 0, 960, 320)]];
    [[SimpleAudioEngine sharedEngine] playEffect:@"arrowDamage.wav"];
    coconutcount = 0;
    coconut2.visible = YES;
    coconut2.position = ccp(875,170);
    /*CCAction *wait;
    if(questionsToGo>1)
    {
        wait = [CCDelayTime actionWithDuration:2.8f];
        CCSequence *seq = [CCSequence actions: (CCFiniteTimeAction *)wait, [CCCallFuncN actionWithTarget:self selector:@selector(continueAnalysis)], nil];
        [self runAction:seq];
    }
    else if(questionsToGo==0)
    {
        wait = [CCDelayTime actionWithDuration:3.0f];
        CCSequence *endGameSequence = [CCSequence actions: (CCFiniteTimeAction *)wait, [CCCallFuncN actionWithTarget:self selector:@selector(continueAnalysis)], nil];
        [self runAction:endGameSequence];
        
    }
     */

}

//See if arrow hits coconut and play sound as coconut falls
-(void) detectCollisions
{
    id actionHide = [CCHide action];
    CGRect arrowBox = [arrow boundingBox];
    CGRect coconutBox = [coconut2 boundingBox];
    if(CGRectIntersectsRect(arrowBox,coconutBox))
    {
        coconutcount++;
        if(coconutcount == 1)
        {
            coconut2.visible=YES;
            [[SimpleAudioEngine sharedEngine] playEffect:@"incoming-artillery.wav"];
            id coconut_move = [CCMoveTo actionWithDuration:2.7 position:ccp(830,70)];
            id accelerate = [CCEaseIn actionWithAction:coconut_move rate:2];
            id startparticles = [CCCallFuncN actionWithTarget:self selector:@selector(beginParticle:)];
            coconutseq = [CCSequence actions:accelerate,actionHide,startparticles,nil];
            [coconut2 runAction: coconutseq];
            if([coconut2 numberOfRunningActions] == 0)
            {
                [self particleExplosionEffect];
            }
            //CCAction *wait;
            /*if(self.progressTimer.percentage>25)
            {
                wait = [CCDelayTime actionWithDuration:2.8f];
                CCSequence *seq = [CCSequence actions: (CCFiniteTimeAction *)wait, [CCCallFuncN actionWithTarget:self selector:@selector(dropLife)], nil];
                [self runAction:seq];
            }
            else if(self.progressTimer.percentage==25)
            {
                wait = [CCDelayTime actionWithDuration:3.0f];
                CCSequence *endGameSequence = [CCSequence actions: (CCFiniteTimeAction *)wait, [CCCallFuncN actionWithTarget:self selector:@selector(dropLife)], nil];
                [self runAction:endGameSequence];
                
            }
             
            if(questionsToGo>1)
            {
                wait = [CCDelayTime actionWithDuration:2.8f];
                CCSequence *seq = [CCSequence actions: (CCFiniteTimeAction *)wait, [CCCallFuncN actionWithTarget:self selector:@selector(continueAnalysis)], nil];
                [self runAction:seq];
            }
            else if(questionsToGo==0)
            {
                wait = [CCDelayTime actionWithDuration:3.0f];
                CCSequence *endGameSequence = [CCSequence actions: (CCFiniteTimeAction *)wait, [CCCallFuncN actionWithTarget:self selector:@selector(continueAnalysis)], nil];
                [self runAction:endGameSequence];
             
            }
             */

        }
    }
}
-(void) continueAnalysis
{
    GameParameters *data = [GameParameters sharedData];
    if([data.weapon isEqualToString:@"Coconut"])
    {
        if(questionsToGo>0 && resultToCompare!=result)
        {
            CCAction *wait = [CCDelayTime actionWithDuration:2.0f];
            id callAnotherQuestion = [CCCallFuncN actionWithTarget:self selector:@selector(generateQuestion)];
            CCSequence *callAnotherQuestionSequence = [CCSequence actions:(CCFiniteTimeAction *) wait, callAnotherQuestion, nil];
            [self runAction:callAnotherQuestionSequence];
        }
        if(questionsToGo>0 && resultToCompare==result)
        {
            CCAction *wait = [CCDelayTime actionWithDuration:8.7f];
            id callAnotherQuestion = [CCCallFuncN actionWithTarget:self selector:@selector(generateQuestion)];
            CCSequence *callAnotherQuestionSequence = [CCSequence actions:(CCFiniteTimeAction *) wait, callAnotherQuestion, nil];
            [self runAction:callAnotherQuestionSequence];
            
        }
        if(questionsToGo == 0 && resultToCompare!=result)
        {
            id endGameDelay = [CCDelayTime actionWithDuration:1.0f];
            id endGame = [CCCallFuncN actionWithTarget:self selector:@selector(switchtoGameOverScene)];
            id endGameSeq = [CCSequence actions: endGameDelay, endGame, nil];
            [self runAction:endGameSeq];
        }
        if(questionsToGo==0 && resultToCompare==result)
        {
            CCAction * wait = [CCDelayTime actionWithDuration:8.7f];
            id endGame = [CCCallFuncN actionWithTarget:self selector:@selector(switchtoGameOverScene)];
            CCSequence *endGameSeq = [CCSequence actions: (CCFiniteTimeAction *)wait, endGame, nil];
            [self runAction:endGameSeq];
        }
    }
    else if([data.weapon isEqualToString:@"Bomb"])
    {
        if(questionsToGo>0 && resultToCompare!=result)
        {
            CCAction *wait = [CCDelayTime actionWithDuration:2.0f];
            id callAnotherQuestion = [CCCallFuncN actionWithTarget:self selector:@selector(generateQuestion)];
            CCSequence *callAnotherQuestionSequence = [CCSequence actions:(CCFiniteTimeAction *) wait, callAnotherQuestion, nil];
            [self runAction:callAnotherQuestionSequence];
        }
        if(questionsToGo>0 && resultToCompare==result)
        {
            CCAction *wait = [CCDelayTime actionWithDuration:8.5f];
            id callAnotherQuestion = [CCCallFuncN actionWithTarget:self selector:@selector(generateQuestion)];
            CCSequence *callAnotherQuestionSequence = [CCSequence actions:(CCFiniteTimeAction *) wait, callAnotherQuestion, nil];
            [self runAction:callAnotherQuestionSequence];
            
        }
        if(questionsToGo == 0 && resultToCompare!=result)
        {
            id endGameDelay = [CCDelayTime actionWithDuration:1.0f];
            id endGame = [CCCallFuncN actionWithTarget:self selector:@selector(switchtoGameOverScene)];
            id endGameSeq = [CCSequence actions: endGameDelay, endGame, nil];
            [self runAction:endGameSeq];
        }
        if(questionsToGo==0 && resultToCompare==result)
        {
            CCAction * wait = [CCDelayTime actionWithDuration:8.5f];
            id endGame = [CCCallFuncN actionWithTarget:self selector:@selector(switchtoGameOverScene)];
            CCSequence *endGameSeq = [CCSequence actions: (CCFiniteTimeAction *)wait, endGame, nil];
            [self runAction:endGameSeq];
        }
    }
    else if([data.weapon isEqualToString:@"Stars"])
    {
        if(questionsToGo>0 && resultToCompare!=result)
        {
            CCAction *wait = [CCDelayTime actionWithDuration:2.0f];
            id callAnotherQuestion = [CCCallFuncN actionWithTarget:self selector:@selector(generateQuestion)];
            CCSequence *callAnotherQuestionSequence = [CCSequence actions:(CCFiniteTimeAction *) wait, callAnotherQuestion, nil];
            [self runAction:callAnotherQuestionSequence];
        }
        if(questionsToGo>0 && resultToCompare==result)
        {
            CCAction *wait = [CCDelayTime actionWithDuration:10.0f];
            id callAnotherQuestion = [CCCallFuncN actionWithTarget:self selector:@selector(generateQuestion)];
            CCSequence *callAnotherQuestionSequence = [CCSequence actions:(CCFiniteTimeAction *) wait, callAnotherQuestion, nil];
            [self runAction:callAnotherQuestionSequence];
            
        }
        if(questionsToGo == 0 && resultToCompare!=result)
        {
            id endGameDelay = [CCDelayTime actionWithDuration:1.0f];
            id endGame = [CCCallFuncN actionWithTarget:self selector:@selector(switchtoGameOverScene)];
            id endGameSeq = [CCSequence actions: endGameDelay, endGame, nil];
            [self runAction:endGameSeq];
        }
        if(questionsToGo==0 && resultToCompare==result)
        {
            CCAction * wait = [CCDelayTime actionWithDuration:10.0f];
            id endGame = [CCCallFuncN actionWithTarget:self selector:@selector(switchtoGameOverScene)];
            CCSequence *endGameSeq = [CCSequence actions: (CCFiniteTimeAction *)wait, endGame, nil];
            [self runAction:endGameSeq];
        }
    }

}
/*-(void) dropLife
{
    if (self.progressTimer.percentage > 25)
    {
        self.progressTimer.percentage -= 25;
    }
    else if(self.progressTimer.percentage==25)
    {
        self.progressTimer.percentage=0;
        CCAction *wait = [CCDelayTime actionWithDuration:1.0f];
        CCSequence *seq = [CCSequence actions: (CCFiniteTimeAction *)wait, [CCCallFuncN actionWithTarget:self selector:@selector(switchtoGameOverScene)], nil];
        [self runAction:seq];
    }
     
    if(questionsToGo==1)
    {
        CCAction *wait = [CCDelayTime actionWithDuration:1.0f];
        CCSequence *seq = [CCSequence actions: (CCFiniteTimeAction *)wait, [CCCallFuncN actionWithTarget:self selector:@selector(switchtoGameOverScene)], nil];
        [self runAction:seq];
    }
}
*/

-(void) switchtoGameOverScene
{
    CCTransitionMoveInR *transition = [CCTransitionMoveInR transitionWithDuration:0.7 scene:(CCScene *) [[GameOver alloc] init]];
    [[CCDirector sharedDirector] replaceScene: transition];
}
-(void) beginParticle: (id) sender {
    [self particleExplosionEffect];
}
-(void) particleExplosionEffect
{
    NSLog(@"Particle");
    CCParticleExplosion *explosion = [[CCParticleExplosion alloc] init];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage: @"raindrop-water-drop.png"];
    explosion.speed=70;
    explosion.duration = 1;
    explosion.life = .5;
    explosion.position = ccp(835,85);
    
    [self addChild:explosion];
}
-(void) moveback
{
    invisible_arrow = [CCSprite spriteWithFile:@"arrow.png"];
    invisible_arrow.position = ccp(960,100);
    invisible_arrow.visible = NO;
    [self addChild: invisible_arrow];
    id goBackAction = [CCMoveTo actionWithDuration:2 position:ccp(150,80)];
    id delay = [CCDelayTime actionWithDuration:1.5];
    easeBack = [CCEaseIn actionWithAction:goBackAction rate:2];
    [invisible_arrow runAction:[CCSequence actions:delay,easeBack,nil]];
    followArrow = [CCFollow actionWithTarget: invisible_arrow worldBoundary: CGRectMake(0,0,960,320)];
    [self runAction: followArrow];
}


-(void) dealloc
{
	delete world;
    
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

-(void) update:(ccTime)delta
{
    GameParameters *data = [GameParameters sharedData];
    if(invisible_arrow.position.x == 150)
    {
        //NSLog(@"%f",self.position.x);
        //NSLog(@"%f",invisible_arrow.position.x);
        //followArrow = [CCFollow actionWithTarget: self worldBoundary: CGRectMake(0,0,960,320)];
        //[self runAction:followArrow];
        //NSLog(@"invisible_arrow.position.x if condition activated:");
        invisible_arrow.position = ccp(0,0);
        self.position = ccp(0,0);
        [self stopAllActions];
        [self removeChild: invisible_arrow cleanup: YES];
        [self removeChild: followArrow cleanup: YES];
        NSLog(@"followBomb is done? : %d", [followBomb isDone]);
        if([data.weapon isEqualToString:@"Bomb"])
        {
            NSLog(@"followBomb removed");
            bombDelay = 0;
            [self removeChild:bombExplosion];
        }
    }
    [self detectCollisions];
    [self detectBombImpact];
   // NSLog(@"%d",arrowdelay);
    if(arrow.position.x == 960)
    {
        //NSLog(@"arrow delay: %d", arrowdelay);
        arrowdelay++;
        if(arrowdelay == 120)
        {
            //arrow.visible = NO;
            [self moveback];
        }

    }
    if(bomb.position.x == 830)
    {
        //NSLog(@"bomb is located at: (%f,%f)", bomb.position.x, bomb.position.y);
        /*[self removeChild:followBomb];
        id delayBeforeMovingBack = [CCDelayTime actionWithDuration:1.5];
        id moveBackSeqForBomb = [CCSequence actions: delayBeforeMovingBack, [CCCallFuncN actionWithTarget:self selector:@selector(moveback)], nil];
        [self runAction:moveBackSeqForBomb];
         */
        //NSLog(@"bombDelay: %d", bombDelay);
        bombDelay++;
        if(bombDelay==120)
        {
            [self removeChild:followBomb cleanup:YES];
            [self removeChild:bomb cleanup:YES];
            bomb=nil;
            [self moveback];
            //[self removeChild:followBomb];
            //[self removeChild:bomb];
        }
    }
    //Check for inputs and create a bullet if there is a tap
    KKInput* input = [KKInput sharedInput];
    input.gestureSwipeEnabled = YES;
    //input.gestureTapEnabled = YES;
    if(input.touchesAvailable)
    {
        if ([KKInput sharedInput].gesturesAvailable)
        {
            if (input.gestureSwipeRecognizedThisFrame)
            {
                NSLog(@"Swipe Detected");
                KKSwipeGestureDirection dir = input.gestureSwipeDirection;
                switch (dir)
                {
                    case KKSwipeGestureDirectionRight:
                        swipeRight = [CCMoveTo actionWithDuration:.5 position:ccp(self.position.x  - 60, self.position.y)];
                        easeRight = [CCEaseIn actionWithAction:swipeRight rate:1];
                        NSLog(@"%f",self.position.x);
                        if(self.position.x != -480)
                        {
                            [self runAction:easeRight];
                        }
                        break;
                    case KKSwipeGestureDirectionLeft:
                        swipeLeft = [CCMoveTo actionWithDuration:.5 position:ccp(self.position.x + 60, self.position.y)];
                        easeLeft = [CCEaseIn actionWithAction:swipeLeft rate:1];
                        if(self.position.x != 0)
                        {
                            [self runAction: easeLeft];
                        }
                        NSLog(@"%f",self.position.x);
                        break;
                    case KKSwipeGestureDirectionUp:
                        // direction-specific code here
                        break;
                    case KKSwipeGestureDirectionDown:
                        // direction-specific code here
                        break;
                }
                
            }
        }

        
    }
    
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}


@end
