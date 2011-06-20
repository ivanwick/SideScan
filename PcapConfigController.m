//
//  PcapConfigController.m
//  PcapSandbox
//
//  Created by Ivan Wick on 12/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PcapConfigController.h"


@implementation PcapConfigController

const float VALIDATOR_INTERVAL = 0.5;

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if (validationTimer == nil)
    {
        validationTimer = [NSTimer scheduledTimerWithTimeInterval:VALIDATOR_INTERVAL
                            target:self
                            selector:@selector(validateFilterTimer:)
                            userInfo:nil
                            repeats:NO];
    }
    else
    {
        [validationTimer setFireDate:
            [[NSDate date] addTimeInterval:VALIDATOR_INTERVAL]];
    }
    [self setShouldDisplayStatus:NO];
}


- (void)validateFilterTimer:(NSTimer*)theTimer
{
    int result;
    struct bpf_program filtprog;

    if (theTimer == validationTimer)
    {   validationTimer = nil;
    }
    
    if (pcap_sess == NULL)
    {
        /* FIX: DLT_EN10MB is a value that works but probably shouldn't be
            hardcoded here.  This value is also similarly hardcoded in the
            PacketStream class. */
        pcap_sess = pcap_open_dead(DLT_EN10MB, -1);
    }

    result = pcap_compile(pcap_sess, &filtprog,
        (char *)[[filterTextField stringValue] UTF8String],
        TRUE,  /* optimize? */
        0); /* subnet mask */

    if (result == 0)
    {
        // NSLog(@"ya its valid good job");
        [self setFilterStatusString:@"ur filter expressions valid good job"];
        [self setIsFilterValid:YES];
    }
    else
    {
        // NSLog(@"no its not valid whats wrong with u %s", pcap_geterr(pcap_sess));
        [self setFilterStatusString:[NSString stringWithUTF8String:pcap_geterr(pcap_sess)]];
        [self setIsFilterValid:NO];
    }
    [self setShouldDisplayStatus:YES];
}

-(BOOL)shouldDisplayStatus            { return shouldDisplayStatus; }
-(void)setShouldDisplayStatus:(BOOL)b { shouldDisplayStatus = b; }

-(BOOL)isFilterValid                { return isFilterValid; }
-(void)setIsFilterValid:(BOOL)b     { isFilterValid = b; }

-(NSString *)filterStatusString         { return filterStatusString; }
-(void)setFilterStatusString:(NSString *)s
{
    if (filterStatusString != nil)
    {   [filterStatusString release];
    }
    
    filterStatusString = s;
    
    if (filterStatusString != nil)
    {   [filterStatusString retain];
    }
}

-(void)awakeFromNib
{
    [self validateFilterTimer:nil];
    [self setShouldDisplayStatus:YES];
}

-(void)dealloc
{
    if (pcap_sess != NULL)
    {   pcap_close(pcap_sess);
    }
    
    [super dealloc];
}

@end
