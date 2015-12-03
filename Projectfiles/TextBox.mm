//
//  TextBox.m
//  Bonk_v2
//
//  Created by Devan Dutta on 8/5/13.
//
//

#import "TextBox.h"

@implementation TextBox
@synthesize roundedBlueRect;
@synthesize text;

-(id) init
{
    if ((self = [super init]))
    {
        self.roundedBlueRect = [CCSprite spriteWithFile:@"any_color_round_square_button_smaller.png"];
        self.text = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
        self.text.color = ccc3(255,0,51);
    }
    return self;
}
@end
