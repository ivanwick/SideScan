//
//  PcapConfigController.h
//  PcapSandbox
//
//  Created by Ivan Wick on 12/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <pcap.h>


@interface PcapConfigController : NSObject {
    NSTimer *validationTimer;
    pcap_t *pcap_sess;

    BOOL isFilterValid;
    BOOL shouldDisplayStatus;
    NSString *filterStatusString;
    
    IBOutlet NSTextField *filterTextField;
}

-(BOOL)shouldDisplayStatus;
-(void)setShouldDisplayStatus:(BOOL)b;

-(BOOL)isFilterValid;
-(void)setIsFilterValid:(BOOL)b;

-(NSString*)filterStatusString;
-(void)setFilterStatusString:(NSString*)s;

@end
