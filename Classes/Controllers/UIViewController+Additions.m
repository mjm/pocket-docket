#import "UIViewController+Additions.h"

#import "../Singletons/PDPersistenceController.h"

@implementation UIViewController (Additions)

- (void)presentLoginViewController
{
	PDLoginViewController *loginController = [[PDLoginViewController alloc] init];
	loginController.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
	[loginController release];
	
	navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		navController.modalPresentationStyle = UIModalPresentationPageSheet;
	}
	
	[self presentModalViewController:navController animated:YES];
}

- (BOOL)shouldPresentLoginViewController
{
	return NO;
}


#pragma mark -
#pragma mark Login Controller Delegate Methods

- (void)loginControllerDidCancel:(PDLoginViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)loginControllerDidLogin:(PDLoginViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
	[[PDPersistenceController sharedPersistenceController] save];
}

- (void)loginControllerDidRegister:(PDLoginViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
	[[PDPersistenceController sharedPersistenceController] save];
}

@end
