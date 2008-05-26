//
//  PcapPacket.m
//  PcapSandbox
//
//  Created by Ivan Wick on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PcapPacket.h"

@implementation PcapPacket

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
        pktHeader = NULL;
        pktData = NULL;
		datalinkLength = 0;
        refPacket = nil;

    }
    return self;
}

- (id)initWithHeader: (const struct pcap_pkthdr *)aHeader
    data:(const u_char *)someData
{
    self = [self init];  /* note this is NOT a [SUPER init] */
    if (self)
    {
        pktHeader = malloc(sizeof(struct pcap_pkthdr));
        if (pktHeader == NULL)
        {
            [self release];
            return nil;
        }
        *pktHeader = *aHeader;
        /* this copies the whole structure */
        
        pktData = malloc(aHeader->len);
        if (pktData == NULL)
        {
            [self release];
            return nil;
        }
        memcpy(pktData, someData, aHeader->len);
    }
    return self;
}

- (id)initByReferencingPcapPacket:(PcapPacket*)pkt
{
    self = [self init];
    if (self)
    {
        refPacket = pkt;
        [pkt retain];
        pktHeader = [pkt header];
        pktData = [pkt dataPointer];
    }
    return self;
}

+ (id)packetByReferencingPcapPacket:(PcapPacket*)pkt
{
    PcapPacket* tempPkt;
    tempPkt = [[PcapPacket alloc] initByReferencingPcapPacket:pkt];
    if (tempPkt)
    {   [tempPkt autorelease];
    }
    return tempPkt;
}
    
- (id)initWithHeader: (const struct pcap_pkthdr *)aHeader
    data:(const u_char *)someData datalinkLength:(unsigned int)dll
{
	self = [self initWithHeader:aHeader data:someData];
	if (self)
	{
		[self setDatalinkLength:dll];
	}
	return self;
}

- (void)dealloc
{
    NSLog(@"[PcapPacket dealloc] %@", self);
    if (refPacket)
    {
        [refPacket release];
    }
    else
    {
        if (pktHeader) { free(pktHeader); }
        if (pktData)   { free(pktData);   }
    }
    [super dealloc];
}

- (NSData *)data
{
    return [NSData dataWithBytes:pktData length:pktHeader->len];
}

- (const void *)dataPointer
{
    return pktData;
}

- (struct pcap_pkthdr *)header
{
    return pktHeader;
}
- (void) setDatalinkLength:(unsigned int)dll;
{	datalinkLength = dll;
}

- (unsigned int)datalinkLength
{	return datalinkLength;
}


@end
