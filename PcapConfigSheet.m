#import "PcapConfigSheet.h"

@implementation PcapConfigSheet

- (NSString *) device
{
    /* should this return a copy instead? */
    return device;
}

- (NSString *) filter
{
    /* should this return a copy instead? */
    return filter;
}

/*
- (void) setDeviceList:(NSArray *)devList
{
    [devicePopUp removeAllItems];
    [devicePopUp addItemsWithTitles:devList];
}
*/

- (void) setDefaultFilter:(NSString *)aFilter
{
    [filterTextField setStringValue:aFilter];
}


- (IBAction)doneWithSheet:(id)sender
{
    enum PCSReturnCode retcode;
    
    if (sender == continueButton)
    {   retcode = PCSContinueButton;
    }
    else
    {   retcode = PCSCancelButton;
    }
    
    device = [[[devArrayController selectedObjects] objectAtIndex:0]  objectForKey:@"DeviceName"];
    filter = [filterTextField stringValue];
    
    [NSApp endSheet:self returnCode:retcode];
}

@end
