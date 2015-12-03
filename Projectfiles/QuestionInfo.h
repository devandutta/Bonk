//
//  QuestionInfo.h
//  Bonk_v2
//
//  Created by Devan Dutta on 7/24/13.
//
//

#import <Foundation/Foundation.h>
#import "GameLayer.h"
#import "StartMenuLayer.h"
#import "GameOver.h"
#import "GameParameters.h"
#import "CCControlExtension.h"
#import "TextBox.h"
@interface QuestionInfo : NSObject
@property (nonatomic) BOOL correct;
@property (nonatomic) int timeToResponse;
-(id) initWithCorrect: (BOOL) WasItCorrect;
-(id) initWithCorrect:(BOOL)WasItCorrect andTime: (int)timeToRespond;
@end
