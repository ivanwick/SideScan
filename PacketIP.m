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
        ipDataPtr = ipHeadPtr + [self ipDataByteOffset]; //sizeof(struct ip);
    
        /* sometimes ethernet frames are padded so we should take the length
           from the IP header, NOT by computing it from the entire packet */
        _ipDataLength = ((struct ip*)ipHeadPtr)->ip_len /* this incl header */
                         - [self ipDataByteOffset];  /* so subt header len */
    }
    
    return self;
}

+ (id)packetWithPacketDatalink:(id <PacketDatalink>)pdl
{
    PacketIP * tempPkt;
    tempPkt = [[PacketIP alloc] initWithPacketDatalink:pdl];
    if (tempPkt)
    {   [tempPkt autorelease];
    }
    return tempPkt;
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
- (unsigned int)dataLength {return _ipDataLength; }

-(struct in_addr)sourceIPAddr   {   return ((struct ip*)ipHeadPtr)->ip_src; }
-(struct in_addr)destIPAddr     {   return ((struct ip*)ipHeadPtr)->ip_dst; }

-(NSHost *)sourceHost
{   return [NSHost hostWithAddress:
                [NSString stringWithCString:
                    inet_ntoa(((struct ip*)ipHeadPtr)->ip_src)]];
}

-(NSHost *)destHost;
{   return [NSHost hostWithAddress:
                [NSString stringWithCString:
                    inet_ntoa(((struct ip*)ipHeadPtr)->ip_dst)]];
}

-(unsigned int) ipDataByteOffset
{
    return ((struct ip*)ipHeadPtr)->ip_hl * 4;
        // multiply by 4 is because header length is in units of 32-bit words.
}


@end
