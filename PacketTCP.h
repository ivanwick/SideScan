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
    unsigned int _tcpDataLength;
    PacketIP *ip;
}

-(id)initWithPacketIP:(PacketIP *)pip;
+(id)packetWithPacketIP:(PacketIP *)pip;

- (void*)headerPointer;
- (void*)dataPointer;
- (unsigned int)dataLength;

-(unsigned short)sourcePort;
-(unsigned short)destPort;

-(unsigned int)seqNum;
-(unsigned int)ackNum;

-(unsigned int)tcpDataByteOffset;

-(struct tcphdr*)tcpHeader;
-(BOOL)finFlag;

@end
