//
//  TrafficAnalyzer.m
//  PcapSandbox
//
//  Created by Ivan Wick on 6/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TrafficAnalyzer.h"
#import "ConnectionIdentifier.h"

@implementation TrafficAnalyzer

/* Notifications */
NSString * const TADidCombineBlockRanges = @"TADidCombineBlockRanges";
NSString * const TADidAddNewBlockRange = @"TADidAddNewBlockRange";
NSString * const TAWillDeleteConnection = @"TAWillDeleteConnection";


-(id)init
{
    self = [super init];
    if (self)
    {
        _pktBuf = [[NSMutableArray alloc] initWithCapacity:10];
        _connections = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)receivedPacketNotification:(NSNotification *)note
{
	[(PacketStream*)[note object] getPacketsIntoArray:_pktBuf];

	NSEnumerator *enumer = [_pktBuf objectEnumerator];
	PcapPacket *pkt;
    PacketTCP *ptcp;
	
	while (pkt = (PcapPacket*)[enumer nextObject])
	{
        ptcp = [[PacketTCP alloc] initWithPacketIP:
                [PacketIP packetWithPacketDatalink:
                [PacketEthernet packetWithPcapPacket:pkt]]];
        
        ConnectionIdentifier *connident =
            [ConnectionIdentifier identifierForPacket:ptcp];
        
        NSLog(@"connident: %@", connident);

        ConnectionTCP *conn = [_connections objectForKey:connident];
        if (conn != nil)
        {
            NSLog(@"ConnectionIdentifier was FOUND");
            [conn addPacket:ptcp];
        }
        else
        {
            NSLog(@"ConnectionIdentifier was NOT FOUND");
            conn = [[ConnectionTCP alloc] initWithInitialPacket:ptcp];
            [_connections setObject:conn forKey:connident];
            [conn release];

            /*  FIX:
                send a notification that a new connection has been established?
            */
        }

        [ptcp release];
        // connident was autorelease
	}

    NSLog(@"_connections count: %d", [_connections count]);

	[_pktBuf removeAllObjects];
}


/*  How often should this method be called?
    I would hesitate to call it every time a packet notification is received,
    which is essentially the frequency with which Dritfnet sweeps its
    connections.  Obviously this works adequately but maybe consider setting up
    a timer or counter.
*/
-(void)sweepConnections
{
    // for each connection
    //  if (connection has received a FIN
    //      or has timed out )
    //  {   send a notification that it will be deleted
    //      delete it.
    //  }
    // }
}


-(NSString *)connectionStatus
{
    NSEnumerator *enumer = [_connections keyEnumerator];
    ConnectionIdentifier * ci;
    ConnectionTCP *ctcp;
    NSMutableString *report = [NSMutableString string];

    [report appendFormat:@"%d connections:\n", [_connections count]];
	while (ci = (ConnectionIdentifier *)[enumer nextObject])
	{
        ctcp = [_connections objectForKey:ci];
        [report appendFormat:@"%@: %d %@\n",
            ci,
            [[ctcp dataBlocks] count],
            ([ctcp hasReceivedFIN] ? @"FIN" : [[ctcp lastUpdate] description])];
    }
    
    return report;
}

@end
