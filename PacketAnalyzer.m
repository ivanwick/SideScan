//
//  PacketAnalyzer.m
//  PcapSandbox
//
//  Created by Ivan Wick on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PacketAnalyzer.h"
#import <netinet/tcp.h>

@implementation PacketAnalyzer

- (id)init
{
	self = [super init];
	if (self)
	{
		connections = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (void)procPacketNotification:(NSNotification *)note
{
	NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:10];
	[(PacketStream*)[note object] getPacketsIntoArray:a];

	NSEnumerator *enumer = [a objectEnumerator];
	PcapPacket *pkt;
    PacketTCP *ptcp;
	
	while (pkt = (PcapPacket*)[enumer nextObject])
	{
        NSLog(@"pkt: %@", pkt);
        
        ptcp = [[PacketTCP alloc] initWithPacketIP:
                [PacketIP packetWithPacketDatalink:
                [PacketEthernet packetWithPcapPacket:pkt]]];
        
		NSLog(@"src: %d:%d\tdst: %d:%d",
            [ptcp sourceIPAddress], [ptcp sourcePort],
            [ptcp destIPAddress], [ptcp destPort]);
        
        [ptcp release];
	}

	[a release];
}

@end


#if 0
- (void)packetReceived:(NSNotification *)note
{
    NSData *packetData = (NSData *)[note object];
    
    /* analyze packet for TCP stream */
    /* is there an image there? */
    /* if so, send a notification. */
}
#endif