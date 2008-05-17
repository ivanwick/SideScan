/* PSBController */

#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

#import "PacketStream.h"

@interface PSBController : NSObject
{
    AuthorizationRef authorizationRef;
    bool authorized;
    PacketStream *pktStream;
}

- (IBAction)runTcpdump:(id)sender;
- (IBAction)toggleAuth:(id)sender;

- (IBAction)connectPacketPipe:(id)sender;

- (void)setupAuthorizationRef;
@end
