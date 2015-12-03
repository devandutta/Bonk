//
//  QuestionInfo.m
//  Bonk_v2
//
//  Created by Devan Dutta on 7/24/13.
//
//

#import "QuestionInfo.h"

@implementation QuestionInfo
@synthesize correct;
@synthesize timeToResponse;

-(id) initWithCorrect:(BOOL)WasItCorrect
{
    if((self = [super init]))
    {
        self.correct = WasItCorrect;
    }
    return self;
}

-(id) initWithCorrect:(BOOL)WasItCorrect andTime:(int)timeToRespond
{
    if((self = [super init]))
    {
        self.correct = WasItCorrect;
        self.timeToResponse = timeToRespond;
    }
    return self;
}

@end
