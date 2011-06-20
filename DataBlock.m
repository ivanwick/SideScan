//
//  DataBlock.m
//  PcapSandbox
//
//  Created by Ivan Wick on 6/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DataBlock.h"


@implementation DataBlock

-(id)init
{
    self = [super init];
    if (self)
    {
        _data = [[NSMutableData alloc] init]; // or should this just be nil?
        _range = NSMakeRange(0,0);
    }
    return self;
}

-(void)dealloc
{
    [_data release];
    [super dealloc];
}

+(id)dataBlockWithData:(NSMutableData *)someData range:(NSRange)aRange {
	DataBlock *newDataBlock = [[DataBlock alloc] init];
	[newDataBlock setData:someData];
	[newDataBlock setRange:aRange];
	[newDataBlock autorelease];
	return newDataBlock;
}


-(id)initWithInitialPacket:(PacketTCP *)pkt initialSeqNum:(unsigned int)isn;
{
    self = [super init];
    if (self)
    {
        /*  FIX WARNING: this is a possible source of memory allocation errors
            as I do not know exactly how the data from pkt is being handled
            here (e.g. copy or reference?)
            
            ALSO: if you check the -(NSData*)data method for PcapPacket, you see
            that an autorelease NSData is being returned back here, and then
            we are copying it AGAIN in this method.  Possible optimisation.
        */
        _data = [[NSMutableData alloc]
                    initWithBytes:[pkt dataPointer] length:[pkt dataLength]];

        // ISN'T SEQUENCE NUMBER WRAPAROUND CHECKING NECESSARY HERE??
        // YES IT IS
        _range = NSMakeRange(
            [self offsetWraparoundSeqNum:[pkt seqNum] initialSeqNum:isn],
            [_data length]);
        
        if (_range.location < 0)
        {
            NSLog(@"\trange location: %d", _range.location);
            NSLog(@"\twhy?? isn: %d\tdatalen:%d", isn, [_data length]);
        }

    }
    return self;
}

-(unsigned int)offsetWraparoundSeqNum:(unsigned int)seqnum
    initialSeqNum:(unsigned int)isn
{
    if (seqnum < isn) { return seqnum - isn; }
    else {   return ((unsigned int)-1) - isn + seqnum;  }
}


-(NSRange)range {   return _range;  }
-(NSData*)data  {   return _data;   }

-(void)setRange:(NSRange)r { _range = r;  }
-(void)setData:(NSMutableData *)d  { _data = d;   }

-(void)appendDataBlock:(DataBlock *)blk
{
    [_data appendData:[blk data]];
    _range = NSMakeRange(_range.location, _range.length + [blk range].length);
}


/* this method combineWithDataBlock is essentially a wrapper for appendDataBlock
   with some range checking in case the ranges aren't adjacent, but overlap.

   This method does not handle a new block whose range is BEFORE self. (as seen
   in the NSAssert)
 */
-(void)combineWithDataBlock:(DataBlock *)blk
{
    // if ranges overlap, make a new DataBlock out of the non-overlapping part
    // of blk, and call appendDataBlock on the new DataBlock slice.
    
    // Otherwise, just pass this message through to appendDataBlock
	
    NSRange otherRange = [blk range];

	NSAssert(_range.location <= otherRange.location,
			 @"This method doesn't handle a new block with range BEFORE self");
    
	NSRange intersectRange = NSIntersectionRange(_range, otherRange);
	NSUInteger appendLoc = _range.location + _range.length;
	
    if (intersectRange.length > 0)
    {
		/* otherRange overlaps with _range. */
		if (otherRange.location + otherRange.length > appendLoc) {
			/* otherRange overhangs the end of _range so we need to
			   slice and keep the extra data */
		
			NSRange sliceRange = NSMakeRange(appendLoc, 
									 otherRange.length - intersectRange.length);
			NSMutableData * sliceData = [NSMutableData dataWithBytesNoCopy:(void*)([[blk data] bytes]+intersectRange.length)
																	length:sliceRange.length];
			DataBlock *sliceBlock = [DataBlock dataBlockWithData:sliceData range:sliceRange];
			[self appendDataBlock:sliceBlock];
		}
		else {
			/* otherRange is fully contained within _range.
			   no need to process it further.
			 */
			NSLog(@"skipping fully contained JIBBA JABBA");
		}
    }
    else
    {
        NSAssert(_range.location + _range.length == otherRange.location,
				@"DataBlock to append isn't directly adjacent");
        [self appendDataBlock:blk];
    }
					  
					  
}

-(unsigned int)rangeLocation    { return _range.location; }

-(NSComparisonResult)compareRangeLocationWith:(DataBlock *)other
{
    if (_range.location < [other rangeLocation])
    {   return NSOrderedAscending; }
    else if (_range.location > [other rangeLocation])
    {   return NSOrderedDescending; }
    else /* (_range.location == [other rangeLocation])*/
    {   return NSOrderedSame; }
}

@end
