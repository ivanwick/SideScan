

#import "PSBController.h"

@implementation PSBController

char tcpdump_path[] = "/usr/sbin/tcpdump";

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

- (IBAction)runTcpdump:(id)sender
{
    OSStatus err = 0;
	FILE *iopipe;
	
     // tcpdump -i en1 -s 0 -U -s 0 -w -
    char* args[] = {"-i", "en1", "-s", "0", "-U", "-w", "-",
                    "tcp and port 80", NULL};
   
    if (! authorized)
    {
        [self alertNotAuthorized];
    }
    else
    {
        err = AuthorizationExecuteWithPrivileges(authorizationRef,
                tcpdump_path, 0, args, &iopipe);
	
		pktStream = [[PacketStream alloc] initWithFilePtr:iopipe];
		pktAnalyzer = [[PacketAnalyzer alloc] init];
		[self connectObservers];
                
		[pktStream monitorInBackgroundAndNotify];
    }
}

- (void)connectObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:pktAnalyzer
								selector:@selector(procPacketNotification:)
								name:PcapPacketReceived
								object:pktStream];
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
    [textArea insertText:@"Connected y0\n"];
}

- (IBAction)toggleAuth:(id)sender
{
    AuthorizationRights rights;
    AuthorizationFlags flags;
    AuthorizationItem items[1];
    OSStatus err = 0;
    
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
}

- (void)awakeFromNib
{
    authorizationRef = NULL;
    authorized = NO;

    [self setupAuthorizationRef];
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

@end
