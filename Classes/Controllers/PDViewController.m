#import "PDViewController.h"

#import "UIViewController+Additions.h"
#import "PDSyncDelegate.h"

#ifdef MULTITASKING

BOOL PDCanBackground()
{
    UIDevice *device = [UIDevice currentDevice];
    return [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
}

#else

BOOL PDCanBackground() { return NO; }

#endif

static BOOL credentialsNeeded = NO;

@implementation PDViewController

- (void)credentialsNeeded:(NSNotification *)note
{
	if ([self shouldPresentLoginViewController])
	{
		[self presentLoginViewController];
		credentialsNeeded = NO;
	}
	else
	{
		credentialsNeeded = YES;
	}
}

- (void)applicationDidEnterBackground:(NSNotification *)note
{
    // Default to do nothing. Subclasses should override if desired.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(credentialsNeeded:)
												 name:PDCredentialsNeededNotification
											   object:nil];
#ifdef MULTITASKING
    if (PDCanBackground())
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (credentialsNeeded && [self shouldPresentLoginViewController])
	{
		credentialsNeeded = NO;
		[self presentLoginViewController];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:PDCredentialsNeededNotification
												  object:nil];
#ifdef MULTITASKING
    if (PDCanBackground())
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidEnterBackgroundNotification
                                                      object:nil];
#endif
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:PDCredentialsNeededNotification
												  object:nil];
#ifdef MULTITASKING
    if (PDCanBackground())
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidEnterBackgroundNotification
                                                      object:nil];
#endif
	[super dealloc];
}

@end
