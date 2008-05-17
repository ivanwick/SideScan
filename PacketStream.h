//
//  PacketPipe.h
//  PcapSandbox
//
//  Created by Ivan Wick on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <pcap.h>
#import "PcapPacket.h"



@interface PacketStream : NSObject {

    pcap_t *pcapsess;
    char errbuf[PCAP_ERRBUF_SIZE];
	
	NSMutableArray *packetBuf;

	NSLock *bufferLock;
}

- (id)init;
- (id)initWithFopenOffline:(FILE *)filePtr;

- (void)dealloc;

- (void)monitorInBackgroundAndNotify;

- (PcapPacket *)getNextPacket;
- (int)getPacketsIntoArray:(NSMutableArray *)pktArray;   /* NSInteger in 10.5?? */

- (void)setPcapSession:(pcap_t *)aSess;
- (pcap_t *)pcapsess;

/* these are only used by the pcap callback and is not part of the public
   interface of this class */
- (NSLock *) bufferLock;
- (NSMutableArray *)packetBuf;

@end
