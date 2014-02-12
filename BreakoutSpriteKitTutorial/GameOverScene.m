//
//  GameOverScene.m
//  BreakoutSpriteKitTutorial
//
//  Created by Craig Hagerman on 2/9/14.
//  Copyright (c) 2014 ece1778. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size playerWon:(BOOL)isWon {
    self = [super initWithSize:size];
    if (self) {
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:background];
        
        // 1
        SKLabelNode* gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        gameOverLabel.fontSize = 42;
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        if (isWon) {
            gameOverLabel.text = @"Game Won";
        } else {
            gameOverLabel.text = @"Game Over";
        }
        [self addChild:gameOverLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    MyScene* breakoutGameScene = [[MyScene alloc] initWithSize:self.size];
    // 2
    [self.view presentScene:breakoutGameScene];
}

@end