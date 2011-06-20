/* PcapConfigSheet */

#import <Cocoa/Cocoa.h>
#import <pcap.h>

@interface PcapConfigSheet : NSPanel
{

    NSString *device;
    NSString *filter;
    
    id modalDelegate;
    SEL didEndSelector;
    
    IBOutlet NSTextField *filterTextField;
    
    IBOutlet NSArrayController *devArrayController;
    
    
    IBOutlet NSButton *continueButton;
    IBOutlet NSButton *cancelButton;
    
}

- (IBAction)doneWithSheet:(id)sender;

- (NSString *) device;
- (NSString *) filter;

//- (void) setDeviceList:(NSArray *)devList;
- (void) setDefaultFilter:(NSString *)aFilter;


/* returnCodes used in callback after showing the sheet */
enum PCSReturnCode
{
    PCSContinueButton = 1,
    PCSCancelButton = 0
};

@end
