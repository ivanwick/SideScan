//
//  HTTPRequestScanner.m
//  PcapSandbox
//
//  Created by Ivan Wick on 11/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HTTPRequestScanner.h"
#import "ScannerUtils.h"

@implementation HTTPRequestScanner

- (void)lookForRequestInData:(NSData *)d
{
    char *b = (char *)[d bytes];
    char *s;
	char *h;
    NSMutableString *getfile = [[NSMutableString alloc] init];
	NSMutableString *host    = [[NSMutableString alloc] init];
    
    if (!memcmp("GET ", b, 4))
    {
        s = b+4;
        while (*s != '\n' && *s != '\r') { [getfile appendFormat:@"%c", *s]; s++; }

		h = SUmemmem(s+1, [d length] - (s-b), "Host: ", 6);
		
		if (h != NULL)
		{
			s = h+6;
			while (*s != '\n' && *s != '\r') { [host appendFormat:@"%c", *s]; s++; }
		}

		NSLog(@"a GET request sir for %@%@", host, getfile);
	}
	
	[getfile release];
	[host release];
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
    // NSLog(@"MAKE YOUR TIME");
}


@end
