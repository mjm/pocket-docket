#import "PDLoginViewController.h"

#import "../Singletons/PDPersistenceController.h"
#import "../Singletons/PDSettingsController.h"
#import "../PDKeyboardObserver.h"
#import "../Views/PDTextFieldCell.h"
#import "../Models/User.h"

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
	
	self.title = NSLocalizedString(@"DocketAnywhere", nil);
	
	self.user = [[User alloc] init];
	self.user.login = [[PDSettingsController sharedSettingsController] docketAnywhereUsername];
	self.user.password = [[PDSettingsController sharedSettingsController] docketAnywherePassword];
	[self.user release];
	
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
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		return YES;
	}
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
    [self performSelector:@selector(activateTextFieldForRow:) withObject:[NSNumber numberWithInteger:0] afterDelay:0.2];
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
	NSString *username = self.user.login;
	NSString *password = self.user.password;
	Response *response = [Connection get:url withUser:username andPassword:password];
	
	[self performSelectorOnMainThread:@selector(handleLoginResponse:) withObject:response waitUntilDone:NO];
}

- (IBAction)login
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.cancelButton.enabled = self.loginButton.enabled = NO;
	[[ConnectionManager sharedInstance] runJob:@selector(doLogin) onTarget:self];
}

- (void)handleRegisterSuccess:(User *)aUser
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	PDSettingsController *settingsController = [PDSettingsController sharedSettingsController];
	settingsController.docketAnywhereUsername = aUser.login;
	settingsController.docketAnywherePassword = aUser.password;
	
	[[PDPersistenceController sharedPersistenceController] createFirstLaunchData];
	
	[self.delegate loginControllerDidRegister:self];
}

- (void)handleRegisterFailure:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Registration Failed", nil)
														message:NSLocalizedString(@"Registration Failed Message", nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
	
	self.cancelButton.enabled = self.registerButton.enabled = YES;
}

- (void)doRegister
{
	NSString *password = self.user.password;
	
	NSError *error = nil;
	if ([self.user createRemoteWithResponse:&error])
	{
		self.user.password = password;
		[self performSelectorOnMainThread:@selector(handleRegisterSuccess:) withObject:self.user waitUntilDone:YES];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(handleRegisterFailure:) withObject:error waitUntilDone:YES];
	}
}

- (IBAction)registerAccount
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.cancelButton.enabled = self.registerButton.enabled = NO;
	[[ConnectionManager sharedInstance] runJob:@selector(doRegister) onTarget:self];
}

- (IBAction)setFormMode:(UISegmentedControl *)sender
{
	self.usernameField = self.emailField = self.passwordField = self.passwordConfirmField = nil;
	
	if (sender.selectedSegmentIndex == 0)
	{
		self.showRegistrationFields = NO;
		self.user.login = [[PDSettingsController sharedSettingsController] docketAnywhereUsername];
		self.user.password = [[PDSettingsController sharedSettingsController] docketAnywherePassword];
		[self.navigationItem setRightBarButtonItem:self.loginButton animated:YES];
	}
	else
	{
		self.showRegistrationFields = YES;
		self.user.login = @"";
		self.user.email = @"";
		self.user.password = @"";
		self.user.passwordConfirmation = @"";
		[self.navigationItem setRightBarButtonItem:self.registerButton animated:YES];
	}

	[self.tableView reloadData];
    [self performSelector:@selector(activateTextFieldForRow:) withObject:[NSNumber numberWithInteger:0] afterDelay:0.2];
}

- (IBAction)textFieldChanged:(UITextField *)textField
{
	if (textField == self.usernameField)
	{
		self.user.login = textField.text;
	}
	else if (textField == self.emailField)
	{
		self.user.email = textField.text;
	}
	else if (textField == self.passwordField)
	{
		self.user.password = textField.text;
	}
	else
	{
		self.user.passwordConfirmation = textField.text;
	}
}

- (void)displayResetMessage:(NSString *)message
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Reset", nil)
														message:message
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)doResetPassword:(NSString *)username
{
	NSString *url = [NSString stringWithFormat:@"%@forgot/%@",
					 [ObjectiveResourceConfig getSite],
					 username];
	Response *response = [Connection get:url];
	
	NSString *alertMessage;
	if ([response isError])
	{
		alertMessage = NSLocalizedString(@"Password Reset Error Message", nil);
	}
	else
	{
		alertMessage = [[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding] autorelease];
	}
	
	[self performSelectorOnMainThread:@selector(displayResetMessage:) withObject:alertMessage waitUntilDone:YES];
}

- (void)forgotPassword
{
	NSString *username = self.usernameField.text;
	if (!username || [@"" isEqualToString:username])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Your Username", nil)
															message:NSLocalizedString(@"No Username Message", nil)
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
		return;
	}
	
	[[ConnectionManager sharedInstance] runJob:@selector(doResetPassword:) onTarget:self withArgument:username];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table
{
    return self.showRegistrationFields ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return self.showRegistrationFields ? 4 : (section == 0 ? 2 : 1);
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) return nil;
	return NSLocalizedString(self.showRegistrationFields ? @"Create an Account" : @"Login to DocketAnywhere", nil);
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"ForgotPassword"];
        if (!cell)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"ForgotPassword"] autorelease];
        }
        
        cell.textLabel.text = NSLocalizedString(@"Forgot Password", nil);
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        return cell;
    }
    
    
	static NSString *TextFieldCell = @"TextFieldCell";
	
	NSInteger passOffset = self.showRegistrationFields ? 2 : 1;
	
    PDTextFieldCell *cell = (PDTextFieldCell *) [table dequeueReusableCellWithIdentifier:TextFieldCell];
    if (!cell)
    {
        cell = [PDTextFieldCell textFieldCell];
    }
    cell.textField.delegate = self;
    cell.textField.returnKeyType = UIReturnKeyNext;
    cell.textField.textColor = [UIColor colorWithRed:56/255.0 green:84/255.0 blue:135/255.0 alpha:1.0];
    [cell.textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        cell.leftIndent = 75;
    }
	
	if (0 == indexPath.row)
	{
		cell.label.text = NSLocalizedString(@"Username", nil);
		self.usernameField = cell.textField;
		
		self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
		if (self.user.login)
		{
			self.usernameField.text = self.user.login;
		}
		else
		{
			self.usernameField.text = @"";
		}
	}
	else if (self.showRegistrationFields && 1 == indexPath.row)
	{
		cell.label.text = NSLocalizedString(@"Email", nil);
		self.emailField = cell.textField;
		
		self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
		
		if (self.user.email)
		{
			self.emailField.text = self.user.email;
		}
		else
		{
			self.emailField.text = @"";
		}
	}
	else if (passOffset == indexPath.row) 
	{
		cell.label.text = NSLocalizedString(@"Password", nil);
		self.passwordField = cell.textField;
		
		self.passwordField.secureTextEntry = YES;
		
		if (self.user.password)
		{
			self.passwordField.text = self.user.password;
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
		cell.label.text = NSLocalizedString(@"Confirm", nil);
		self.passwordConfirmField = cell.textField;
		
		self.passwordConfirmField.returnKeyType = UIReturnKeyGo;
		self.passwordConfirmField.secureTextEntry = YES;
		
		if (self.user.passwordConfirmation)
		{
			self.passwordConfirmField.text = self.user.passwordConfirmation;
		}
		else
		{
			self.passwordConfirmField.text = @"";
		}
	}
	
	return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[table deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1)
    {
        [self forgotPassword];
        return;
    }
    
	PDTextFieldCell *cell = (PDTextFieldCell *) [table cellForRowAtIndexPath:indexPath];
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
			[self registerAccount];
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
	self.user = nil;
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
