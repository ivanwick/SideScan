//
//  GIFScan.m
//  PcapSandbox
//
//  Created by Ivan Wick on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GIFScan.h"
#import "ScannerUtils.h"
#import "GIFScanner.h"

@implementation GIFScan

const char         *GIF_HEADERS[] = { "GIF89a", "GIF87a" };
const unsigned int  GIF_HEADER_LENGTH = 6;
const unsigned int  GIF_HEADERS_COUNT = 2;

const unsigned int  IMAGEDESC_PACKEDBYTE_OFFSET = 9;
const unsigned int  IMAGEDESC_LENGTH = 10;
const unsigned int  LSD_PACKEDBYTE_OFFSET = 4;
const unsigned int  LSD_PIXELASPECT_RATIO_OFFSET = 6;
const unsigned int  LSD_LENGTH = 7;

void * searchGIFHeaders(const void *haystack, size_t haystack_len)
{
    int i;
    void *hdr, *hdrsearch[GIF_HEADERS_COUNT];    
    
    for (i = 0; i < GIF_HEADERS_COUNT; i++)
    {
        hdrsearch[i] = SUmemmem(haystack, haystack_len,
                                GIF_HEADERS[i], GIF_HEADER_LENGTH);
    }
    
    hdr = NULL;
    for (i = 0; i < GIF_HEADERS_COUNT; i++)
    {
        if (hdrsearch[i] == NULL) continue;
        if (hdrsearch[i] < hdr || hdr == NULL) { hdr = hdrsearch[i]; }
    }
    
    return hdr;
}

/*  PRECOND:    
    POSTCOND:   If a header was found, _descriptorOffset points to the LSD and
                    scan state is FOLLOWING_LOGICAL_SCREEN_DESCRIPTOR
*/
-(void)advanceToHeader
{
    NSData *d = [_block data];
    const void *dbytes = [d bytes];
    void *hdr;
    unsigned int hdrOffset;
    
    hdr = searchGIFHeaders(dbytes + _sigScanOffset, [d length] - _sigScanOffset);
    hdrOffset = hdr - dbytes;

    if (hdr == NULL)
    {
        _scanOffset = [d length];
        _sigScanOffset = [d length] - GIF_HEADER_LENGTH;
        return;
    }
    
    _sigScanOffset = hdrOffset;
    
    if (!(hdrOffset + GIF_HEADER_LENGTH + LSD_LENGTH < [d length]))
    {   _scanOffset = [d length];
        return;
    }
    
    if (((char*)hdr)[GIF_HEADER_LENGTH + LSD_PIXELASPECT_RATIO_OFFSET] != 0)
    {
        NSLog(@"DUDE ARE YOU TELLING ME UR PIXELS AREN'T SQUARE??");
        _sigScanOffset += GIF_HEADER_LENGTH;
        _scanOffset = _sigScanOffset;
        return;
    }
    
    // all right at this point just call it legit
    _imageStartOffset = _sigScanOffset;
    _descriptorOffset = _sigScanOffset + GIF_HEADER_LENGTH;

    _scanOffset = _descriptorOffset;
    _state = GSLogicalScreenDescriptor;
}

-(id) initWithDataBlock:(DataBlock *)db
{
    self = [super init];
    if (self)
    {
        _scanOffset = 0;
        _sigScanOffset = 0;
        _state = GSInterimage;
        _block = [db retain];
    }
    return self;
}

-(void)dealloc
{
    [_block release];
    [super dealloc];
}

/* PRECOND: _scanOffset points to the first byte of a block.
*/
-(void) advanceByBlock
{
    NSData *d = [_block data];
    const void *dbytes = [d bytes];
    char blockid = ((char*)dbytes)[_scanOffset];

    switch (blockid)
    {
        case 0x21: // extension, see if you can advance to the subblocks
            _state = GSSubBlock;
            _scanOffset += 2;
            _lastSubBlockOffset = _scanOffset;
            break;
            
        case 0x2c:
            _state = GSImageDescriptor;
            _descriptorOffset = _scanOffset;
            // _scanOffset unmodified
            break;
            
        case 0x3b: // end block.
            _state = GSInterimage;
            _scanOffset += 1;
            _sigScanOffset = _scanOffset;

        // publish the image we found
        [self publishImage:
            [[[NSImage alloc] initWithData:
                [d subdataWithRange:NSMakeRange(_imageStartOffset,
                                        (_sigScanOffset - _imageStartOffset))]]
                autorelease]];
            break;
    }
}


-(void)publishImage:(NSImage *)img
{
    //NSLog(@"found an image you monsters: %@", img);
    
    [[NSNotificationCenter defaultCenter] postNotification:
        [NSNotification notificationWithName:GIFScannerExtractedImage
        object:img]];
}

-(void)advanceImageDescriptor
{
    NSData *d = [_block data];
    const void *dbytes = [d bytes];
    char * imgdesc = (char*)(dbytes + _descriptorOffset);
    
    if (_descriptorOffset + IMAGEDESC_PACKEDBYTE_OFFSET < [d length])
    {
        _lastSubBlockOffset = _descriptorOffset
                        + IMAGEDESC_LENGTH
                        + [GIFScan colorTableSizeFromPackedByte:
                                        imgdesc[IMAGEDESC_PACKEDBYTE_OFFSET]]
                        + 1 /* LZW minimum code size byte */;
        _scanOffset = _lastSubBlockOffset;
        _state = GSSubBlock;
    }
    else
    {
        _scanOffset = [d length];
    }
}


-(void)advanceLogicalScreenDescriptor
{
    NSData *d = [_block data];
    const void *dbytes = [d bytes];
    char * imgdesc = (char*)(dbytes + _descriptorOffset);
    
    if (_descriptorOffset + LSD_PACKEDBYTE_OFFSET < [d length])
    {
        _scanOffset = _descriptorOffset
                        + LSD_LENGTH
                        + [GIFScan colorTableSizeFromPackedByte:
                                        imgdesc[LSD_PACKEDBYTE_OFFSET]];
        _state = GSBlock;
    }
    else
    {
        _scanOffset = [d length];
    }
}



/*  PRECOND:    _lastSubBlockOffset points to the first byte in the subblock
*/
-(void)advanceBySubBlock
{
    NSData *d = [_block data];
    const void *dbytes = [d bytes];
    char * lastSubBlock = (char*)(dbytes + _lastSubBlockOffset);
    unsigned char sblen = lastSubBlock[0];
    unsigned int nextSBOffset;
    
    nextSBOffset = _lastSubBlockOffset + sblen + 1;
    
    if (sblen == 0) // block terminator
    {
        _scanOffset = nextSBOffset;
        _state = GSBlock;
    }
    // advance the offsets, the length/boundary check is in -advance.
    else
    {
        _lastSubBlockOffset = nextSBOffset;
        _scanOffset = nextSBOffset;
    }
}

-(void)advance
{
    NSData *d = [_block data];
    while (_scanOffset < [d length])
    {
        switch (_state)
        {
            case GSInterimage:
                //NSLog(@"advanceToHeader at %@:%d", self, _scanOffset);
                [self advanceToHeader];
                break;
                
            case GSLogicalScreenDescriptor:
                // NSLog(@"advanceLogicalScreenDescriptor");
                [self advanceLogicalScreenDescriptor];
                break;
                
            case GSBlock:
                // NSLog(@"advanceByBlock");
                [self advanceByBlock];
                break;
                
            case GSImageDescriptor:
                // NSLog(@"advanceImageDescriptor");
                [self advanceImageDescriptor];
                break;
                
            case GSSubBlock:
                // NSLog(@"advanceBySubBlock");
                [self advanceBySubBlock];
                break;
        }
    }
}

-(void)finalize
{
    // FIX: publish what you got so far
    [self advance];
    if (_state != GSInterimage)
    {
        NSLog(@"GIFScan publish what you got");
    }

#if 0
    // diagnostics
    NSLog(@"GIFScan finalize");
    NSLog(@"_block: %@", _block);
    NSLog(@"_scanOffset: %x", _scanOffset);
    NSLog(@"_sigScanOffset: %x", _sigScanOffset);
    NSLog(@"_imageStartOffset: %x", _imageStartOffset);
    NSLog(@"_state: %@",
        (_state == GSInterimage) ? @"GSInterimage" :
        (_state == GSLogicalScreenDescriptor) ? @"GSLogicalScreenDescriptor" :
        (_state == GSBlock) ? @"GSBlock" :
        (_state == GSImageDescriptor) ? @"GSImageDescriptor" : 
        (_state == GSSubBlock) ? @"GSSubBlock" : @"???");

    NSLog(@"_lastSubBlockOffset: %x", _lastSubBlockOffset);
    NSLog(@"_descriptorOffset: %x", _descriptorOffset);
#endif
}

-(void)resetWithNewDataBlock:(DataBlock*)newBlock
{
    int diff = [_block range].location - [newBlock range].location;

    // FIX: recompute offsets in _taggedRanges for use with new block
    // it will be something like:
    //
    // for each range
    //   r.location += diff
    // end

    NSLog(@"GIFScan resetWithNewDataBlock\tdiff: %d", diff);

    if (diff != 0)
    {
        _scanOffset = 0;
        _sigScanOffset = _scanOffset;
        _state = GSInterimage;
    }

    [_block release];
    _block = [newBlock retain];
}

-(void)mergeWithScan:(GIFScan *)gs
{
    // eh
}

-(NSArray *)taggedRanges { return nil; }
-(DataBlock *)block { return _block; }



struct packedbyte
{
    unsigned char tableFlag:1;      // this was way awesomer when it was
    unsigned char dontCare:4;       // inlined as an initializer
    unsigned char tableSizeField:3;
};

/* This method can use the packed fields and get the size of Global Color Table
   OR Local ones.  The packed field layout and size calculation happens to be
   the same. */
+(unsigned int)colorTableSizeFromPackedByte:(char)p
{
    struct packedbyte * packed = (struct packedbyte *)&p; 
    
    if (packed->tableFlag == 0)
    {   return 0;
    }
    else
    {   return pow(2, packed->tableSizeField + 1) * 3;  // * 3 because r,g,b
    }
}
@end
