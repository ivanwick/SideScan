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
NSString * const TADidProcessPacket = @"TADidProcessPacket";

/* Constant */
#define TAConnectionTimeout 60

-(id)init
{
    self = [super init];
    if (self)
    {
        _pktBuf = [[NSMutableArray alloc] initWithCapacity:10];
        _connections = [[NSMutableDictionary alloc] init];
        
        _sweepTimer = [NSTimer timerWithTimeInterval:10
                        target:self
                        selector:@selector(periodicSweep:)
                        userInfo:nil
                        repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_sweepTimer
            forMode:NSDefaultRunLoopMode];
        
    }
    return self;
}

-(void) dealloc
{
    [_pktBuf release];
    [_connections release];
    [_sweepTimer invalidate];

    [super dealloc];
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
        
        // NSLog(@"connident: %@", connident);

        ConnectionTCP *conn = [_connections objectForKey:connident];
        if (conn != nil)
        {
            // NSLog(@"ConnectionIdentifier was FOUND");
            [conn addPacket:ptcp];
        }
        else
        {
            // NSLog(@"ConnectionIdentifier was NOT FOUND");
            conn = [[ConnectionTCP alloc] initWithInitialPacket:ptcp];
            [_connections setObject:conn forKey:connident];
            [conn release];

        }

        [[NSNotificationCenter defaultCenter]
            postNotificationName:TADidProcessPacket
            object:self];  // maybe ptcp should be in here somewhere???

        [ptcp release];
        // connident was autorelease
	}

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
    NSLog(@"sweeping now sir");
    NSEnumerator *enumer = [_connections keyEnumerator];
    ConnectionIdentifier *ci;
    ConnectionTCP *ctcp;
    NSMutableArray *removeList = [NSMutableArray
                                    arrayWithCapacity:[_connections count]];

    // Consider changing this to "Fast Enumeration" for Objective-C 2.0 in
    // Mac OS X 10.5.
	while (ci = (ConnectionIdentifier *)[enumer nextObject])
	{
        ctcp = [_connections objectForKey:ci];
        if ([ctcp hasReceivedFIN]  ||
            -[[ctcp lastUpdate] timeIntervalSinceNow] > TAConnectionTimeout)
        {
            [removeList addObject:ci];
            
            [ctcp willDiscard];
        }
        /* else
        {
            NSLog(@"keeping a connection last modified %@, %f sec ago sir",
                [ctcp lastUpdate], -[[ctcp lastUpdate] timeIntervalSinceNow]);
        }*/
    }
    
    [_connections removeObjectsForKeys:removeList];
    
    /* http://developer.apple.com/documentation/Cocoa/Conceptual/Collections/Articles/Enumerators.html
       It is not safe to remove, replace, or add to a mutable collection’s
       elements while enumerating through it. If you need to modify a
       collection during enumeration, you can either: make a copy of the
       collection and enumerate using the copy; or, collect the information
       you require during the enumeration and apply the changes afterwards.
    */
}

- (void)periodicSweep:(NSTimer*)theTimer
{
    [self sweepConnections];
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
        [ctcp writeBlocksToFile:@"/Users/ivan/pcapsandbox/blockdata"];
    }
    
    return report;
}

@end
