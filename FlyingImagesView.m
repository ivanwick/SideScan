//
//  FlyingImagesView.m
//  CASandbox
//
//  Created by Ivan Wick on 12/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSImage-Extras.h"
#import "FlyingImagesView.h"


@interface FlyingImagesView (Private)
- (CATransform3D) get3DTransform;
- (void)generateLayerForNSImage:(NSImage *)nsi;
- (void)makeImageSublayers;
-(void) loadImages;
- (void)setupBackgroundGradient;
-(void)centerImageSublayersAtPoint:(CGPoint)c;
- (CALayer *)generateLayerForCGImageRef:(CGImageRef)cgCompositeImage;
-(void)animateNewLayerAt:(CGPoint)newpos;
-(CAAnimation *)keyframeAnimation;

-(CGPoint)randomPosition;
-(void)displayImage:(NSImage *)img;
-(void)receivedExtractedImageNotification:(NSNotification *)note;
-(void)animateLayer:(CALayer *)cal atCGPoint:(CGPoint)newpos;

@end


// SEE NOTES ABOUT THIS CLASS AT THE END OF THE FILE
@interface LayerDeleterAnimationDelegate : NSObject{
    CALayer *layer;
}
+(id)delegateWithLayer:(CALayer *)l;
-(void)setLayer:(CALayer*)l;
@end



@implementation FlyingImagesView

- (void)awakeFromNib
{
    NSImage * nsi = [[[NSImage alloc] 
        //initWithContentsOfFile:@"/System/Library/CoreServices/Bluetooth Setup Assistant.app/Contents/Resources/AppIcon.icns"]
        initWithContentsOfFile:@"/System/Library/CoreServices/AOS.bundle/Contents/Resources/48x67iDisk.tiff"]
        //initWithContentsOfFile:@"/Applications/Utilities/Remote Install Mac OS X.app/Contents/Resources/Background.png"]
        //initWithContentsOfFile:@"/System/Library/Automator/Ask for Confirmation.action/Contents/Resources/Normal.tiff"]
         //initWithContentsOfFile:@"/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/MigrationSection.bundle/Contents/Resources/EthernetCable.tif"] autorelease];
        autorelease];
    imagedata = [nsi cgImage];

    // setup gradient to draw the background of the view
    [self setupBackgroundGradient];

    // make the view layer-backed and become the delegate for the layer
    [self setWantsLayer: YES];
    CALayer* mainLayer = [self layer];
    [mainLayer setName:@"mainLayer"];
    [mainLayer setDelegate: self];

    // causes the layer content to be drawn in -drawRect:
    [mainLayer setNeedsDisplay];

    CALayer* imagesContainer = [CALayer layer];
    [imagesContainer setName:@"imagesContainer"];
    [imagesContainer setSublayerTransform:[self get3DTransform]];

    imagesContainer.bounds = mainLayer.bounds;
    imagesContainer.position = CGPointMake(mainLayer.bounds.size.width / 2,
                                           mainLayer.bounds.size.height/ 2);
    //imagesContainer.backgroundColor = CGColorCreateGenericGray(0.75, 1.0);

    imagesContainer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    //mainLayer.layoutManager = [CAConstraintLayoutManager layoutManager];

    [mainLayer addSublayer:imagesContainer];
    containerLayerForImages = imagesContainer;

    [self animateNewLayerAt:CGPointMake(400,400)];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(receivedExtractedImageNotification:)
        name:@"PNGScannerExtractedImage"
        object:nil];
    */

}


-(void)receivedExtractedImageNotification:(NSNotification *)note
{
    NSImage *img = [[note userInfo] objectForKey:@"image"];
    //NSLog(@"receivedNotification");
    [self displayImage:img];
}

-(void)displayImage:(NSImage *)img
{
    CGImageRef cgir = [img cgImage];
    CGPoint p = [self randomPosition];
    
    [self animateLayer:[self generateLayerForCGImageRef:cgir] atCGPoint:p];
    CGImageRelease(cgir);
}

-(CGPoint)randomPosition
{
    CGRect  cbounds = [containerLayerForImages bounds];
    
    CGPoint maxpoint = CGPointMake(cbounds.size.width, cbounds.size.height);
    CGPoint retpoint = CGPointMake(
        random() % ((NSInteger)(maxpoint.x - 50)), // why cast?
        random() % ((NSInteger)(maxpoint.y - 50)));
        
    return retpoint;
}

-(void)mouseUp:(NSEvent*)e
{
    CGPoint m = NSPointToCGPoint([e locationInWindow]);
    CGPoint newPos, clfip = [containerLayerForImages position];
    clfip = CGPointMake(clfip.x - containerLayerForImages.bounds.size.width / 2,
                        clfip.y - containerLayerForImages.bounds.size.height/ 2);
    newPos = CGPointMake(m.x - clfip.x, m.y - clfip.y);

    [self animateNewLayerAt:newPos];
}


-(void)animateNewLayerAt:(CGPoint)newpos
{
    CALayer *cal = [self generateLayerForCGImageRef:imagedata];
    [self animateLayer:cal atCGPoint:newpos];
}

-(void)animateLayer:(CALayer *)cal atCGPoint:(CGPoint)newpos
{
    CAAnimation *kfa = [self keyframeAnimation];
    [kfa setDelegate:[LayerDeleterAnimationDelegate delegateWithLayer:cal]];
    
    [cal setOpacity:0.0];
    [cal setPosition: newpos];
    [containerLayerForImages addSublayer:cal];
    [cal addAnimation:kfa forKey:@"flyIn"];
}


- (CALayer *)generateLayerForCGImageRef:(CGImageRef)cgCompositeImage
{
    CALayer* il = [CALayer layer];
    [il setName:@"img"];
    [il setFrame:CGRectMake(100, 100, 100, 100)];
    [il setContents:(id)cgCompositeImage];
    [il setContentsGravity:kCAGravityResizeAspect];
    
    return il;
}

#if 0
-(void)makeImageSublayers
{
    NSImage * nsi = [[[NSImage alloc] initWithContentsOfFile:@"/Users/ivan/choptest/full/cheapcontrol.png"] autorelease];
    CGImageRef cgir = [nsi cgImage];

    img1 = [CALayer layer];
    img2 = [CALayer layer];
    img3 = [CALayer layer];
    img4 = [CALayer layer];
    img5 = [CALayer layer];    
    NSArray *allImageLayers = [NSArray arrayWithObjects:img1, img2, img3, img4, img5, nil];
    
    for (CALayer *cal in allImageLayers)
    {
        [cal setBounds:CGRectMake(0, 0, 100, 100)];
        [cal setContents:(id)cgir];
        [cal setContentsGravity:kCAGravityResizeAspect];
        [containerLayerForImages addSublayer:cal];
    }
    
    CGImageRelease(cgir);
}
#endif

-(CAAnimation *)keyframeAnimation
{
    CAKeyframeAnimation *kfa, *rotanim, *opacityanim;
    
    kfa=[CAKeyframeAnimation animationWithKeyPath:@"zPosition"];
    kfa.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-500.0],
        [NSNumber numberWithFloat: 0],
        [NSNumber numberWithFloat: 0],
        [NSNumber numberWithFloat:+500.0],
        nil];
    kfa.keyTimes=[NSArray arrayWithObjects:[NSNumber numberWithFloat:0],
        [NSNumber numberWithFloat:T_MOVE],
        [NSNumber numberWithFloat:1-T_MOVE],
        [NSNumber numberWithFloat:1.0],
        nil];
/*    kfa.timingFunctions = [NSArray arrayWithObjects:
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
        nil];
*/    //kfa.duration = FULL_ANIM_TIME;

    rotanim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotanim.values = [NSArray arrayWithObjects:
        [NSNumber numberWithFloat: -(M_PI/2)],  // initial state?
        [NSNumber numberWithFloat: -(M_PI/2)],
        [NSNumber numberWithFloat: 0],
        [NSNumber numberWithFloat: 0],
        [NSNumber numberWithFloat: -(M_PI/2)],
        nil];

    rotanim.keyTimes = [NSArray arrayWithObjects:
        [NSNumber numberWithFloat: 0],      // specify initial state?
        [NSNumber numberWithFloat: T_MOVE-T_ROTATE],
        [NSNumber numberWithFloat: T_MOVE],
        [NSNumber numberWithFloat: 1- (T_MOVE)],
        [NSNumber numberWithFloat: 1- (T_MOVE - T_ROTATE)],
        nil];

    rotanim.timingFunctions = [NSArray arrayWithObjects:
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
        nil];
        
    //rotanim.duration = FULL_ANIM_TIME;

    opacityanim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityanim.values = [NSArray arrayWithObjects:
        [NSNumber numberWithFloat: 0],
        [NSNumber numberWithFloat: 1],
        [NSNumber numberWithFloat: 1],
        [NSNumber numberWithFloat: 0],
        nil];
    opacityanim.keyTimes = [NSArray arrayWithObjects:
        [NSNumber numberWithFloat: 0],
        [NSNumber numberWithFloat: T_MOVE],
        [NSNumber numberWithFloat: 1-T_MOVE],
        [NSNumber numberWithFloat: 1],
        nil];
    
    CAAnimationGroup *caag = [CAAnimationGroup animation];
    caag.animations = [NSArray arrayWithObjects:kfa, rotanim, opacityanim, nil];

    caag.duration = FULL_ANIM_TIME;
    return caag;
}

- (BOOL)acceptsFirstResponder
{
    // accept keyboard events in the view
    return YES;
}

- (void)keyDown:(NSEvent*)event
{
    NSLog(@"keyDown");
    //[img5 addAnimation:[self keyframeAnimation] forKey:@"flyIn"];
}

- (void)setupBackgroundGradient
{
    // create a basic gradient for the background of the view
    
    CGFloat red1   =    0.0 / 255.0;
    CGFloat green1 =   72.0 / 255.0;
    CGFloat blue1  =  127.0 / 255.0;

    CGFloat red2    =   0.0 / 255.0;
    CGFloat green2  =  43.0 / 255.0;
    CGFloat blue2   =  76.0 / 255.0;

    NSColor* gradientTop    = [NSColor colorWithCalibratedRed:red1 green:green1 blue:blue1 alpha:1.0];    
    NSColor* gradientBottom = [NSColor colorWithCalibratedRed:red2 green:green2 blue:blue2 alpha:1.0];

    NSGradient* gradient;
    gradient = [[NSGradient alloc] initWithStartingColor:gradientBottom endingColor:gradientTop];

    backgroundGradient = gradient;
}

- (CATransform3D) get3DTransform
{
    CGFloat zDistance = 500.0;

	CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -zDistance;
    return transform;
}



- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        T_MOVE = 0.1;
        T_ROTATE = 0.025;
        FULL_ANIM_TIME = 4; //seconds

    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
    // draw a basic gradient for the view background
    [backgroundGradient drawInRect:[self bounds] angle:90.0];    
}

-(float)moveTime    { return T_MOVE; }
-(float)rotateTime  { return T_ROTATE; }
-(float)fullAnimTime{ return FULL_ANIM_TIME; }
-(void)setMoveTime:(float)f  { T_MOVE = f; }
-(void)setRotateTime:(float)f { T_ROTATE = f; }
-(void)setFullAnimTime:(float)f { FULL_ANIM_TIME = f; }

@end



@implementation LayerDeleterAnimationDelegate

/* This small class right here is ridiculous, but the reason it exists is
   because I can't find in the documentation any way to, given an animation,
   get the layer it was animating.  I take it this is because the same animation
   can be applied to multiple layers at arbitrary and possibly overlapping
   times, though I have not read or tested this.
   I would have liked to do something in the View object like
     -(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
     {  
        [[theAnimation layer] removeFromSuperlayer];
     }
   but instead this object hangs around as the animation delegate, storing the
   layer, solely to remove the layer when the animation is done.
*/

+(id)delegateWithLayer:(CALayer *)l
{
    LayerDeleterAnimationDelegate *ldad = [[LayerDeleterAnimationDelegate alloc] init];
    if (ldad)
    {
        [ldad setLayer:l];
        [ldad autorelease];
    }
    return ldad;
}

-(void)setLayer:(CALayer*)l
{   layer = [l retain];
}

-(void)dealloc
{
    if (layer) { [layer release]; }
    [super dealloc];
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finishedFlag
{
    //NSLog(@"removing from superlayer");
    if (finishedFlag)
    {
        [layer removeFromSuperlayer];
        [layer release];
        layer = nil;
    }
}

/* CAAnimation Class Reference */
/*
Important: The delegate object is retained by the receiver. This is a rare
exception to the memory management rules described in Memory Management
Programming Guide for Cocoa.
An instance of CAAnimation should not be set as a delegate of itself. Doing so
(outside of a garbage-collected environment) will cause retain cycles.
*/


@end

