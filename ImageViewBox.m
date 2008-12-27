//
//  ImageViewBox.m
//  PcapSandbox
//
//  Created by Ivan Wick on 12/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ImageViewBox.h"


@implementation ImageViewBox

// -----------------------------------------------------------------------------
//	hitTest:aPoint
// -----------------------------------------------------------------------------
- (NSView *)hitTest:(NSPoint)aPoint
{
	// don't allow any mouse clicks for subviews in this NSBox
	return nil;
}

@end

