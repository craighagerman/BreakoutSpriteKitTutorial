//
//  MyScene.m
//  BreakoutSpriteKitTutorial
//
//  Created by Craig Hagerman on 2/9/14.
//  Copyright (c) 2014 ece1778. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

static NSString* ballCategoryName = @"ball";
static NSString* paddleCategoryName = @"paddle";
static NSString* blockCategoryName = @"block";
static NSString* blockNodeCategoryName = @"blockNode";

static const uint32_t ballCategory  = 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t bottomCategory = 0x1 << 1; // 00000000000000000000000000000010
static const uint32_t blockCategory = 0x1 << 2;  // 00000000000000000000000000000100
static const uint32_t paddleCategory = 0x1 << 3; // 00000000000000000000000000001000

@interface MyScene()

@property (nonatomic) BOOL isFingerOnPaddle;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:background];
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);       // set gravity to zero along both axis
        
        // Create a physics body that borders the screen
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        // Set physicsBody of scene to borderBody ('caged')
        self.physicsBody = borderBody;
        // Set the friction of that physicsBody to 0
        self.physicsBody.friction = 0.0f;
        
        // create a sprite, name it for later reference, set its position relative to the scene, and add it to the scene.
        SKSpriteNode* ball = [SKSpriteNode spriteNodeWithImageNamed: @"ball.png"];
        ball.name = ballCategoryName;
        ball.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/3);
        [self addChild:ball];
        
        // create a volume-based body for the ball.
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
        
        // remove friction
        ball.physicsBody.friction = 0.0f;
        // set the 'bounciness'. 1.0f means perfectly elastic
        ball.physicsBody.restitution = 1.0f;
        // simulates fluid or air friction by reducing the body’s linear velocity
        ball.physicsBody.linearDamping = 0.0f;
        // Don't allow the ball to rotate
        ball.physicsBody.allowsRotation = NO;
        
        [ball.physicsBody applyImpulse:CGVectorMake(100.0f, 100.0f)];
        
        // Create and configure the paddle
        SKSpriteNode* paddle = [[SKSpriteNode alloc] initWithImageNamed: @"paddle.png"];
        paddle.name = paddleCategoryName;
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddle.frame.size.height * 0.6f);
        [self addChild:paddle];
        paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paddle.frame.size];
        paddle.physicsBody.restitution = 0.1f;
        paddle.physicsBody.friction = 0.4f;
        // make physicsBody static
        paddle.physicsBody.dynamic = NO;
        
        // create a physics body that stretches across the bottom of the screen for the ball to interact with
        CGRect bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        SKNode* bottom = [SKNode node];
        bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        [self addChild:bottom];
        
        bottom.physicsBody.categoryBitMask = bottomCategory;
        ball.physicsBody.categoryBitMask = ballCategory;
        paddle.physicsBody.categoryBitMask = paddleCategory;
        ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
        
        self.physicsWorld.contactDelegate = self;
        
        
        // 1 Store some useful variables
        int numberOfBlocks = 3;
        int blockWidth = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"].size.width;
        float padding = 20.0f;
        // 2 Calculate the xOffset
        float xOffset = (self.frame.size.width - (blockWidth * numberOfBlocks + padding * (numberOfBlocks-1))) / 2;
        // 3 Create the blocks and add them to the scene
        for (int i = 1; i <= numberOfBlocks; i++) {
            SKSpriteNode* block = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
            block.position = CGPointMake((i-0.5f)*block.frame.size.width + (i-1)*padding + xOffset, self.frame.size.height * 0.8f);
            block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.frame.size];
            block.physicsBody.allowsRotation = NO;
            block.physicsBody.friction = 0.0f;
            block.name = blockCategoryName;
            block.physicsBody.categoryBitMask = blockCategory;
            ball.physicsBody.collisionBitMask = paddleCategory;
            //block.physicsBody.collisionBitMask = 0;
            
            [self addChild:block];
        }
    }
    return self;
}



-(void)didBeginContact:(SKPhysicsContact*)contact {
    // 1 Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    // 3 react to the contact between ball and bottom
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory) {
        GameOverScene* gameOverScene = [[GameOverScene alloc] initWithSize:self.frame.size playerWon:NO];
        [self.view presentScene:gameOverScene];
    }
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == blockCategory) {
        [secondBody.node removeFromParent];
        if ([self isGameWon]) {
            GameOverScene* gameWonScene = [[GameOverScene alloc] initWithSize:self.frame.size playerWon:YES];
            [self.view presentScene:gameWonScene];
        }
    }
}


-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    /* Called when a touch begins */
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:touchLocation];
    if (body && [body.node.name isEqualToString: paddleCategoryName]) {
        NSLog(@"Began touch on paddle");
        self.isFingerOnPaddle = YES;
    }
}


-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    // 1 Check whether user tapped paddle
    if (self.isFingerOnPaddle) {
        // 2 Get touch location
        UITouch* touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        // 3 Get node for paddle
        SKSpriteNode* paddle = (SKSpriteNode*)[self childNodeWithName: paddleCategoryName];
        // 4 Calculate new position along x for paddle
        int paddleX = paddle.position.x + (touchLocation.x - previousLocation.x);
        // 5 Limit x so that the paddle will not leave the screen to left or right
        paddleX = MAX(paddleX, paddle.size.width/2);
        paddleX = MIN(paddleX, self.size.width - paddle.size.width/2);
        // 6 Update position of paddle
        paddle.position = CGPointMake(paddleX, paddle.position.y);
    }
}


-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    self.isFingerOnPaddle = NO;
}



-(BOOL)isGameWon {
    int numberOfBricks = 0;
    for (SKNode* node in self.children) {
        if ([node.name isEqual: blockCategoryName]) {
            numberOfBricks++;
        }
    }
    return numberOfBricks <= 0;
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    SKNode* ball = [self childNodeWithName: ballCategoryName];
    static int maxSpeed = 1000;
    float speed = sqrt(ball.physicsBody.velocity.dx*ball.physicsBody.velocity.dx + ball.physicsBody.velocity.dy * ball.physicsBody.velocity.dy);
    if (speed > maxSpeed) {
        ball.physicsBody.linearDamping = 0.4f;
    } else {
        ball.physicsBody.linearDamping = 0.0f;
    }
}



@end