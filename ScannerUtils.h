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
   uClibc-0.9.28 source */  /* Taken from OpenWRT kallsyms.c */
void *SUmemmem (const void *haystack, size_t haystack_len,
              const void *needle, size_t needle_len);
/* Who knows if this could ever be compiled on a system with GNU libc
   but I changed the name of this to i.e. "ScannerUtils memmem" to avoid
   a name collision */
