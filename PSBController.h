/* PSBController */

#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

#import "PacketStream.h"
//#import "PacketAnalyzer.h"
#import "TrafficAnalyzer.h"
#import "FlyingImagesView.h"
#import "PcapConfigSheet.h"

@interface PSBController : NSObject
{
    AuthorizationRef authorizationRef;
    BOOL authorized;
    PacketStream *pktStream;
	// PacketAnalyzer *pktAnalyzer;
    TrafficAnalyzer *trafAnalyzer;
    NSMutableArray *extractedImages;
    
    IBOutlet NSTextView * textArea;
    IBOutlet NSArrayController *arrayController;
	
	BOOL isImagesCollectionVisible;
	BOOL isHUDVisible;
	BOOL isFlyingImagesVisible;
	BOOL isAnimationSettingsVisible;
    
    IBOutlet FlyingImagesView * fiView;
    
    IBOutlet PcapConfigSheet * pcapConfigSheet;
    IBOutlet NSWindow * mainWindow;
}

- (IBAction)showPcapConfigSheet:(id)sender;

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
