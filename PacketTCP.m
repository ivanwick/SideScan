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
    self = [super initWithPacketDatalink:[pip packetDatalink]];
    if (self)
    {
        ip = pip;
        [ip retain];
        
        tcpHeadPtr = [ip dataPointer];
        tcpDataPtr = tcpHeadPtr + [self tcpDataByteOffset]; // sizeof(struct tcphdr);
        _tcpDataLength = [ip dataLength] - [self tcpDataByteOffset];
    }
    return self;
}

+ (id)packetWithPacketIP:(PacketIP*)pip
{
    PacketTCP *tempPkt;
    tempPkt = [[PacketTCP alloc] initWithPacketIP:pip];
    if (tempPkt)
    {   [tempPkt autorelease];
    }
    return tempPkt;
}

-(void)dealloc
{
    [ip release];
    [super dealloc];
}


- (void*)headerPointer  {   return tcpHeadPtr;  }
- (void*)dataPointer    {   return tcpDataPtr;  }
- (unsigned int)dataLength {return _tcpDataLength; }


-(unsigned short)sourcePort
{	return ntohs(
	((struct tcphdr*)tcpHeadPtr)->th_sport);
}

-(unsigned short)destPort
{	return ntohs(
	((struct tcphdr*)tcpHeadPtr)->th_dport);
}


-(unsigned int)seqNum;
{	return ntohl(((struct tcphdr*)tcpHeadPtr)->th_seq);
}
-(unsigned int)ackNum;
{	return ntohl(((struct tcphdr*)tcpHeadPtr)->th_ack);
}

-(unsigned int)tcpDataByteOffset;
{	return ((struct tcphdr*)tcpHeadPtr)->th_off * 4;
    // multiply by 4 is sizeof(int) because th_off is in units of
    // 32-bit words.
}

-(struct tcphdr*)tcpHeader;
{	return (struct tcphdr*)tcpHeadPtr;
}

-(BOOL)finFlag
{   return (((struct tcphdr*)tcpHeadPtr)->th_flags) & TH_FIN;
}
@end
