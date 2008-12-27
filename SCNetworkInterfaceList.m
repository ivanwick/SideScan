//
//  SCNCNetIfList.m
//  EthInterface
//
//  Created by Ivan Wick on 12/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SCNetworkInterfaceList.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation SCNetworkInterfaceList

/* TOLL FREE BRIDGING YAY */
+ (NSArray *) getListFromSC
{
    NSArray* a = (NSArray*)SCNetworkInterfaceCopyAll();
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[a count]];
    SCNetworkInterfaceRef scnir;
    
    NSString *dev, *name;
    
    NSEnumerator *e = [a objectEnumerator];
    
    while (scnir = (SCNetworkInterfaceRef)[e nextObject])
    {
        if (scnir == nil) { continue; }
        
        dev = (NSString*)SCNetworkInterfaceGetBSDName(scnir);
        name = (NSString*)SCNetworkInterfaceGetLocalizedDisplayName(scnir);
        
        [result addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                dev, @"DeviceName",
                                name, @"DisplayName",
                                nil]];
                                
    }
    CFRelease(a);

    return result;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self reloadList];
        if (_interfaceList == nil)
        {   self = nil;
        }
    }
    return self;
}

-(void)dealloc
{
    [_interfaceList release];
    [super dealloc];
}

-(void)reloadList;
{
    if (_interfaceList != nil) { [_interfaceList release]; }
    _interfaceList = [SCNetworkInterfaceList getListFromSC];
}

-(NSArray *)list
{   return _interfaceList;
}


@end

