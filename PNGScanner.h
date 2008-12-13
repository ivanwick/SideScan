//
//  PNGScanner.h
//  PcapSandbox
//
//  Created by Ivan Wick on 12/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConnectionTCP.h"

// this should actually be "internal" i.e. in the implementation file, since
// the PNGScan is not part of the public interface of this class
// It's here because of the dictionary wrapper methods at the bottom.
// FIX: do something about this.
#import "PNGScan.h"


@interface PNGScanner : NSObject {
    NSMutableDictionary * _activeScans;
}

- (void)registerAsObserver;
- (void)startNewScanForBlock:(DataBlock*)block;



// See the implementation notes for these methods
-(PNGScan *)getScanForBlock:(DataBlock *)block;
-(void)removeScanForBlock:(DataBlock *)block;
-(void)setScan:(PNGScan *)scan forBlock:(DataBlock *)block;

@end