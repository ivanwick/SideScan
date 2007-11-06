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
void PacketPipe_packetrecv(u_char *userarg, const struct pcap_pkthdr *header,
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

- (id)init
{
    self = [super init];
    if (self)
    {
        pcapsess = NULL;
    }
    
    return self;
}

- (id)initWithFopenOffline:(FILE *)filePtr
{
    self = [self init];
    if (self)
    {
        pcapsess = pcap_fopen_offline(filePtr, errbuf);
        if (pcapsess == NULL)
        {
            // throw an exception with errbuf??
            [self release];
            return nil;
        }
    }

    // any reason to save filePtr?    

    return self;
}


- (void)monitorInBackgroundAndNotify
{
    [NSThread detachNewThreadSelector:@selector (startPcapLoopForeverArg:)
        toTarget:self
        withObject:nil];
}

- (void)startPcapLoopForeverArg:(id)anArg
{
    int result;
    NSAutoreleasePool *pool;

    while (YES)
    {
        pool = [[NSAutoreleasePool alloc] init];

        /* Want to return after every 20 packets in order to have a chance to
           destroy and create a new Autorelease Pool.  */

        /* FIX is 20 a good number for this? */
        result = pcap_loop(pcapsess, 20,
                    PacketPipe_packetrecv, NULL);

    /* -1 is returned on an error; 0 is
       returned if cnt is exhausted; -2 is returned if the loop terminated due
       to  a  call  to pcap_breakloop() before any packets were processed.
    */

        [pool release];
    }
}


- (void)setPcapSession:(pcap_t *)aSess
{
    pcapsess = aSess;
}
- (pcap_t *)pcapsess
{
    return pcapsess;
}


@end
