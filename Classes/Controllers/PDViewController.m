#import "PDViewController.h"

#import "UIViewController+Additions.h"
#import "PDSyncDelegate.h"

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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(credentialsNeeded:)
												 name:PDCredentialsNeededNotification
											   object:nil];
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
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:PDCredentialsNeededNotification
												  object:nil];
	[super dealloc];
}

@end
