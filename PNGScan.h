//
//  PNGScan.h
//  PcapSandbox
//
//  Created by Ivan Wick on 12/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataBlock.h"
#import "PNGScanner.h"

// This could also be called a "ScanState"
// Maybe it will be changed to that by the time I am finished

@interface PNGScan : NSObject {
    NSMutableArray * _taggedRanges;
    BOOL _followingImage;

    DataBlock *_block;

    // These need to be offsets instead of actual pointers because the
    // DataBlock's NSMutableData could experience an appendData message caused
    // by block combination and that might invalidate pointers to actual memory.
    unsigned int _imageStartOffset;
    unsigned int _lastChunkOffset;
    unsigned int _scanPosOffset;
}


-(id)initWithDataBlock:(DataBlock *)db;
-(void)advance;
-(void)resetWithNewDataBlock:(DataBlock*)newBlock;
-(void)mergeWithScan:(PNGScan *)otherScan;
-(void)finalize;

+(unsigned int)lengthForChunk:(const void *)c;
+(BOOL) isEndChunk:(const void *)c;


/// accessors
-(NSArray*)taggedRanges;
-(DataBlock *)block;

/// private
-(void)advanceByChunk;
-(void)advanceToSignature;
-(void)publishImage:(NSImage*)img;

@end
