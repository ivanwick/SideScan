//
//  untitled.h
//  PcapSandbox
//
//  Created by Ivan Wick on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ConnectionTCP.h"   // dude we can take this out once those
                            // scan hash methods are out of here


@interface GIFScanner : NSObject {
    NSMutableDictionary * _activeScans;
}

// GIFScannerDidExtractImage ??
NSString * const GIFScannerExtractedImage;

- (void)registerAsObserver;
- (void)startNewScanForBlock:(DataBlock*)block;



// See the implementation notes for these methods
-(id)getScanForBlock:(DataBlock *)block;
-(void)removeScanForBlock:(DataBlock *)block;
-(void)setScan:(id)scan forBlock:(DataBlock *)block;


@end