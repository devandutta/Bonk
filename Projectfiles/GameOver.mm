//
//  GameOver.m
//  Bonk_v2
//
//  Created by Devan Dutta on 6/28/13.
//
//

#import "GameOver.h"
#import "StartMenuLayer.h"
#import "GameParameters.h"
@implementation GameOver
+(id) scene
{
    CCScene *scene = [CCScene node];
    StartMenuLayer *layer = [StartMenuLayer node];
    [scene addChild:layer];
    return scene;
}
-(id) init
{
    if((self=[super init]))
    {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        GameParameters *data = [GameParameters sharedData];
        CCLabelTTF* GameOver = [CCLabelTTF labelWithString:@"Round Summary" fontName:@"Marker Felt" fontSize:32];
        [GameOver setColor:ccc3(222, 222, 255)];
		GameOver.position = ccp(240,20);
		[self addChild:GameOver];
        CCMenuItem *restartGame = [CCMenuItemImage itemWithNormalImage:@"restart.png" selectedImage:@"restart.png" target:self selector:@selector(reactToRestart:)];
        restartGame.scale=0.3;
        restartGame.position = ccp(430,20);
        CCMenu *restartGameMenu = [CCMenu menuWithItems:restartGame, nil];
        restartGameMenu.position = CGPointZero;
        [self addChild: restartGameMenu z:2];
        
        results = [CCMenu menuWithItems: nil];
        results.anchorPoint = ccp(0,0);
        results.position = ccp(240,190);
        
        results2 = [CCMenu menuWithItems: nil];
        results2.anchorPoint = ccp(0,0);
        results2.position = ccp(240,190);
        
        results3 = [CCMenu menuWithItems: nil];
        results3.anchorPoint = ccp(0,0);
        results3.position = ccp(240,190);
        
        if([data.responseData count]<=10)
        {
            layer1 = [[CCLayer alloc] init];
            CCLabelTTF* questionNumber = [CCLabelTTF labelWithString:@"Question #" fontName:@"Marker Felt" fontSize:24];
            questionNumber.color = ccc3(255,102,0);
            CCMenuItemLabel* questionNumberMenuLabel = [CCMenuItemLabel itemWithLabel:questionNumber];
            [results addChild:questionNumberMenuLabel];
            CCLabelTTF* timeTitleLabel = [CCLabelTTF labelWithString:@"Time:" fontName:@"Marker Felt" fontSize:24];
            timeTitleLabel.color = ccc3(255,153,255);
            CCMenuItemLabel* timeTitleLabelMenuItem = [CCMenuItemLabel itemWithLabel:timeTitleLabel];
            [results addChild:timeTitleLabelMenuItem];
            CCLabelTTF* correctTitleLabel = [CCLabelTTF labelWithString:@"Correct?" fontName:@"Marker Felt" fontSize:24];
            correctTitleLabel.color = ccc3(0,204,255);
            CCMenuItemLabel* correctTitleLabelMenuItem = [CCMenuItemLabel itemWithLabel:correctTitleLabel];
            [results addChild:correctTitleLabelMenuItem];
            for(int x=0; x<(int)[data.responseData count]; x++)
            {
                NSString *numberText = [NSString stringWithFormat:@"%d", x+1];
                CCLabelTTF *numberLabel = [CCLabelTTF labelWithString:numberText fontName:@"Marker Felt" fontSize:16];
                numberLabel.color = ccc3(255, 102, 0);
                CCMenuItemLabel* numberMenuLabel = [CCMenuItemLabel itemWithLabel:numberLabel];
                [results addChild:numberMenuLabel];
                QuestionInfo *question = [data.responseData objectAtIndex:x];
                NSString *time = [NSString stringWithFormat:@"%d sec", question.timeToResponse];
                CCLabelTTF *timeLabel = [CCLabelTTF labelWithString:time fontName:@"Marker Felt" fontSize:16];
                timeLabel.color = ccc3(255,153,255);
                CCMenuItemLabel* timeMenuLabel = [CCMenuItemLabel itemWithLabel:timeLabel];
                [results addChild:timeMenuLabel];
                NSString* correct;
                if(question.correct == YES)
                    correct = [NSString stringWithFormat:@"YES"];
                else
                    correct = [NSString stringWithFormat:@"NO"];
                CCLabelTTF *correctLabel = [CCLabelTTF labelWithString:correct fontName:@"Marker Felt" fontSize:16];
                correctLabel.color = ccc3(0,204,255);
                CCMenuItemLabel* correctMenuLabel = [CCMenuItemLabel itemWithLabel:correctLabel];
                [results addChild:correctMenuLabel];
                NSLog(@"x value: %d", x);
            }
            if([data.responseData count]==5)
            {
                [results alignItemsInColumns:[NSNumber numberWithInt:3],[NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], nil];
                NSLog(@"Number of children: %d minus the three for column headers", [results.children count]-3);
            }
            else if([data.responseData count]==10)
            {
                [results alignItemsInColumns:[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3], nil];
            }
            [layer1 addChild:results];
            scrollResults = [[CCScrollLayer alloc] initWithLayers:[NSArray arrayWithObjects:layer1, nil] widthOffset:screenSize.width*2];
        }
        else if([data.responseData count]==15 || [data.responseData count]==20)
        {
            int positionCounter;
            layer1 = [[CCLayer alloc] init];
            layer1.contentSize = CGSizeMake(screenSize.width, screenSize.height);
            CCLabelTTF* questionNumber = [CCLabelTTF labelWithString:@"Question #" fontName:@"Marker Felt" fontSize:24];
            questionNumber.color = ccc3(255,102,0);
            CCMenuItemLabel* questionNumberMenuLabel = [CCMenuItemLabel itemWithLabel:questionNumber];
            [results addChild:questionNumberMenuLabel];
            CCLabelTTF* timeTitleLabel = [CCLabelTTF labelWithString:@"Time:" fontName:@"Marker Felt" fontSize:24];
            timeTitleLabel.color = ccc3(255,153,255);
            CCMenuItemLabel* timeTitleLabelMenuItem = [CCMenuItemLabel itemWithLabel:timeTitleLabel];
            [results addChild:timeTitleLabelMenuItem];
            CCLabelTTF* correctTitleLabel = [CCLabelTTF labelWithString:@"Correct?" fontName:@"Marker Felt" fontSize:24];
            correctTitleLabel.color = ccc3(0,204,255);
            CCMenuItemLabel* correctTitleLabelMenuItem = [CCMenuItemLabel itemWithLabel:correctTitleLabel];
            [results addChild:correctTitleLabelMenuItem];
            for(positionCounter=0; positionCounter<10; positionCounter++)
            {
                NSString *numberText = [NSString stringWithFormat:@"%d", positionCounter+1];
                CCLabelTTF *numberLabel = [CCLabelTTF labelWithString:numberText fontName:@"Marker Felt" fontSize:16];
                numberLabel.color = ccc3(255, 102, 0);
                CCMenuItemLabel* numberMenuLabel = [CCMenuItemLabel itemWithLabel:numberLabel];
                [results addChild:numberMenuLabel];
                QuestionInfo *question = [data.responseData objectAtIndex:positionCounter];
                NSString *time = [NSString stringWithFormat:@"%d sec", question.timeToResponse];
                CCLabelTTF *timeLabel = [CCLabelTTF labelWithString:time fontName:@"Marker Felt" fontSize:16];
                timeLabel.color = ccc3(255,153,255);
                CCMenuItemLabel* timeMenuLabel = [CCMenuItemLabel itemWithLabel:timeLabel];
                [results addChild:timeMenuLabel];
                NSString* correct;
                if(question.correct == YES)
                    correct = [NSString stringWithFormat:@"YES"];
                else
                    correct = [NSString stringWithFormat:@"NO"];
                CCLabelTTF *correctLabel = [CCLabelTTF labelWithString:correct fontName:@"Marker Felt" fontSize:16];
                correctLabel.color = ccc3(0,204,255);
                CCMenuItemLabel* correctMenuLabel = [CCMenuItemLabel itemWithLabel:correctLabel];
                [results addChild:correctMenuLabel];
            }
            if(([results.children count]-3)==5)
            {
                [results alignItemsInColumns:[NSNumber numberWithInt:3],[NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], nil];
                NSLog(@"Number of children: %d minus the three for column headers", [results.children count]-3);
            }
            else if(([results.children count]-3)==10)
            {
                [results alignItemsInColumns:[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3], nil];
            }
            [layer1 addChild:results];
            
            layer2 = [[CCLayer alloc] init];
            layer2.contentSize = CGSizeMake(screenSize.width, screenSize.height);
            CCLabelTTF* questionNumberLayer2 = [CCLabelTTF labelWithString:@"Question #" fontName:@"Marker Felt" fontSize:24];
            questionNumberLayer2.color = ccc3(255,102,0);
            CCMenuItemLabel* questionNumberMenuLabelLayer2 = [CCMenuItemLabel itemWithLabel:questionNumberLayer2];
            [results2 addChild:questionNumberMenuLabelLayer2];
            CCLabelTTF* timeTitleLabelLayer2 = [CCLabelTTF labelWithString:@"Time:" fontName:@"Marker Felt" fontSize:24];
            timeTitleLabelLayer2.color = ccc3(255,153,255);
            CCMenuItemLabel* timeTitleLabelMenuItemLayer2 = [CCMenuItemLabel itemWithLabel:timeTitleLabelLayer2];
            [results2 addChild:timeTitleLabelMenuItemLayer2];
            CCLabelTTF* correctTitleLabelLayer2 = [CCLabelTTF labelWithString:@"Correct?" fontName:@"Marker Felt" fontSize:24];
            correctTitleLabelLayer2.color = ccc3(0,204,255);
            CCMenuItemLabel* correctTitleLabelMenuItemLayer2 = [CCMenuItemLabel itemWithLabel:correctTitleLabelLayer2];
            [results2 addChild:correctTitleLabelMenuItemLayer2];
            int endingPosition;
            if([data.responseData count]==15)
                endingPosition = 14;
            else if([data.responseData count]==20)
                endingPosition = 19;
            for(positionCounter=6; positionCounter<endingPosition; positionCounter++)
            {
                NSString *numberText = [NSString stringWithFormat:@"%d", positionCounter+1];
                CCLabelTTF *numberLabel = [CCLabelTTF labelWithString:numberText fontName:@"Marker Felt" fontSize:16];
                numberLabel.color = ccc3(255, 102, 0);
                CCMenuItemLabel* numberMenuLabel = [CCMenuItemLabel itemWithLabel:numberLabel];
                [results2 addChild:numberMenuLabel];
                QuestionInfo *question = [data.responseData objectAtIndex:positionCounter];
                NSString *time = [NSString stringWithFormat:@"%d sec", question.timeToResponse];
                CCLabelTTF *timeLabel = [CCLabelTTF labelWithString:time fontName:@"Marker Felt" fontSize:16];
                timeLabel.color = ccc3(255,153,255);
                CCMenuItemLabel* timeMenuLabel = [CCMenuItemLabel itemWithLabel:timeLabel];
                [results2 addChild:timeMenuLabel];
                NSString* correct;
                if(question.correct == YES)
                    correct = [NSString stringWithFormat:@"YES"];
                else
                    correct = [NSString stringWithFormat:@"NO"];
                CCLabelTTF *correctLabel = [CCLabelTTF labelWithString:correct fontName:@"Marker Felt" fontSize:16];
                correctLabel.color = ccc3(0,204,255);
                CCMenuItemLabel* correctMenuLabel = [CCMenuItemLabel itemWithLabel:correctLabel];
                [results2 addChild:correctMenuLabel];
            }
            if(([results2.children count]-3)==5)
            {
                [results2 alignItemsInColumns:[NSNumber numberWithInt:3],[NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], [NSNumber numberWithInt:3], nil];
                NSLog(@"Number of children: %d minus the three for column headers", [results2.children count]-3);
            }
            else if(([results2.children count]-3)==10)
            {
                [results2 alignItemsInColumns:[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3], nil];
            }
            [layer2 addChild:results2];
            scrollResults = [[CCScrollLayer alloc] initWithLayers:[NSArray arrayWithObjects:layer1,layer2, nil] widthOffset:screenSize.width*2];

        }
        [self addChild:scrollResults];

    }
    return self;
}
-(void) reactToRestart: (CCMenuItem *) menuItem;
{
    GameParameters *data = [GameParameters sharedData];
    CCTransitionSlideInL *transition = [CCTransitionSlideInL transitionWithDuration:0.7 scene:(CCScene *) [[StartMenuLayer alloc] init]];
    [[CCDirector sharedDirector] replaceScene: transition];
    [data.responseData removeAllObjects];

}
-(void) dealloc
{
#ifndef KK_ARC_ENABLED
    [super dealloc];
#endif
}

@end
