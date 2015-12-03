//
//  GameParameters.h
//  Bonk_v2
//
//  Created by Devan Dutta on 7/24/13.
//
//

#import <Foundation/Foundation.h>
#import "GameLayer.h"
#import "StartMenuLayer.h"
#import "GameOver.h"
#import "StartMenuLayer.h"
#import "CCControlExtension.h"
#import "TextBox.h"
@interface GameParameters : NSObject
@property (nonatomic) int numQuestions;
@property (nonatomic) int maxNumber;
@property (nonatomic) BOOL negativeAnswer;
@property (nonatomic) NSMutableArray* responseData;
@property (nonatomic) NSString *weapon;
+(GameParameters*) sharedData;
@end
