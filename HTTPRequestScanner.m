//
//  HTTPRequestScanner.m
//  PcapSandbox
//
//  Created by Ivan Wick on 11/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HTTPRequestScanner.h"


@implementation HTTPRequestScanner

- (void)lookForRequestInData:(NSData *)d
{
    char *b = (char *)[d bytes];
    char *s;
    NSMutableString *getfile = [[NSMutableString alloc] init];
    
    if (!memcmp("GET ", b, 4))
    {
        s = b+4;
        while (*s != '\n') { [getfile appendFormat:@"%c", *s]; s++; }

        NSLog(@"a GET request sir for %@", getfile);
    }
}


- (void)registerAsObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(receivedCombinedBlocksNotification:)
		name:CTDidCombineBlockRanges
        object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(receivedAddedBlockNotification:)
		name:CTDidAddNewBlockRange
        object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(receivedWillDiscardNotification:)
		name:CTWillBeDiscarded
        object:nil];
}


- (void)receivedCombinedBlocksNotification:(NSNotification *)note
{
    NSDictionary *uinfo = [note userInfo];
    DataBlock *extblock;
    extblock = [uinfo objectForKey:@"extendedBlock"];
    
    //[self lookForRequestInData:[extblock data]];
}


- (void)receivedAddedBlockNotification:(NSNotification *)note
{
    NSDictionary *uinfo = [note userInfo];
    DataBlock *newblock = [uinfo objectForKey:@"newBlock"];
    
    [self lookForRequestInData:[newblock data]];
}


- (void)receivedWillDiscardNotification:(NSNotification *)note
{
    NSLog(@"MAKE YOUR TIME");
}


@end
