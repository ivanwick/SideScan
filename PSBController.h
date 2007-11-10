/* PSBController */

#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

#import "PacketPipe.h"

@interface PSBController : NSObject
{
    AuthorizationRef authorizationRef;
    bool authorized;
    PacketPipe *pktPipe;
}

- (IBAction)runTcpdump:(id)sender;
- (IBAction)toggleAuth:(id)sender;

- (IBAction)connectPacketPipe:(id)sender;

- (void)setupAuthorizationRef;
@end
