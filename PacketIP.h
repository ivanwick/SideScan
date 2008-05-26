//
//  PacketIP.h
//  PcapSandbox
//
//  Created by Ivan Wick on 5/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PacketDatalink.h"
#import "PcapPacket.h"
#import <netinet/in.h>
#import <netinet/ip.h>

typedef enum
{
    IPProtoICMP   = IPPROTO_ICMP,
    IPProtoIGMP   = IPPROTO_IGMP,
    IPProtoTCP    = IPPROTO_TCP,
    IPProtoUDP    = IPPROTO_UDP,
    IPProtoIP     = IPPROTO_IP,

    /* I think some of these IPv6 constants overlap with the IPv4 ones, maybe
       there should be a separate class for IPv6 */
    IPProtoIPv6   = IPPROTO_IPV6,
    IPProtoIPv6Frag = IPPROTO_FRAGMENT, /* fragment header for IPv6 */
    IPProtoIPv6ICMP = IPPROTO_ICMPV6,   /* ICMP6 */
    IPProtoIPv6NoNext = IPPROTO_NONE,   /* IP6 no next header */
    IPProtoIPv6DestOpt = IPPROTO_DSTOPTS,  /* IP6 destination option */
    IPProtoIPv6Routing = IPPROTO_ROUTING /* IP6 routing header */
} PacketIPProto;


@interface PacketIP : PcapPacket {
    void * ipHeadPtr;
    void * ipDataPtr;
    id <PacketDatalink> datalink;
}

-(id) initWithPacketDatalink:(id <PacketDatalink>)pdl;
+ (id)packetWithPacketDatalink:(id <PacketDatalink>)pdl;

-(id <PacketDatalink>) packetDatalink;

-(struct in_addr)sourceIPAddress;
-(struct in_addr)destIPAddress;

- (void*)headerPointer;
- (void*)dataPointer;

@end
