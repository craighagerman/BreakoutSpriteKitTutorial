//
//  GameOverScene.h
//  BreakoutSpriteKitTutorial
//
//  Created by Craig Hagerman on 2/9/14.
//  Copyright (c) 2014 ece1778. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameOverScene : SKScene

-(id)initWithSize:(CGSize)size playerWon:(BOOL)isWon;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
