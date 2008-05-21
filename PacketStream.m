//
//  PacketPipe.m
//  PcapSandbox
//
//  Created by Ivan Wick on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//


/*
Will probably have to do something like this in order to bundle a copy of
libpcap that has pcap_fopen_offline in it.
http://0xced.blogspot.com/2006/07/dealing-with-outdated-open-source-libs.html
*/

#import "PacketStream.h"

#import <net/ethernet.h>
#import <netinet/tcp.h>
#import <netinet/ip.h>

NSString * const PcapPacketReceived = @"PcapMonitorPacketReceived";

@implementation PacketStream



void packet_analyze(const struct pcap_pkthdr *header, const u_char *data)
{
	struct ether_header* eth = (struct ether_header *)data;
	struct ip* iph = (struct ip *)((char*)eth + sizeof(struct ether_header));	
	struct tcphdr* tcph = (struct tcphdr *)((char*)iph + sizeof(struct ip));
	
	NSLog(@"ether_shost: %s",
		ether_ntoa((struct ether_addr*)eth->ether_shost));
	NSLog(@"ether_dhost: %s",
		ether_ntoa((struct ether_addr*)eth->ether_dhost));
			
	NSLog(@"tcp srcport: %d", ntohs(tcph->th_sport));
	NSLog(@"tcp destport: %d", ntohs(tcph->th_dport));

}



/* this is a standard pcap callback for use by pcap_loop. */
void PacketPipe_packetrecv(u_char *userarg, const struct pcap_pkthdr *header,
                 const u_char *data)
{
	/* NSLog(@"capped %d bytes", header->len); */
	
	PacketStream *self = (PacketStream*)userarg;
	PcapPacket * pkt = [[PcapPacket alloc] initWithHeader:header
										   data:data
										   datalinkLength:[self datalinkLength]
										   ];

	[[self bufferLock] lock];
	/* add the packet data to buffer queue */	
	[[self packetBuf] addObject:pkt];
	[pkt release];
	
	[[self bufferLock] unlock];
	
	NSNotification * note = [NSNotification notificationWithName:@"packet"
								object:self];
	
	/* packet_analyze(header, data); */
	
	[[NSNotificationCenter defaultCenter]
		performSelectorOnMainThread:@selector(postNotification:)
		withObject:note
		waitUntilDone:NO];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        pcapsess = NULL;
		packetBuf = [[NSMutableArray alloc] initWithCapacity:1000];
												/* 1000? who knows?*/
		bufferLock = [[NSLock alloc] init];
    }
    
    return self;
}

- (id)initWithFilePtr:(FILE *)fparam
{
    self = [self init];
    if (self)
    {
		filePtr = fparam;
    }
    return self;
}

- (void)dealloc
{
	[bufferLock release];
	[packetBuf release];
	[super dealloc];
}

- (void)monitorInBackgroundAndNotify
{
	NSLog(@"main thread: self: %@", self);
    [NSThread detachNewThreadSelector:@selector (startPcapLoopForeverArg:)
        toTarget:self
        withObject:nil];
}

- (void)startPcapLoopForeverArg:(id)anArg
{
    int result;
    NSAutoreleasePool *pool;

	pcapsess = pcap_fopen_offline(filePtr, errbuf);
	if (pcapsess == NULL)
	{	NSLog(@"Can't open pcap session.");
		// throw an exception with errbuf??
		return;
	}
	
	datalinkLength = [self pcap_datalinkLength];
	NSLog(@"PacketStream datalinkLength: %d", datalinkLength);

    while (YES)
    {
        pool = [[NSAutoreleasePool alloc] init];

        /* Want to return after every 20 packets in order to have a chance to
           destroy and create a new Autorelease Pool.  */

        /* FIX is 20 a good number for this? */
        result = pcap_loop(pcapsess, 20,
                    PacketPipe_packetrecv, (void*)self );

    /* -1 is returned on an error; 0 is
       returned if cnt is exhausted; -2 is returned if the loop terminated due
       to  a  call  to pcap_breakloop() before any packets were processed.
    */
        NSLog(@"[pool release]");
        [pool release];
    }
}


- (PcapPacket *)getNextPacket
{
	
	/* get a temporary copy of the first available packet in the queue */

	PcapPacket * retPkt;
	[bufferLock lock];

	retPkt = [[packetBuf objectAtIndex:0] retain];
	[packetBuf removeObjectAtIndex:0];
	
	[bufferLock unlock];

	return [retPkt autorelease];  /* this should be the main thread's
									 autorelease pool or whatever, the
									 calling thread's pool.*/
}

- (int)getPacketsIntoArray:(NSMutableArray *)pktArray   /* NSInteger in 10.5?? */
{
	int count;
	
	[bufferLock lock];
	/* put the available packets into buf */
	[pktArray addObjectsFromArray:packetBuf];
	
	count = [packetBuf count];
	[packetBuf removeAllObjects];
	
	[bufferLock unlock];
	
	return count;
}

- (void)setPcapSession:(pcap_t *)aSess
{	pcapsess = aSess;
}
- (pcap_t *)pcapsess
{	return pcapsess;
}

- (unsigned int)datalinkLength
{	return datalinkLength;
}

/* the following function was originally copied from driftnet
   but I pared it down to a more restricted subset.
   for one thing, I only anticipate this code ever running on anything
   other than mac os x, so many of the specialized devices for datalinks could
   be removed.
*/
/* get_link_level_hdr_length:
 * Find out how long the link-level header is, based on the datalink layer
 * type. This is based on init_linktype in the libpcap distribution; I
 * don't know why libpcap doesn't expose the information directly. The
 * constants here are taken from 0.6.2, but I've added #ifdefs in the hope
 * that it will still compile with earlier versions. */
//int get_link_level_hdr_length(int type)
- (unsigned int)pcap_datalinkLength
{
	unsigned int type = pcap_datalink(pcapsess);
    switch (type) {
        case DLT_EN10MB:
            return 14;

        case DLT_SLIP:
            return 16;

        case DLT_SLIP_BSDOS:
            return 24;

        case DLT_NULL:
        case DLT_LOOP:
            return 4;

        case DLT_PPP:
        case DLT_PPP_SERIAL:
            return 4;

        case DLT_PPP_BSDOS:
            return 24;

        case DLT_FDDI:
            return 21;

		case DLT_IEEE802_11:
        case DLT_IEEE802:
            return 22;

        case DLT_ATM_RFC1483:
            return 8;

        case DLT_RAW:
            return 0;

        default:
			return 0;
		}
}




- (NSLock *)bufferLock
{	return bufferLock;
}
- (NSMutableArray *)packetBuf
{	return packetBuf;
}

@end