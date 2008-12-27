//
//  FlyingImagesView.h
//  CASandbox
//
//  Created by Ivan Wick on 12/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface FlyingImagesView : NSView
{
    CALayer* containerLayerForImages;
    NSGradient* backgroundGradient;
    CGImageRef imagedata;
    
    float T_MOVE;// = 0.1;
    float T_ROTATE;// = 0.025;
    float FULL_ANIM_TIME;// = 4; //seconds
}

-(float)moveTime;
-(float)rotateTime;
-(float)fullAnimTime;
-(void)setMoveTime:(float)f;
-(void)setRotateTime:(float)f;
-(void)setFullAnimTime:(float)f;

-(void)displayImage:(NSImage *)img;

@end
