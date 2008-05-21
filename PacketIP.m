//
//  PacketIP.m
//  PcapSandbox
//
//  Created by Ivan Wick on 5/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PacketIP.h"


@implementation PacketIP

-(id) initWithPacketDatalink:(id <PacketDatalink>)pdl
{
    self = [super initByReferencingPcapPacket:[pdl pcapPacket]];
    if (self)
    {
        datalink = pdl;
        [datalink retain];
        ipHeadPtr = [datalink dataPointer];
        ipDataPtr = ipHeadPtr + sizeof(struct ip);
    }
    
    return self;
}

- (void)dealloc
{
    [datalink release];
    [super dealloc];
}

-(id <PacketDatalink>) packetDatalink
{   return datalink;    }


- (void*)headerPointer  {   return ipHeadPtr;   }
- (void*)dataPointer    {   return ipDataPtr;   }

-(struct in_addr)sourceIPAddress
{   return ((struct ip*)ipHeadPtr)->ip_src;
}

-(struct in_addr)destIPAddress;
{   return ((struct ip*)ipHeadPtr)->ip_dst;
}
@end
