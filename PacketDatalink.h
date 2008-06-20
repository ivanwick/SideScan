//
//  PacketDatalink.h
//  PcapSandbox
//
//  Created by Ivan Wick on 5/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PcapPacket.h"

/* Abstract class? Interface/Protocol?? */

@protocol PacketDatalink <NSObject>

- (void *)dataPointer;
- (PcapPacket *)pcapPacket;
- (unsigned int)dataLength;

@end
