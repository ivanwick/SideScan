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

-(void)appendDataBlock:(DataBlock *)blk
{
    [_data appendData:[blk data]];
    _range = NSMakeRange(_range.location, _range.length + [blk range].length);
}


/* this method combineWithDataBlock is essentially a wrapper for appendDataBlock
   with some range checking in case the ranges aren't adjacent, but overlap.
*/
-(void)combineWithDataBlock:(DataBlock *)blk
{
    // if ranges overlap, make a new DataBlock out of the non-overlapping part
    // of blk, and call appendDataBlock on the new DataBlock slice.
    
    // Otherwise, just pass this message through to appendDataBlock
    
    NSRange otherRange = [blk range];
    DataBlock *sliceBlock;
    
    if (_range.location + _range.length > otherRange.location)
    {
        // make a new one?? or maybe just have a way to extract the data

        // slice it
        #if 0
        sliceBlock = [[DataBlock alloc] initWithInitialPacket: initialSeqNum:;
        [self appendDataBlock:sliceBlock];
        [sliceBlock release];
        #endif
        NSLog(@"combine blocks with nonadjacent ranges??? QUIT YO JIBBA JABBA!!");
    }
    else
    {
        assert(_range.location + _range.length == otherRange.location);
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
