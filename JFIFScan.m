//
//  JFIFScan.m
//  PcapSandbox
//
//  Created by Ivan Wick on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "JFIFScan.h"
#import "ScannerUtils.h"

@implementation JFIFScan

const char			JFIF_SOI_APP0[] = { 0xff, 0xd8, 0xff, 0xe0 };
const unsigned int	JFIF_SOI_APP0_LENGTH = 4;
const unsigned int	JFIF_APP0LEN_LENGTH = 2;
const char			JFIF_APP0_IDENTIFIER[] = "JFIF";  // yes, null terminated
const char			JFIF_APP0_IDENTIFIER_LENGTH = 5;  // yes, include the \0
const char			JFIF_EOI[] = { 0xff, 0xd9 };
const char			JFIF_EOI_LENGTH = 2;

-(id)initWithDataBlock:(DataBlock *)db
{
	self = [super init];
	if (self)
	{
		_taggedRanges = [[NSMutableArray alloc] init];
		_followingImage = NO;
		
		_scanPosOffset = 0;
        _sigScanOffset = 0;
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

-(void)publishImage:(NSImage *)img
{
    NSLog(@"JFIF image extracted sir: %@", img);
    
    [[NSNotificationCenter defaultCenter] postNotification:
	 [NSNotification notificationWithName:JFIFScannerExtractedImage
								   object:img]];
}


-(void)advance
{
	NSData *d = [_block data];
	while (_scanPosOffset < [d length])
	{
		if (_followingImage)
		{	[self advanceToEOI];
		}
		else
		{	[self advanceToSOI];
		}
	}
}

-(void)advanceToSOI
{
	NSData *d = [_block data];
	const void *dbytes = [d bytes];
	void *newPos;
	unsigned int newPosOffset;
	
    // FIX: This needs to be changed so that the signature scan avoids regions
    // that are tagged.
	newPos = SUmemmem(dbytes + _sigScanOffset, [d length] - _sigScanOffset,
					  JFIF_SOI_APP0, JFIF_SOI_APP0_LENGTH);
	newPosOffset = (newPos - dbytes);
	
	if (newPos == NULL)
	{
		_scanPosOffset = [d length];
        _sigScanOffset = [d length] - JFIF_SOI_APP0_LENGTH;
		return;
	}
    
    _sigScanOffset = newPosOffset;
	
	// bail out if there is not enough data for the rest of the signature
	if ( newPosOffset + JFIF_SOI_APP0_LENGTH
	                  + JFIF_APP0LEN_LENGTH
					  + JFIF_APP0_IDENTIFIER_LENGTH
		> [d length] )
	{
        _scanPosOffset = [d length];
		return;
	}

	newPos       += JFIF_SOI_APP0_LENGTH + JFIF_APP0LEN_LENGTH;
	newPosOffset += JFIF_SOI_APP0_LENGTH + JFIF_APP0LEN_LENGTH;

	if (0 != memcmp(newPos, JFIF_APP0_IDENTIFIER, JFIF_APP0_IDENTIFIER_LENGTH))
	{
        _sigScanOffset += JFIF_SOI_APP0_LENGTH;
		_scanPosOffset = _sigScanOffset;
		return;
	}

	// if control reaches here without having returned early, REAL SIGNATURE
	// change state of the scan
    _imageStartOffset = _sigScanOffset;
    _scanPosOffset = newPosOffset + JFIF_APP0_IDENTIFIER_LENGTH;
    _followingImage = YES;
}


-(void)advanceToEOI
{
	NSData *d = [_block data];
	const void *dbytes = [d bytes];
	void *imgEnd;

	imgEnd = SUmemmem(dbytes + _scanPosOffset, [d length] - _scanPosOffset,
					  JFIF_EOI, JFIF_EOI_LENGTH);
					  
	if (imgEnd == NULL)
	{
		_scanPosOffset = [d length];
	}
	else
	{
		// for future convenience, increment imgEnd past the EOI tag
		imgEnd += JFIF_EOI_LENGTH;
		
		// publish one for great justice
		[self publishImage:
			[[[NSImage alloc] initWithData:         // IM IN UR OBJ-C
				[d subdataWithRange:                // LISPING UR COCOA
					NSMakeRange(_imageStartOffset,
								((imgEnd - dbytes) - _imageStartOffset))]]
				autorelease]];

        // FIX: tag it in _taggedRanges so that it doesn't get parsed out again
        
        // reset scan state
        _sigScanOffset = (imgEnd - dbytes);
        _scanPosOffset = _sigScanOffset;
        _followingImage = NO;
        _imageStartOffset = 0;      // eh might as well
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

-(void)mergeWithScan:(JFIFScan *)otherScan
{
	/*  I am not going to bother implementing this right now for a couple reasons:
	 - Keeping track of tagged ranges is not impemented anywhere else
	 - Tagged ranges functionality is probably better parted out to a separate
	 class that implements things like
		add/remove ranges
		nextRangeAfterLocation:(int)
		mergeWithList:(RangeList *)rl offset:(int)
		mergeWithList:(RangeList *)rl // offset implicitly zero
	 since there is going to be a slight mess from having to deal with NSValue
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
    if (_followingImage)
    {
        NSLog(@"JFIFScan publish what you got. but not really.");
    }
}


@end
