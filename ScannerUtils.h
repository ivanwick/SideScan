/*
 *  ScannerUtils.h
 *  PcapSandbox
 *
 *  Created by Ivan Wick on 12/6/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdlib.h>

/* Darwin has no memmem implementation, this one is ripped from the
   uClibc-0.9.28 source */   
void *memmem (const void *haystack, size_t haystack_len,
              const void *needle, size_t needle_len);
