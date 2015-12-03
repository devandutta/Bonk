//
//  GameParameters.m
//  Bonk_v2
//
//  Created by Devan Dutta on 7/24/13.
//
//

#import "GameParameters.h"

@implementation GameParameters
@synthesize numQuestions;
@synthesize maxNumber;
@synthesize negativeAnswer;
@synthesize responseData;
@synthesize weapon;

//static variable - this stores our singleton instance
static GameParameters *sharedData = nil;

+(GameParameters*) sharedData
{
    //If our singleton instance has not been created (first time it is being accessed)
    if(sharedData == nil)
    {
        //create the singleton instance
        sharedData = [[GameParameters alloc] init];
        
        //Must instantiate each property
        
        //Default number of questions
        sharedData.numQuestions = 5;
        //Default max number
        sharedData.maxNumber = 25;
        //Default negative answer is YES
        sharedData.negativeAnswer = NO;
        //Instantiate the responseData NSMutableArray
        sharedData.responseData = [[NSMutableArray alloc] init];
        //Default weapon is coconut
        sharedData.weapon = [NSString stringWithFormat:@"Coconut"];
    }
    
    //If the singleton instance has already been created, return it
    return sharedData;
}
@end
