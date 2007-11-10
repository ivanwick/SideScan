//
//  PacketPipe.h
//  PcapSandbox
//
//  Created by Ivan Wick on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <pcap.h>




@interface PacketPipe : NSObject {

    pcap_t *pcapsess;
    char errbuf[PCAP_ERRBUF_SIZE];

}

- (id)init;
- (id)initWithFopenOffline:(FILE *)filePtr;

- (void)setPcapSession:(pcap_t *)aSess;
- (pcap_t *)pcapsess;

- (void)monitorInBackgroundAndNotify;

@end
