//
//  GIFScan.h
//  PcapSandbox
//
//  Created by Ivan Wick on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConnectionTCP.h"

typedef enum {
    GSInterimage,
    GSLogicalScreenDescriptor,
    GSBlock,
    GSImageDescriptor,
    GSSubBlock,
} GIFScanState ;


@interface GIFScan : NSObject {
    DataBlock * _block;
    
    unsigned int _scanOffset;
    unsigned int _sigScanOffset;
    unsigned int _imageStartOffset;
    GIFScanState _state;
    
    unsigned int _lastSubBlockOffset;    
    unsigned int _descriptorOffset;
}

-(id)initWithDataBlock:(DataBlock*)db;
-(void)advance;
-(void)resetWithNewDataBlock:(DataBlock*)db;
-(void)mergeWithScan:(GIFScan *)gs;
-(void)finalize;

-(NSArray *)taggedRanges;
-(DataBlock *)block;

+(unsigned int)colorTableSizeFromPackedByte:(char)p;

// private
-(void)advanceToHeader;
-(void) advanceByBlock;
-(void)advanceImageDescriptor;
-(void)advanceLogicalScreenDescriptor;
-(void)advanceBySubBlock;
-(void)publishImage:(NSImage *)img;

@end
