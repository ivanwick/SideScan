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

NSString * const PcapPacketReceived = @"PcapMonitorPacketReceived";

@implementation PacketStream

/* this is a standard pcap callback for use by pcap_loop. */
void PacketPipe_packetrecv(u_char *userarg, const struct pcap_pkthdr *header,
                 const u_char *data)
{
	NSLog(@"capped %d bytes", header->len);
	
	PacketStream *self = (PacketStream*)userarg;
	PcapPacket * pkt = [[PcapPacket alloc] initWithHeader:header
										   data:data];

	[[self bufferLock] lock];
	/* add the packet data to buffer queue */	
	[[self packetBuf] addObject:pkt];
	[pkt release];
	
	[[self bufferLock] unlock];
	
	NSNotification * note = [NSNotification notificationWithName:@"packet"
								object:self];
	
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
    }
    
    return self;
}

- (id)initWithFopenOffline:(FILE *)filePtr
{
    self = [self init];
    if (self)
    {
    NSLog(@"%s", pcap_lib_version());
        pcapsess = pcap_fopen_offline(filePtr, errbuf);
	NSLog(@"running");
        // pcapsess = pcap_open_offline(errbuf, errbuf);
        if (pcapsess == NULL)
        {
			NSLog(@"Can't open pcap session.");
            // throw an exception with errbuf??
            [self release];
            return nil;
        }
		
		packetBuf = [[NSMutableArray alloc] initWithCapacity:1000];
												/* 1000? who knows?*/
		bufferLock = [[NSLock alloc] init];
    }

    // any reason to save filePtr?    

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
{
    pcapsess = aSess;
}
- (pcap_t *)pcapsess
{
    return pcapsess;
}

- (NSLock *)bufferLock
{	return bufferLock;
}
- (NSMutableArray *)packetBuf
{	return packetBuf;
}

@end