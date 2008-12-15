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
    NSMutableArray *extractedImages;
    
    IBOutlet NSTextView * textArea;
    IBOutlet NSArrayController *arrayController;
	
	BOOL isHUDVisible;
}

- (IBAction)runTcpdump:(id)sender;
- (IBAction)toggleAuth:(id)sender;
- (IBAction)showStatus:(id)sender;
- (IBAction)clearLogText:(id)sender;


- (void)connectObservers;
- (void)setupAuthorizationRef;

-(id)extractedImages;
-(BOOL)isHUDVisible;
-(void)setIsHUDVisible:(BOOL)b;
// -(id)valueForKey:(NSString*)k;
@end
