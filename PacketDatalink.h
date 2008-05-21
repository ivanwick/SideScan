//
//  PacketDatalink.h
//  PcapSandbox
//
//  Created by Ivan Wick on 5/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* THIS IS AN ABSTRACT CLASS */

@protocol PacketDatalink <NSObject>

- (void *)dataPointer;

@end
