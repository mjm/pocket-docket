#import "PDLoginViewController.h"

#import "../PDSettingsController.h"

#import "ObjectiveResource.h"
#import "Connection.h"
#import "ConnectionManager.h"
#import "Response.h"

@implementation PDLoginViewController

#pragma mark -
#pragma mark Initializing a View Controller

- (id)init
{
	if (![super initWithNibName:@"PDLoginView" bundle:nil])
		return self;
	
	// TODO localize
	self.title = NSLocalizedString(@"Login", nil);
	return self;
}


#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.loginButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.tableView = nil;
	self.cancelButton = nil;
	self.loginButton = nil;
	self.usernameField = nil;
	self.usernameCell = nil;
	self.passwordField = nil;
	self.passwordCell = nil;
}


#pragma mark -
#pragma mark Actions

- (IBAction)cancel
{
	[self.delegate loginControllerDidCancel:self];
}

- (void)showLoginFailedAlert
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed", nil)
														message:NSLocalizedString(@"Login Failed Message", nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
}

- (void)reenableButtons
{
	self.cancelButton.enabled = self.loginButton.enabled = YES;
}

- (void)doLogin
{
	NSString *url = [[ObjectiveResourceConfig getSite] stringByAppendingString:@"ping"];
	NSString *username = self.usernameField.text;
	NSString *password = self.passwordField.text;
	Response *response = [Connection get:url withUser:username andPassword:password];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if ([response isSuccess])
	{
		PDSettingsController *settingsController = [PDSettingsController sharedSettingsController];
		settingsController.docketAnywhereUsername = username;
		settingsController.docketAnywherePassword = password;
		
		[(NSObject *)self.delegate performSelectorOnMainThread:@selector(loginControllerDidLogin:) withObject:self waitUntilDone:NO];
	}
	else if (response.statusCode == 401) // Not Authorized
	{
		[self performSelectorOnMainThread:@selector(showLoginFailedAlert) withObject:nil waitUntilDone:NO];
	}
	else
	{
		NSLog(@"Error in response, status code: %d", response.statusCode);
	}
	
	[self performSelectorOnMainThread:@selector(reenableButtons) withObject:nil waitUntilDone:NO];
}

- (IBAction)login
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.cancelButton.enabled = self.loginButton.enabled = NO;
	[[ConnectionManager sharedInstance] runJob:@selector(doLogin) onTarget:self];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// TODO localize
	return @"Login to DocketAnywhere";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *UsernameCell = @"UsernameCell";
	static NSString *PasswordCell = @"PasswordCell";
	
	if (0 == indexPath.row)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UsernameCell];
		if (!cell)
		{
			cell = self.usernameCell;
		}
		
		NSString *username = [[PDSettingsController sharedSettingsController] docketAnywhereUsername];
		if (username)
		{
			self.usernameField.text = username;
		}
		else
		{
			self.usernameField.text = @"";
			[self.usernameField becomeFirstResponder];
		}
		
		return cell;
	}
	else
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PasswordCell];
		if (!cell)
		{
			cell = self.passwordCell;
		}
		
		NSString *password = [[PDSettingsController sharedSettingsController] docketAnywherePassword];
		if (password)
		{
			self.passwordField.text = password;
		}
		else
		{
			self.passwordField.text = @"";
		}
		
		return cell;
	}
}


#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (0 == indexPath.row)
	{
		[self.usernameField becomeFirstResponder];
	}
	else
	{
		[self.passwordField becomeFirstResponder];
	}
}


#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.usernameField)
	{
		[self.passwordField becomeFirstResponder];
	}
	else
	{
		[self login];
	}
	
	return NO;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	self.delegate = nil;
	self.tableView = nil;
	self.cancelButton = nil;
	self.loginButton = nil;
	self.usernameField = nil;
	self.usernameCell = nil;
	self.passwordField = nil;
	self.passwordCell = nil;
    [super dealloc];
}


@end
