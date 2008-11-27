//
//  ConnectionTCP.h
//  PcapSandbox
//
//  Created by Ivan Wick on 5/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PacketTCP.h"
#import "DataBlock.h"

@interface ConnectionTCP : NSObject {
    unsigned short _sport;
    unsigned short _dport;
    struct in_addr _saddr;
    struct in_addr _daddr;
    
    /*  the packets dictionary maps [DataBlockRange offset]s to DataBlockRanges 
        In driftnet, these are sorted by the offset, I don't know exactly
        if or how the NSMutableDictionary would sort its keys like that.
        But you can use
            keysSortedByValueUsingSelector:
        if you need the blocks sorted, which we do in order to step through
        the sorted block list combining blocks with adjacent data.
        
        So maybe we actually should be using an NSMutableArray (driftnet uses
        a linked list) that is just maintained in sorted order.
    */

    /*  FIX ok here's an idea:
        Maybe the DataBlocks should be in a hash which is keyed by the ending
        offset of the range, so that it will be easy to find a packet which is
        immediately following the one in the hash, simply
            [dict getObjectForKey:[newdatablock endRange]-1];
        but what if there are overlaps due to changing window size or something?
    */

    NSMutableArray * _blockRanges;
    NSDate * _lastUpdate;
    BOOL _fin;
    unsigned int _isn;
}

/* Notifications */
NSString * const CTDidCombineBlockRanges;
NSString * const CTDidAddNewBlockRange;
NSString * const CTWillBeDiscarded;
NSString * const CTDidReceiveFIN;

- (id)initWithInitialPacket:(PacketTCP *)pkt;
- (void)addPacket:(PacketTCP*)pkt;
- (BOOL)combineAdjacentDataBlocks;

- (unsigned short)sourcePort;
- (unsigned short)destPort;
- (struct in_addr)sourceIPAddr;
- (struct in_addr)destIPAddr;
- (NSDate *)lastUpdate;
- (BOOL)hasReceivedFIN;
- (unsigned int)isn;

- (NSArray *)dataBlocks;
- (void)willDiscard;


- (void)writeBlocksToFile:(NSString*)path;


@end
