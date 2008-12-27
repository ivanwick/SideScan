//
//  SCNCNetIfList.h
//  EthInterface
//
//  Created by Ivan Wick on 12/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SCNetworkInterfaceList : NSObject {
    NSArray *_interfaceList;
}

-(NSArray*)list;
-(void)reloadList;
@end
