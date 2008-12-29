

#import "PSBController.h"

// this is only here because i am hardcoding this scanner in
#import "HTTPRequestScanner.h"
#import "PNGScanner.h"
#import "JFIFScanner.h"
#import "GIFScanner.h"

@implementation PSBController

char tcpdump_path[] = "/usr/sbin/tcpdump";

-(id) init
{
    self = [super init];
    if (self)
    {
        extractedImages = [[NSMutableArray alloc] initWithCapacity:100];

        authorizationRef = NULL;
        authorized = NO;
    }
    return self;
}

-(void)dealloc
{
    [extractedImages release];
    [super dealloc];
}

- (void)alertNotAuthorized
{
    NSAlert *theAlert = [[NSAlert alloc] init];
    
    [theAlert setMessageText:@"You are not yet authorized to run tcpdump."];
    [theAlert setInformativeText:
        @"In order to gain authorization, you must first authenticate."];
    [theAlert setAlertStyle:NSWarningAlertStyle];
    [theAlert addButtonWithTitle:@"OK"];
    [theAlert runModal];
    
    [theAlert release];
}


- (void)connectObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:trafAnalyzer
								selector:@selector(receivedPacketNotification:)
								name:PcapPacketReceived
								object:pktStream];
                                
    [[[HTTPRequestScanner alloc] init] registerAsObserver];
    
    [[[PNGScanner alloc] init] registerAsObserver];    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(receivedExtractedImageNotification:)
                                name:PNGScannerExtractedImage
                                object:nil];

    [[[JFIFScanner alloc] init] registerAsObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(receivedExtractedImageNotification:)
                                name:JFIFScannerExtractedImage
                                object:nil];
    
    [[[GIFScanner alloc] init] registerAsObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(receivedExtractedImageNotification:)
                                name:GIFScannerExtractedImage
                                object:nil];

                                    
/*
    PacketPipe *pktPipe = [[PacketPipe alloc] initUsingFopen:iopipe];
    PacketAnalyzer *pktAnalyzer = [[PacketAnalyzer alloc] init];
    
    [self setObserver: PacketAnalyzerGotImage delegate:self selector:procImage];

    [self setObserver: something: whatever: yarly:];
    [pktPipe readInBackgroundAndNotify];
*/
/*  [textStorage beginEditing];
    [[textArea textStorage] appendAttributedString:
        [[[NSAttributedString alloc]
            initWithString:@"Connected y0"] autorelease]];
    [textStorage endEditing];
*/
    [[[textArea textStorage] mutableString] appendString:@"Connected y0\n"];
}

- (IBAction)toggleAuth:(id)sender
{
    AuthorizationRights rights;
    AuthorizationFlags flags;
    AuthorizationItem items[1];
    OSStatus err = noErr;
    
    if (authorized)
    {
        /* Do you have to call AuthorizationCreate after using
           AuthorizationFree? (I think so.)
           Is there a better way to revoke your Authorization rights without
           completely destroying your AuthorizationReference?
        */
        AuthorizationFree(authorizationRef,kAuthorizationFlagDestroyRights);
        authorized = NO;
    }
    else
    {
        [self setupAuthorizationRef];
        items[0].name = kAuthorizationRightExecute;
        items[0].value = tcpdump_path;
        items[0].valueLength = strlen(tcpdump_path);
        items[0].flags = 0;
    
        rights.count=1;
        rights.items = items;
    
        flags = kAuthorizationFlagInteractionAllowed 
                    | kAuthorizationFlagExtendRights;

    // Here, since we've specified kAuthorizationFlagExtendRights and
    // have also specified kAuthorizationFlagInteractionAllowed, if the
    // user isn't currently authorized to execute tools as root 
    // (kAuthorizationRightExecute),they will be asked for their password. 

    // The err return value will indicate authorization success or failure.

        err = AuthorizationCopyRights(authorizationRef,&rights,
                                    kAuthorizationEmptyEnvironment,
                                    flags, NULL);

        if (err != errAuthorizationSuccess)
        {
            NSLog(@"Authorization failed.");
            return;
        }
        
        authorized = YES;
    }

    
    if (authorized) { [textArea insertText:@"Authorization: YA RLY\n"];  }
    else            { [textArea insertText:@"Authorization: NO LULZ\n"]; }
}

- (void)awakeFromNib
{
    // actually this is getting called in the toggleauth action method
    //[self setupAuthorizationRef];
}

- (void)setupAuthorizationRef
{
    authorizationRef = NULL;
    OSStatus err = 0;

    // The authorization rights structure holds a reference to an array
    // of AuthorizationItem structures that represent the rights for which
    // you are requesting access.

    AuthorizationRights rights;
    AuthorizationFlags flags;
    
    // We just want the user's current authorization environment,
    // so we aren't asking for any additional rights yet.

    rights.count=0;
    rights.items = NULL;
        
    flags = kAuthorizationFlagDefaults;
    
    err = AuthorizationCreate(&rights, kAuthorizationEmptyEnvironment, 
                              flags, &authorizationRef);
    
    if (err != errAuthorizationSuccess)
    {
        NSLog(@"AuthorizationRef initialization failed. Consider quitting now.");
    }
}

- (IBAction)showStatus:(id)sender
{
    [textArea insertText:@"STATUS ur mom\n"];
    if (trafAnalyzer)
    {   [textArea insertText:[trafAnalyzer connectionStatus]];
    }
    else
    {   [textArea insertText:@"Traffic Analyzer not initialized yet\n"];
    }
}

- (IBAction)clearLogText:(id)sender
{
    [[textArea textStorage] setAttributedString:
        [[[NSAttributedString alloc] initWithString:@""] autorelease]];
        

    /* this is just here as a positive control for testing the bindings */
    /*[[NSNotificationCenter defaultCenter]
        postNotificationName:PNGScannerExtractedImage
        object:[[NSImage alloc] initWithContentsOfFile:
            @"/Users/ivan/choptest/full/cheapcontrol.png"]];
    NSLog(@"sent note");
    */
}

-(void)receivedExtractedImageNotification:(NSNotification *)note
{
    NSImage * img = [note object];
    [arrayController addObject:img];
    [fiView displayImage:img];
}

-(id)extractedImages	{ return extractedImages; }

-(BOOL)isImagesCollectionVisible          { return isImagesCollectionVisible; }
-(void)setIsImagesCollectionVisible:(BOOL)b	 { isImagesCollectionVisible = b; }
-(BOOL)isHUDVisible                       { return isHUDVisible; }
-(void)setIsHUDVisible:(BOOL)b               { isHUDVisible = b; }
-(BOOL)isFlyingImagesVisible              { return isFlyingImagesVisible; }
-(void)setIsFlyingImagesVisible:(BOOL)b      { isFlyingImagesVisible = b; }
-(BOOL)isAnimationSettingsVisible         { return isAnimationSettingsVisible; }
-(void)setIsAnimationSettingsVisible:(BOOL)b { isAnimationSettingsVisible = b; }



#if 0
-(id)valueForKey:(NSString*)k
{
    NSLog(@"vfk %@", k);
    if ([k isEqual:@"extractedImages"])
    {   return extractedImages;
    }
    else
    {
        return nil;
    }
}
#endif



- (void)runTcpdumpWithDevice:(NSString *)dev filter:(NSString *)filt
{
    OSStatus err = 0;
	FILE *iopipe;
	
     // tcpdump -i en1 -s 0 -U -s 0 -w - tcp and src port 80
    char* args[] = {"-i", (char*)[dev UTF8String], "-s", "0", "-U", "-w", "-",
                    (char*)[filt UTF8String], NULL};
   
    if (! authorized)
    {
        [self alertNotAuthorized];
    }
    else
    {
        err = AuthorizationExecuteWithPrivileges(authorizationRef,
                tcpdump_path, 0, args, &iopipe);
	
		pktStream = [[PacketStream alloc] initWithFilePtr:iopipe];
		// pktAnalyzer = [[PacketAnalyzer alloc] init];
        trafAnalyzer = [[TrafficAnalyzer alloc] init];
		[self connectObservers];
        
		[pktStream monitorInBackgroundAndNotify];
        //[sender setEnabled:NO];
    }
}


//- (void) loadAndSchedulePcapConfig
- (IBAction)showPcapConfigSheet:(id)sender;
{
    [NSBundle loadNibNamed:@"PcapConfigSheet" owner:self];

    // what used to be set up in the next 2 lines is taken care of by
    // the array controller in the nib now.
    //[pcapConfigSheet setDeviceList:[PcapUtilities allInterfaces]];
    //[pcapConfigSheet setDefaultFilter:@"tcp port 80 and not arp"];
    
    /* What really happens when this scheduled after "delay of 0" is that it
       will run during the next iteration of the event loop.
       All of the NSWindow loading etc. is expected to be done by then, so that
       the sheet has a window it can be attached to.
       However, I have not found definitive verification of this mechanism in
       the docs, because it seems to work so I haven't looked.  */
    [self performSelector:@selector(displayPcapConfigSheet)
        withObject:self
        afterDelay:0];

}

- (void) displayPcapConfigSheet
{
    [NSApp beginSheet: pcapConfigSheet
        modalForWindow: mainWindow
        modalDelegate: self
        didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
        contextInfo: nil];
}

-(void) didEndSheet:(NSPanel *)theSheet returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    if (returnCode == PCSContinueButton)
    {
        [self runTcpdumpWithDevice:[pcapConfigSheet device]
                            filter:[pcapConfigSheet filter]];
        [theSheet orderOut:self];
    }
    else
    {
        NSLog(@"%@: PCSCancelButton", self);
        //[self close];
    }
}


@end
