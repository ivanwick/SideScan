/*
 *  ScannerUtils.c
 *  PcapSandbox
 *
 *  Created by Ivan Wick on 12/6/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "ScannerUtils.h"
#include <string.h>

/* Darwin has no memmem implementation, this one is ripped from the
   uClibc-0.9.28 source */  /* Taken from OpenWRT kallsyms.c */
/* Who knows if this could ever be compiled on a system with GNU libc
   but I changed the name of this to i.e. "ScannerUtils memmem" to avoid
   a name collision */
void *SUmemmem (const void *haystack, size_t haystack_len, const void *needle,  size_t needle_len)
{
  const char *begin;
  const char *const last_possible
    = (const char *) haystack + haystack_len - needle_len;

  if (needle_len == 0)
    /* The first occurrence of the empty string is deemed to occur at
       the beginning of the string.  */
    return (void *) haystack;

  /* Sanity check, otherwise the loop might search through the whole
     memory.  */
  if (__builtin_expect (haystack_len < needle_len, 0))
    return NULL;

  for (begin = (const char *) haystack; begin <= last_possible; ++begin)
    if (begin[0] == ((const char *) needle)[0] &&
        !memcmp ((const void *) &begin[1],
                 (const void *) ((const char *) needle + 1),
                 needle_len - 1))
      return (void *) begin;

  return NULL;
}
