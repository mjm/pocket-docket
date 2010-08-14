#import "UIViewController+Additions.h"


@implementation UIViewController (Additions)

- (void)presentLoginViewController
{
	PDLoginViewController *loginController = [[PDLoginViewController alloc] init];
	loginController.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
	[loginController release];
	
	navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
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
}

- (void)loginControllerDidRegister:(PDLoginViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
