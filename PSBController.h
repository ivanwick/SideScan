/* PSBController */

#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

#import "PacketStream.h"
#import "PacketAnalyzer.h"

@interface PSBController : NSObject
{
    AuthorizationRef authorizationRef;
    bool authorized;
    PacketStream *pktStream;
	PacketAnalyzer *pktAnalyzer;
}

- (IBAction)runTcpdump:(id)sender;
- (IBAction)toggleAuth:(id)sender;

- (void)connectObservers;
- (void)setupAuthorizationRef;
@end
