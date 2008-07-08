//
//  ConnectionTCP.m
//  PcapSandbox
//
//  Created by Ivan Wick on 5/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ConnectionTCP.h"


@implementation ConnectionTCP

- (id)init
{
    self = [super init];
    if (self)
    {
        _blockRanges = [[NSMutableArray alloc] init];
        _fin = NO;
    }
    return self;
}

- (id)initWithInitialPacket:(PacketTCP*)pkt
{
    self = [self init];
    if (self)
    {
        _sport = [pkt sourcePort];
        _dport = [pkt destPort];
        _saddr = [pkt sourceIPAddr];
        _daddr = [pkt destIPAddr];
        _isn   = [pkt seqNum];
        
        [self addPacket:pkt];
    }
    return self;
}

- (void)dealloc
{
    [_blockRanges release];
    [super dealloc];
}

- (unsigned short)sourcePort  {   return _sport;  }
- (unsigned short)destPort    {   return _dport;  }
- (struct in_addr)sourceIPAddr{   return _saddr;  }
- (struct in_addr)destIPAddr  {   return _daddr;  }
- (NSDate *)lastUpdate  {   return _lastUpdate;  }
- (BOOL)hasReceivedFIN  {   return _fin;    }
- (unsigned int)isn     {   return _isn;    }

- (void)addPacket:(PacketTCP*)pkt
{
    if ([pkt dataLength] > 0)
    {
        DataBlock *newblk = [[DataBlock alloc] initWithInitialPacket:pkt
                                    initialSeqNum:[self isn]];
        [_blockRanges addObject:newblk];
        [_blockRanges sortUsingSelector:@selector(compareRangeLocationWith:)];
        [newblk release];
        
        [self combineAdjacentDataBlocks];
    }

    // check the FIN flag for future sweeping
    _fin = [pkt finFlag];

    [_lastUpdate release];
    _lastUpdate = [[NSDate date] retain]; // now
}

-(void)combineAdjacentDataBlocks
{
    BOOL didCombine = YES;
    int i;
    DataBlock *blk, *nextblk;
    NSRange brange, nrange;

    while (didCombine)
    {
        didCombine = NO;
        for (i = 0; i < [_blockRanges count] - 1; i++)
        {
            blk = [_blockRanges objectAtIndex:i];
            nextblk = [_blockRanges objectAtIndex:(i+1)];
            brange = [blk range];
            nrange = [nextblk range];
            
            NSLog(@"brange: %d, %d\tnrange: %d, %d",
                brange.location, brange.length,
                nrange.location, nrange.length);
            

            if (brange.location + brange.length >= nrange.location)
            {
                [blk combineWithDataBlock:nextblk];
                [_blockRanges removeObjectAtIndex:(i+1)];
                didCombine = YES;
                
                /* back up index so that the next pass will include another
                    analysis of this iteration's blk */
                i--;
            }
        }
    }
    // if adjacent block is found, combine with it and issue TADidCombineRanges
    // else keep the block and issue TADidAddNewBlockRange

    // add packet to the list of blocks, resizing NSMutableData as neccessary.
    // TADidAddNewBlockRange
    
    // if appropriate, combine adjacent block ranges.
    // TADidCombineRanges
    
    // Maybe the above two operations should be mutually exclusive for each
    // packet, so that observers don't have to process a new block and
    // immediately throw away their work when the blocks get combined.
    // An optimisation??
}

- (NSArray *)dataBlocks { return _blockRanges; }

- (void)writeBlocksToFile:(NSString*)path
{
    NSEnumerator* e;
    e = [_blockRanges objectEnumerator];
    DataBlock *blk;
    int c;
    
    c = 0;
    while (blk = [e nextObject])
    {
        if ([blk range].length > 0)
        {   [[blk data] writeToFile:[NSString stringWithFormat:@"%@_%08x_%02d_%u_%u",
                                      path, self, c, [blk rangeLocation], [blk range].length]
                        atomically:YES];
                        
            NSLog([NSString stringWithFormat:@"%@_%08x_%02d_%u_%u",
                    path, self, c, [blk rangeLocation], [blk range].length]);
        }
        c++; // NO ITS NOT ITS OBJECTIVE C LOLOLOLOLO
    }
}


@end


#if 0
/*  Here is an override for isEqual so that a certain connection can be
    identified out of an array of connections.  For this purpose, the identity
    of a connection is:
        source ip addr, source port, dest ip addr, dest port.
        
    This means that a single tcp packet by itself has all of the identifying
    information of a connection, and might can be compared to each other.  For
    this purpose, I made a protocol TCPConnectionIdentifiable.
    
    My fear is that if this code ever gets reused, that the identity of a
    connection may need to be defined differently.  Furthermore, should we
    allow this comparison of a connection against a single packet?
    
    Maybe a separate object should be defined e.g. ConnectionIdentifier, so
    that we can be pedantic and only compare the ConnectionIdentifiers to
    other objects of the same or inheriting class, then instead of storing an
    array of connections, we store a hashtable of connectionidentifier keys
    for connection object values.
    
    Actually that is a good idea.  Later if necessary, this extra layer can be
    optimised down to overriding [ConnectionTCP isEqual:] so that a new objects
    don't have to be allocated every time we want to compare connections and
    packets.
    
        ConnectionIdentifier
            +(id)identifierFromPacket:(PacketTCP*)pkt
            {
                self = [[super alloc] init];
                if (self)
                {
                //  in here do we want to retain a reference to pkt and just
                //  pass messages through to it or do we want to copy the 
                //  values for port and addr to self?
                
                    [pkt retain];
                }
                
                return [self autorelease];
            }
            
            +(id)identifierFromConnection:(ConnectionTCP*)conn;
            
            -(BOOL)isEqual:(id)other
            {
                return ([other isKindOfClass:[self class]]
                    &&  [self sourceIPAddr] == [other sourceIPAddr]
                    &&  [self sourcePort]   == [other sourcePort]
                    &&  [self destIPAddr]   == [other destIPAddr]
                    &&  [self destPort]     == [other destPort] );
            }
                
*/
-(BOOL)isEqual:(id)other
{
    if (other == nil) { return NO; }
    if ([other conformsToProtocol:@protocol(TCPConnectionIdentifiable)])
    {
        return ([self connectionIdentityMatches:other])
    }
    
    // by default:
    return NO;
}

-(BOOL)connectionIdentityMatches:(id <TCPConnectionIdentifiable>)other
{
    return ([self sourcePort] == [other sourcePort]
        &&  [self destPort]   == [other destPort]
        &&  [self sourceIPAddr] == [other sourceIPAddress]
        &&  [self destIPAddr] == [other destIPAddr] );
}


////////////////////////////////////////////////////////////////////////////////
    Datablock *blk, *nextblk = nil;
    unsigned int i;
    
    if ([_blockRanges count] == 0)
    {   [_blockRanges addObject:newblk];
    }
    else
    {
        blk = nil;
        nextblk = [_blockRanges objectAtIndex:0];
        i = 0;
        do
        {
            if ([nextblk rangePosition] > [newblk rangePosition])
            {   // possibly combine with blk, or maybe with nextblk
                brange = [blk range];
                if (blk != nil
                 && brange.location + brange.length == [newblk rangeLocation]+1)
                {
                    combine them;
                }
                
                if (
                // check for combination with nextblk
                // check for combination with blk
                
                break;
            }
            i++;
        } while (i < [_blockRanges count]);
    }


#endif
