//
//  PcapTCPPacket.h
//  PcapSandbox
//
//  Created by Ivan Wick on 5/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PcapPacket.h"
#import "PacketIP.h"
#import <netinet/tcp.h>

@interface PacketTCP : PacketIP {
    void * tcpHeadPtr;
    void * tcpDataPtr;
    PacketIP *ip;
}

-(id)initWithPacketIP:(PacketIP *)pip;
+(id)packetWithPacketIP:(PacketIP *)pip;

- (void*)headerPointer;
- (void*)dataPointer;

-(unsigned short)sourcePort;
-(unsigned short)destPort;

-(unsigned short)seqNum;
-(unsigned short)ackNum;

-(unsigned short)dataOffset;

-(struct tcphdr*)tcpHeader;

@end
