//
//  PcapPacket.h
//  PcapSandbox
//
//  Created by Ivan Wick on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <pcap.h>

@interface PcapPacket : NSObject {

    /* Consider making an Obj-C class for pkthdr instead of just using struct */
    struct pcap_pkthdr *pktHeader;
    u_char *pktData;
    /* Consider changing the internal representation to an NSData. */
	
	unsigned int datalinkLength;
}

- (struct pcap_pkthdr *) header;
/*
-(id)initWithPacketIP(PacketIP *)pip;
*/

/* is this one really necessary? cause you can just use [[[self] data] bytes] */
- (const void *) dataPointer;

- (void) setDatalinkLength:(unsigned int)dll;
- (unsigned int) datalinkLength;

- (id)initWithHeader: (const struct pcap_pkthdr *)header
    data:(const u_char *)data;
- (id)initWithHeader: (const struct pcap_pkthdr *)header
    data:(const u_char *)data datalinkLength:(unsigned int)dll;

@end
