//
//  ConnectionIdentifier.h
//  PcapSandbox
//
//  Created by Ivan Wick on 6/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//


/*  The reason this class is defined is because there might be different ways
    of determining the "identity" of a TCP connection.  For instance, in
    Driftnet, a "connection" only refers to a one-way data stream between hosts.
    Alternatively, a connection might need to be defined as the two-way data,
    which means the comparison would need to be done differently.
    
    But the ConnectionTCP class is defined in the Driftnet way, why should you
    allow for behavior that isn't even encoded by the Connection class?
*/

#import <Cocoa/Cocoa.h>
#import "ConnectionTCP.h"
#import "PacketTCP.h"

@interface ConnectionIdentifier : NSObject <NSCopying> {
    unsigned short _sport;
    unsigned short _dport;
    struct in_addr _saddr;
    struct in_addr _daddr;

}

+(id)identifierForConnection:(ConnectionTCP *)conn;
+(id)identifierForPacket:(PacketTCP *)pkt;

// these two are private and should only be called from the autorelease class
// initializers above.
-(id)initWithConnection:(ConnectionTCP *)conn;
-(id)initWithPacket:(PacketTCP *)pkt;
// used for NSCopying
-(id)initWithConnectionIdentifier:(ConnectionIdentifier *)ci;

- (unsigned short)sourcePort;
- (unsigned short)destPort;
- (struct in_addr)sourceIPAddr;
- (struct in_addr)destIPAddr;

- (NSString *)description;

/* YOU WANT TO USE THIS AS A DICTIONARY KEY?
   THEN YOU MUST OVERRIDE THESE METHODS THREE. */

// NSCopying Protocol, so that objects of this class can be used as
// Dictionary keys.
-(id)copyWithZone:(NSZone *)z;

// Just implemeting your own override for isEqual is not sufficient if you want
// to use objects of this class as dictionary keys. Since the dictionary uses
// hashing to store/lookup its keys, hash needs to be overridden here as well.
-(BOOL)isEqual:(id)other;
-(unsigned int)hash;     // please see comments about implementation in the .m

@end

#if 0
- (void)setSourcePort:(unsigned short)sp;
- (void)setDestPort:(unsigned short)dp;
- (void)setSourceIPAddr:(struct in_addr)sa;
- (void)setDestIPAddr:(struct in_addr)da;
#endif
