#import "PDLoginViewController.h"

#import "../PDSettingsController.h"
#import "../PDKeyboardObserver.h"
#import "../Views/PDTextFieldCell.h"

#import "ObjectiveResource.h"
#import "Connection.h"
#import "ConnectionManager.h"
#import "Response.h"

@interface PDLoginViewController ()

@property (nonatomic, assign) BOOL showRegistrationFields;

- (void)activateTextFieldForRow:(NSNumber *)row;

@end

@implementation PDLoginViewController

#pragma mark -
#pragma mark Initializing a View Controller

- (id)init
{
	if (![super initWithNibName:@"PDLoginView" bundle:nil])
		return self;
	
	// TODO localize
	self.title = NSLocalizedString(@"DocketAnywhere", nil);
	return self;
}


#pragma mark -
#pragma mark Private Methods

- (void)activateTextFieldForRow:(NSNumber *)rowNum
{
	NSInteger row = [rowNum integerValue];
	PDTextFieldCell *cell = (PDTextFieldCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
	[cell.textField becomeFirstResponder];
}


#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.loginButton;
	
	self.keyboardObserver = [PDKeyboardObserver keyboardObserverWithViewController:self delegate:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.keyboardObserver = nil;
	self.tableView = nil;
	self.cancelButton = nil;
	self.loginButton = nil;
	self.usernameField = nil;
	self.emailField = nil;
	self.passwordField = nil;
	self.passwordConfirmField = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.keyboardObserver registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
	//[self.usernameField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.keyboardObserver unregisterNotifications];
}


#pragma mark -
#pragma mark Actions

- (IBAction)cancel
{
	[self.delegate loginControllerDidCancel:self];
}

- (void)handleLoginResponse:(Response *)response
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if ([response isSuccess])
	{
		PDSettingsController *settingsController = [PDSettingsController sharedSettingsController];
		settingsController.docketAnywhereUsername = self.usernameField.text;
		settingsController.docketAnywherePassword = self.passwordField.text;
		
		[self.delegate loginControllerDidLogin:self];
	}
	else if (response.statusCode == 401) // Not Authorized
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed", nil)
															message:NSLocalizedString(@"Login Failed Message", nil)
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)
												  otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
	else
	{
		NSLog(@"Error in response, status code: %d", response.statusCode);
	}
	
	self.cancelButton.enabled = self.loginButton.enabled = YES;
}

- (void)doLogin
{
	NSString *url = [[ObjectiveResourceConfig getSite] stringByAppendingString:@"ping"];
	NSString *username = self.usernameField.text;
	NSString *password = self.passwordField.text;
	Response *response = [Connection get:url withUser:username andPassword:password];
	
	[self performSelectorOnMainThread:@selector(handleLoginResponse:) withObject:response waitUntilDone:NO];
}

- (IBAction)login
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.cancelButton.enabled = self.loginButton.enabled = NO;
	[[ConnectionManager sharedInstance] runJob:@selector(doLogin) onTarget:self];
}

- (IBAction)setFormMode:(UISegmentedControl *)sender
{
	self.usernameField = self.emailField = self.passwordField = self.passwordConfirmField = nil;
	
	if (sender.selectedSegmentIndex == 0)
	{
		self.showRegistrationFields = NO;
		[self.navigationItem setRightBarButtonItem:self.loginButton animated:YES];
	}
	else
	{
		self.showRegistrationFields = YES;
		[self.navigationItem setRightBarButtonItem:self.registerButton animated:YES];
	}

	[self.tableView reloadData];
//	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
//				  withRowAnimation:UITableViewRowAnimationFade];
	//[self performSelector:@selector(activateTextFieldForRow:) withObject:[NSNumber numberWithInteger:0] afterDelay:0.2];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return self.showRegistrationFields ? 4 : 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// TODO localize
	return self.showRegistrationFields ? @"Create an Account" : @"Login to DocketAnywhere";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *TextFieldCell = @"TextFieldCell";
	
	NSInteger passOffset = self.showRegistrationFields ? 2 : 1;
	
	PDTextFieldCell *cell = (PDTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:TextFieldCell];
	if (!cell)
	{
		cell = [PDTextFieldCell textFieldCell];
	}
	cell.textField.delegate = self;
	cell.textField.returnKeyType = UIReturnKeyNext;
	cell.textField.textColor = [UIColor colorWithRed:56/255.0 green:84/255.0 blue:135/255.0 alpha:1.0];
	
	if (0 == indexPath.row)
	{
		BOOL focusUsername = self.usernameField == nil;
		
		cell.textLabel.text = @"Username"; // TODO localize
		self.usernameField = cell.textField;
		
		self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
		NSString *username = [[PDSettingsController sharedSettingsController] docketAnywhereUsername];
		if (username && !self.showRegistrationFields)
		{
			self.usernameField.text = username;
		}
		else
		{
			self.usernameField.text = @"";
		}
		
		if (focusUsername)
		{
			[self.usernameField becomeFirstResponder];
		}
	}
	else if (self.showRegistrationFields && 1 == indexPath.row)
	{
		cell.textLabel.text = @"Email"; // TODO localize
		self.emailField = cell.textField;
		
		self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
		self.emailField.text = @"";
	}
	else if (passOffset == indexPath.row) 
	{
		cell.textLabel.text = @"Password"; // TODO localize
		self.passwordField = cell.textField;
		
		self.passwordField.secureTextEntry = YES;
		
		NSString *password = [[PDSettingsController sharedSettingsController] docketAnywherePassword];
		if (password && !self.showRegistrationFields)
		{
			self.passwordField.text = password;
		}
		else
		{
			self.passwordField.text = @"";
		}
		
		if (!self.showRegistrationFields)
		{
			self.passwordField.returnKeyType = UIReturnKeyGo;
		}
	}
	else
	{
		cell.textLabel.text = @"Confirm"; // TODO localize
		self.passwordConfirmField = cell.textField;
		
		self.passwordConfirmField.returnKeyType = UIReturnKeyGo;
		self.passwordConfirmField.secureTextEntry = YES;
		self.passwordConfirmField.text = @"";
	}
	
	return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	PDTextFieldCell *cell = (PDTextFieldCell *) [tableView cellForRowAtIndexPath:indexPath];
	[cell.textField becomeFirstResponder];
}


#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.usernameField)
	{
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
							  atScrollPosition:UITableViewScrollPositionTop
									  animated:YES];
		[(self.showRegistrationFields ? self.emailField : self.passwordField) becomeFirstResponder];
	}
	else if (textField == self.emailField)
	{
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
							  atScrollPosition:UITableViewScrollPositionTop
									  animated:YES];
		[self.passwordField becomeFirstResponder];
	}
	else if (textField == self.passwordField && self.showRegistrationFields)
	{
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]
							  atScrollPosition:UITableViewScrollPositionTop
									  animated:YES];
		[self performSelector:@selector(activateTextFieldForRow:) withObject:[NSNumber numberWithInteger:3] afterDelay:0.2];
	}
	else
	{
		if (self.showRegistrationFields)
		{
//			[self registerAccount];
		}
		else
		{
			[self login];
		}
	}
	
	return NO;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	self.delegate = nil;
	self.keyboardObserver = nil;
	self.tableView = nil;
	self.cancelButton = nil;
	self.loginButton = nil;
	self.usernameField = nil;
	self.emailField = nil;
	self.passwordField = nil;
	self.passwordConfirmField = nil;
    [super dealloc];
}


@end
