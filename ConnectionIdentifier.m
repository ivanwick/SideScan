//
//  ConnectionIdentifier.m
//  PcapSandbox
//
//  Created by Ivan Wick on 6/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ConnectionIdentifier.h"


@implementation ConnectionIdentifier

-(id)initWithConnection:(ConnectionTCP *)conn
{
    self = [super init];
    if (self)
    {
        _sport = [conn sourcePort];
        _dport = [conn destPort];
        _saddr = [conn sourceIPAddr];
        _daddr = [conn destIPAddr];
    }
    return self;
}

-(id)initWithPacket:(PacketTCP *)pkt
{
    self = [super init];
    if (self)
    {
        _sport = [pkt sourcePort];
        _dport = [pkt destPort];
        _saddr = [pkt sourceIPAddr];
        _daddr = [pkt destIPAddr];
    }
    return self;
}

-(id)initWithConnectionIdentifier:(ConnectionIdentifier *)ci
{
    _sport = [ci sourcePort];
    _saddr = [ci sourceIPAddr];
    _dport = [ci destPort];
    _daddr = [ci destIPAddr];
    
    return self;
}

+(id)identifierForConnection:(ConnectionTCP *)conn
{
    ConnectionIdentifier *connid = [[ConnectionIdentifier alloc]
                                    initWithConnection:conn];

    return [connid autorelease];
}

+(id)identifierForPacket:(PacketTCP *)pkt
{
    ConnectionIdentifier *connid = [[ConnectionIdentifier alloc]
                                    initWithPacket:pkt];
    return [connid autorelease];
}


-(id)copyWithZone:(NSZone *)zone
{
    ConnectionIdentifier * cicopy = [[[self class] allocWithZone:zone]
                                        initWithConnectionIdentifier:self];
    return cicopy;
}


-(BOOL)isEqual:(id)other
{
    if (other == nil)   {   return NO;  }
    if ([other isKindOfClass:[self class]])
    {
        return ([self sourcePort] == [other sourcePort]
            &&  [self destPort]   == [other destPort]
            &&  [self sourceIPAddr].s_addr == [other sourceIPAddr].s_addr
            &&  [self destIPAddr].s_addr == [other destIPAddr].s_addr );
    }
    
    // by default:
    return NO;
}

/* well, is this a good way to override the hash method? */
-(unsigned int)hash
{   return [[self description] hash];
}


- (unsigned short)sourcePort  {   return _sport;  }
- (unsigned short)destPort    {   return _dport;  }
- (struct in_addr)sourceIPAddr{   return _saddr;  }
- (struct in_addr)destIPAddr  {   return _daddr;  }

- (NSString *)description
{
    return [NSString stringWithFormat:@"%x:%d -> %x:%d",
                _saddr, _sport, _daddr, _dport];
}

@end



#if 0
/*
    ConnectionIdentifier *copy = [[[self class] allocWithZone: zone] init];
    [copy setSourcePort:_sport];
    [copy setSourceIPAddr:_saddr];
    [copy setDestPort:_dport];
    [copy setDestIPAddr:_daddr];
*/

- (void)setSourcePort:(unsigned short)sp    {   _sport = sp; }
- (void)setDestPort:(unsigned short)dp      {   _dport = dp; }
- (void)setSourceIPAddr:(struct in_addr)sa  {   _saddr = sa; }
- (void)setDestIPAddr:(struct in_addr)da    {   _daddr = da; }
#endif
