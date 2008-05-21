//
//  PacketAnalyzer.h
//  PcapSandbox
//
//  Created by Ivan Wick on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PacketStream.h"

#import "PacketEthernet.h"
#import "PacketTCP.h"

@interface PacketAnalyzer : NSObject {
	NSMutableDictionary *connections;
}

@end
