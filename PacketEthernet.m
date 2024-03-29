//
//  PacketEthernet.m
//  PcapSandbox
//
//  Created by Ivan Wick on 5/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PacketEthernet.h"

@implementation PacketEthernet



- (id)initWithPcapPacket:(PcapPacket *)pcp
{
    self = [super initByReferencingPcapPacket:pcp];
    if (self)
    {
        pcap = pcp;
        [pcap retain];
        ethHeadPtr = [pcap dataPointer];
        
        ethDataPtr = ethHeadPtr + sizeof(struct ether_header);
    }
    return self;
}

+ (id)packetWithPcapPacket:(PcapPacket*)pkt
{
    PacketEthernet* tempPkt;
    tempPkt = [[PacketEthernet alloc] initWithPcapPacket:pkt];
    if (tempPkt)
    {   [tempPkt autorelease];
    }
    return tempPkt;
}


-(void)dealloc
{
    [pcap release];
    [super dealloc];
}

-(PacketEthernetEtherType) etherType
{
	return ((struct ether_header*)ethHeadPtr)->ether_type;
}

- (const void *)headerPointer {   return ethHeadPtr;    }
- (const void *)dataPointer   {   return ethDataPtr;    }

- (PcapPacket *)pcapPacket  { return pcap;  }

- (unsigned int)dataLength
{
    /* FIX should this be caplen instead of len??? */
    return ([pcap header])->len - [pcap datalinkLength];
}

@end
