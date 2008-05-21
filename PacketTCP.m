//
//  PcapTCPPacket.m
//  PcapSandbox
//
//  Created by Ivan Wick on 5/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PacketTCP.h"

@implementation PacketTCP

-(id)initWithPacketIP:(PacketIP *)pip
{
    self = [super init];
    if (self)
    {
        ip = pip;
        [ip retain];
        
        tcpHeadPtr = [ip dataPointer];
        tcpDataPtr = tcpHeadPtr + sizeof(struct tcphdr);
    }
    return self;
}

-(void)dealloc
{
    [ip release];
    [super dealloc];
}


- (void*)headerPointer  {   return tcpHeadPtr;  }
- (void*)dataPointer    {   return tcpDataPtr;  }



-(unsigned short)sourcePort
{	return ntohs(
	((struct tcphdr*)tcpHeadPtr)->th_sport);
}

-(unsigned short)destPort
{	return ntohs(
	((struct tcphdr*)tcpHeadPtr)->th_dport);
}


-(unsigned short)seqNum;
{	return ntohs(((struct tcphdr*)tcpHeadPtr)->th_seq);
}
-(unsigned short)ackNum;
{	return ntohs(((struct tcphdr*)tcpHeadPtr)->th_ack);
}

-(unsigned short)dataOffset;
{	return ntohs(((struct tcphdr*)tcpHeadPtr)->th_off);
}

-(struct tcphdr*)tcpHeader;
{	return (struct tcphdr*)tcpHeadPtr;
}

@end
