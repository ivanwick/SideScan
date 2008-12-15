//
//  untitled.m
//  PcapSandbox
//
//  Created by Ivan Wick on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GIFScanner.h"
#import "GIFScan.h"

@implementation GIFScanner

NSString * const GIFScannerExtractedImage = @"GIFScannerExtractedImage";

- (void)registerAsObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(receivedCombinedBlocksNotification:)
                name:CTDidCombineBlockRanges
                object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(receivedAddedBlockNotification:)
                name:CTDidAddNewBlockRange
                object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(receivedWillDiscardNotification:)
                name:CTWillBeDiscarded
                object:nil];
}

- (void)receivedCombinedBlocksNotification:(NSNotification *)note
{
    NSDictionary *uinfo = [note userInfo];
    DataBlock *extblock, *discblock;
    extblock = [uinfo objectForKey:@"extendedBlock"];
    discblock = [uinfo objectForKey:@"discardedBlock"];
    GIFScan *escan, *dscan;
    
    escan = [self getScanForBlock:extblock];
    dscan = [self getScanForBlock:discblock];
 
    /*
    NSLog(@"GIFScanner combinedBlocks -- escan:%@\tdscan:%@", escan, dscan);
    NSLog(@"\textblock:%@\tdiscblock:%@",
            extblock ? NSStringFromRange([extblock range]) : nil,
            discblock ? NSStringFromRange([discblock range]) : nil);
    */
 
    if (dscan != nil)
    {
        if (escan != nil)
        {   // both present: merge
            [escan mergeWithScan:dscan];
        }
        else
        {   // only dscan present, retarget it for extblock and save
            [dscan resetWithNewDataBlock:extblock];
            [self setScan:dscan forBlock:extblock];
        }
        
        // in both cases we are no longer keeping track of discblock
        [self removeScanForBlock:discblock];
    }
    else // (dscan == nil)
    {
        if (escan == nil)
        {
            [self startNewScanForBlock:extblock];
            // startNewScanForBlock sends "advance" to the new scan.
        }
    }
    
    [escan advance];
}

- (void)receivedAddedBlockNotification:(NSNotification *)note
{
    NSDictionary *uinfo = [note userInfo];
    DataBlock *newblock = [uinfo objectForKey:@"newBlock"];

    [self startNewScanForBlock:newblock];
}

-(void)startNewScanForBlock:(DataBlock*)block
{
    GIFScan * scan = [[GIFScan alloc] initWithDataBlock:block];
    
    [self setScan:scan forBlock:block];  // this retains scan and block

    // FIX: do we need to advance here?  maybe just return the new Scan and make
    // it the calling method's responsibility to advance it.
    [scan advance];
    [scan release];
}

- (void)receivedWillDiscardNotification:(NSNotification *)note
{
    ConnectionTCP *conndisc = (ConnectionTCP *)[note object];
    DataBlock *b;
    GIFScan *scan;
    
    NSEnumerator *enblk = [[conndisc dataBlocks] objectEnumerator];
  	while (b = (DataBlock*)[enblk nextObject])
	{
        scan = [self getScanForBlock:b];
        if (scan != nil)
        {
            [scan finalize];
            [self removeScanForBlock:b];
        }
    }
    // NSLog(@"ORLY YARLY");
}

-(id)init
{
    self = [super init];
    if (self)
    {
        _activeScans = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return self;
}
-(void)dealloc
{
    [_activeScans release];
    [super dealloc];
}


/* These are some cheap methods that essentially wrap the _activeScans
   dictionary so that NSValues are being stored as keys instead of copying the
   DataBlocks when they are used as keys.
   
   Some alternatives are:
     - Use a NSMapTable, except this only works in 10.5
     - Write a dictionary wrapper class to do the NSValue conversion
     - Make a NSValue-storing category over NSMutableDictionary
*/
//-(PNGScan *)getScanForBlock:(DataBlock *)block
-(id)getScanForBlock:(DataBlock *)block
{
    return [_activeScans objectForKey:[NSValue valueWithBytes:&block
                                                objCType:@encode(DataBlock *)]];
}

-(void)removeScanForBlock:(DataBlock *)block
{
    [_activeScans removeObjectForKey:[NSValue valueWithBytes:&block
                                                objCType:@encode(DataBlock *)]];
}

//-(void)setScan:(PNGScan *)scan forBlock:(DataBlock *)block
-(void)setScan:(id)scan forBlock:(DataBlock *)block
{
    [_activeScans setObject:scan forKey:[NSValue valueWithBytes:&block
                                                objCType:@encode(DataBlock *)]];
}

-(void)dumpActiveScansComparing:(NSValue*)v
{
    NSEnumerator *e = [_activeScans keyEnumerator];
    NSValue *k;
    while (k = [e nextObject])
    {
        NSLog(@"%@ => %@", k, [_activeScans objectForKey:k]);
        if ([v isEqual:k])
        {   NSLog(@"match");
        }
    }
}

@end
