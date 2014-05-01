//
//  JFIFScanner.h
//  PcapSandbox
//
//  Created by Ivan Wick on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConnectionTCP.h"

@interface JFIFScanner : NSObject {
	NSMutableDictionary * _activeScans;
}

- (void)registerAsObserver;
- (void)startNewScanForBlock:(DataBlock*)block;


// See the implementation notes for these methods
-(id)getScanForBlock:(DataBlock *)block;
-(void)removeScanForBlock:(DataBlock *)block;
-(void)setScan:(id)scan forBlock:(DataBlock *)block;


@end

// JFIFScannerDidExtractImage ??
NSString * const JFIFScannerExtractedImage;