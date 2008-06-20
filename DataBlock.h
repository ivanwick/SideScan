//
//  DataBlock.h
//  PcapSandbox
//
//  Created by Ivan Wick on 6/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PacketTCP.h"

@interface DataBlock : NSObject {
    NSRange _range;
    NSMutableData*  _data;
}

-(id)init;
-(id)initWithInitialPacket:(PacketTCP *)pkt initialSeqNum:(unsigned int)isn;

-(NSRange)range;
-(NSData*)data;

// a private one
-(unsigned int)offsetWraparoundSeqNum:(unsigned int)seqnum
    initialSeqNum:(unsigned int)isn;

-(void)appendDataBlock:(DataBlock *)blk;
-(void)combineWithDataBlock:(DataBlock *)blk;

/*  DataBlock needs to implement KVC on the range location so that the
    connection class can sort them to more easily find blocks to combine dudez.
*/
-(unsigned int)rangeLocation;
-(NSComparisonResult)compareRangeLocationWith:(DataBlock *)other;
@end
