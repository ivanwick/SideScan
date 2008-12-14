//
//  PNGScan.m
//  PcapSandbox
//
//  Created by Ivan Wick on 12/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PNGScan.h"
#import "ScannerUtils.h"

const char          PNG_SIGNATURE[] = { 0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n' };
const unsigned int  PNG_SIGLENGTH  = 8;
const unsigned int  PNG_CHECKSUM_LENGTH = 4;
const unsigned int  PNG_CHUNKLEN_LENGTH = 4;
const unsigned int  PNG_CHUNKTAG_LENGTH = 4;

@implementation PNGScan

-(id) initWithDataBlock:(DataBlock *)db
{
    self = [super init];
    if (self)
    {
        _taggedRanges = [[NSMutableArray alloc] init];
        _followingImage = NO;
    
        _scanPosOffset = 0;
        _block = [db retain];
    }
    return self;
}

-(void)dealloc
{
    [_taggedRanges release];
    [_block release];
    [super dealloc];
}

-(void)advance
{
    NSData *d = [_block data];
    while (_scanPosOffset < [d length])
    {
        if (_followingImage)
        {   [self advanceByChunk];
        }
        else
        {   [self advanceToSignature];
        }
    }
}


// Precondition for this method is that the scan is currently following a PNG
// image (_followingImage == YES).
// This method will advance by a single chunk provided there is enough data
// ready.
// If the IEND chunk is found, then this method publishes the image and resets
// the scan state.
-(void)advanceByChunk
{
    NSData *d = [_block data];
    const void *dbytes = [d bytes];
    void * lastChunk;
    unsigned int nextChunkOffset;

    // Before you check the chunk size, make sure there is enough space for it!
    if ([d length] - _lastChunkOffset < 4)
    {
        _scanPosOffset = [d length];
        return;
    }
    
    lastChunk = (void*)(dbytes + _lastChunkOffset);  // make a pointer from the offset

    // make sure there is enough space for the chunk itself
    if ([PNGScan lengthForChunk:lastChunk] > [d length] - _lastChunkOffset)
    {
        _scanPosOffset = [d length];
        return;
    }

    nextChunkOffset = _lastChunkOffset + [PNGScan lengthForChunk:lastChunk];
	
    // see if we just finished an image
    if ([PNGScan isEndChunk:lastChunk])
    {
        // publish the image we found
        [self publishImage:
            [[[NSImage alloc] initWithData:
                [d subdataWithRange:NSMakeRange(_imageStartOffset,
                                        (nextChunkOffset - _imageStartOffset))]]
                autorelease]];

        // FIX: tag it in _taggedRanges so that it doesn't get parsed out again
        
        // reset scan state
        _scanPosOffset = nextChunkOffset;
        _followingImage = NO;
        _imageStartOffset = 0;      // eh might as well
    }
    else
    {
        _lastChunkOffset = nextChunkOffset;
        _scanPosOffset = nextChunkOffset;
    }
}

-(void)publishImage:(NSImage *)img
{
    NSLog(@"found an image you monsters: %@", img);
    
    [[NSNotificationCenter defaultCenter] postNotification:
        [NSNotification notificationWithName:PNGScannerExtractedImage
        object:img]];
}

// Precondition for this method is that the scan is currently in an inter-image
// region of data and is not following chunks. The scan position is advanced by
// using memmem to look for the PNG file signature, while also avoiding tagged
// regions (i.e. regions that have already been identified as images).
// If the signature is found, the scan state is updated to reflect this.
// Otherwise, only the _scanPosOffset is updated.
-(void)advanceToSignature
{
    NSData *d = [_block data];
    const void *dbytes = [d bytes];
    void * newPos;
    unsigned int newPosOffset;
    
    // FIX: This needs to be changed so that the signature scan avoids regions
    // that are tagged.
    newPos = SUmemmem(dbytes + _scanPosOffset, [d length] - _scanPosOffset,
                      PNG_SIGNATURE, PNG_SIGLENGTH);
                       

    if (newPos == NULL)  // nothing found
    {
        _scanPosOffset = [d length];
    }
    else
    {
        newPosOffset = (newPos - dbytes);
        
        _imageStartOffset = newPosOffset;
        _lastChunkOffset = newPosOffset + PNG_SIGLENGTH;
        _scanPosOffset = _lastChunkOffset;
        _followingImage = YES;
    }
}

-(void)resetWithNewDataBlock:(DataBlock*)newBlock
{
    int diff = [_block range].location - [newBlock range].location;

    // FIX: recompute offsets in _taggedRanges for use with new block
    // it will be something like:
    //
    // for each range
    //   r.location += diff
    // end

    if (diff != 0)
    {
        _scanPosOffset = 0;
        _followingImage = NO;
    }

    [_block release];
    _block = [newBlock retain];
}

-(void)mergeWithScan:(PNGScan *)otherScan
{
/*  I am not going to bother implementing this right now for a couple reasons:
    - Keeping track of tagged ranges is not impemented anywhere else
    - Tagged ranges functionality is probably better parted out to a separate
      class that implements things like
        add/remove ranges
        nextRangeAfterLocation:(int)
        mergeWithList:(RangeList *)rl offset:(int)
        mergeWithList:(RangeList *)rl // offset implicitly zero
      Also there is going to be a slight mess from having to deal with NSValue
      objects to encode and decode NSRange structs.
      btw the following methods on NSValue are pertinent:
        + (NSValue *)valueWithRange:(NSRange)range
        - (NSRange)rangeValue
*/
/*
    int diff = [_block range].location - [[otherScan block] range].location;
    NSArray * oRanges = [otherScan taggedRanges];
    NSEnumerator * orenum = [oRanges objectEnumerator];
    NS
    
    while (
    
    [_taggedRanges addObjectsFromArray:[otherScan taggedRanges]];
*/
}

-(DataBlock *)block         { return _block; }
-(NSArray *)taggedRanges    { return _taggedRanges; }

-(void)finalize
{
    NSLog(@"PNGScan finalize");
    if (_followingImage)
    {
        NSLog(@"publish what you got.");
    }
}


+(unsigned int)lengthForChunk:(void*)c
{
    return PNG_CHUNKLEN_LENGTH
        + NSSwapBigIntToHost(((unsigned int*)c)[0])  // data length
        + PNG_CHECKSUM_LENGTH
        + PNG_CHUNKTAG_LENGTH;
}

+(BOOL) isEndChunk:(void*)c
{
    return (memcmp(c+4, "IEND", 4) == 0);
}

@end
