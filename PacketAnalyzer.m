//
//  PacketAnalyzer.m
//  PcapSandbox
//
//  Created by Ivan Wick on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PacketAnalyzer.h"


@implementation PacketAnalyzer

- (void)packetReceived:(NSNotification *)note
{
    NSData *packetData = (NSData *)[note object];
    
    /* analyze packet for TCP stream */
    /* is there an image there? */
    /* if so, send a notification. */
}

@end
