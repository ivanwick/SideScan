//
//  TrafficAnalyzer.h
//  PcapSandbox
//
//  Created by Ivan Wick on 6/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PacketStream.h"
#import "PcapPacket.h"
#import "PacketTCP.h"
#import "PacketIP.h"
#import "PacketEthernet.h"

@interface TrafficAnalyzer : NSObject {

    NSMutableArray * _pktBuf;
    NSMutableDictionary * _connections;
}

/* Notifications */
NSString * const TADidCombineBlockRanges;   // = @"TADidCombineBlockRanges";
NSString * const TADidAddNewBlockRange;     // = @"TADidAddNewBlockRange";
NSString * const TAWillDeleteConnection;    // = @"TAWillDeleteConnection";

-(void)receivedPacketNotification:(NSNotification *)note;

-(void)sweepConnections;

-(NSString *)connectionStatus;

@end
