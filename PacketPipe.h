//
//  PacketPipe.h
//  PcapSandbox
//
//  Created by Ivan Wick on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <pcap.h>


NSString * const PcapPacketReceived = @"PcapPacketReceived";


@interface PacketPipe : NSObject {

    pcap_t *pcapsess;

}


@end
