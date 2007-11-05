//
//  PacketPipe.m
//  PcapSandbox
//
//  Created by Ivan Wick on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PacketPipe.h"
#import "PcapPacket.h"

@implementation PacketPipe

/* this is a standard pcap callback for use by pcap_loop. */
void packet_recv(u_char *userarg, const struct pcap_pkthdr *header,
                 const u_char *data)
{
    /* Encapsulate the packet into an object so that it can be attached to
       an NSNotification, */
    PcapPacket *pack = [[PcapPacket alloc] initWithHeader:header data:data];

    /* Pass the packet object up to the notification center/queue */
    NSNotification *sendNote =
        [NSNotification notificationWithName:PcapPacketReceived object:pack];

    [[NSNotificationQueue defaultQueue]
        enqueueNotification:sendNote
        postingStyle:NSPostWhenIdle
        coalesceMask:NSNotificationCoalescingOnName
        forModes:nil];

    [sendNote release];
    [pack release];
}



@end
