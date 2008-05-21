//
//  PacketEthernet.h
//  PcapSandbox
//
//  Created by Ivan Wick on 5/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PcapPacket.h"
#import "PacketDatalink.h"

#import <net/ethernet.h>

/* taken from net/ethernet.h */
/* here's a nice Cocoa-y typedef'ed enum with hell of long identifiers. */
typedef enum
{	EtherTypePUP     = ETHERTYPE_PUP,
	EtherTypeIP      = ETHERTYPE_IP,
	EtherTypeARP     = ETHERTYPE_ARP,
	EtherTypeRevARP  = ETHERTYPE_REVARP,
	EtherTypeVLAN    = ETHERTYPE_VLAN,
	EtherTypeIPv6    = ETHERTYPE_IPV6,
	EtherTypeLoopback= ETHERTYPE_LOOPBACK
} PacketEthernetEtherType;

@interface PacketEthernet : PcapPacket <PacketDatalink> {
    const void *ethHeadPtr;
	const void *ethDataPtr;

    PcapPacket *pcap;
}


- (id)initWithPcapPacket:(PcapPacket *)pcp;


/*	I don't know what type these should return but I am not using
    them right now anyway  */
/*
(void *)sourceMAC;
(void *)destMAC;
*/

- (PcapPacket *)pcapPacket;

- (PacketEthernetEtherType)etherType;
- (void *)headerPointer;
- (void *)dataPointer;

@end
