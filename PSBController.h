/* PSBController */

#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

#import "PacketStream.h"
//#import "PacketAnalyzer.h"
#import "TrafficAnalyzer.h"

@interface PSBController : NSObject
{
    AuthorizationRef authorizationRef;
    bool authorized;
    PacketStream *pktStream;
	// PacketAnalyzer *pktAnalyzer;
    TrafficAnalyzer *trafAnalyzer;
    
    IBOutlet NSTextView * textArea;
}

- (IBAction)runTcpdump:(id)sender;
- (IBAction)toggleAuth:(id)sender;
- (IBAction)showStatus:(id)sender;
- (IBAction)clearLogText:(id)sender;

- (void)connectObservers;
- (void)setupAuthorizationRef;
@end
