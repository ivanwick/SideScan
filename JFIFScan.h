//
//  JFIFScan.h
//  PcapSandbox
//
//  Created by Ivan Wick on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataBlock.h"
#import "JFIFScanner.h"


@interface JFIFScan : NSObject {
    NSMutableArray * _taggedRanges;
    BOOL _followingImage;
	
    DataBlock *_block;
	
    // These need to be offsets instead of actual pointers because the
    // DataBlock's NSMutableData could experience an appendData message caused
    // by block combination and that might invalidate pointers to actual memory.
    unsigned int _imageStartOffset;
    unsigned int _lastChunkOffset;
    unsigned int _scanPosOffset;
    unsigned int _sigScanOffset;
}


-(id)initWithDataBlock:(DataBlock *)db;
-(void)advance;
-(void)resetWithNewDataBlock:(DataBlock*)newBlock;
-(void)mergeWithScan:(JFIFScan *)otherScan;
-(void)finalize;


/// accessors
-(NSArray*)taggedRanges;
-(DataBlock *)block;

/// private
-(void)advanceToSOI;
-(void)advanceToEOI;
-(void)publishImage:(NSImage*)img;

@end
