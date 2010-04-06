#import "PDEntryDetailViewController.h"

#import "../Models/PDListEntry.h"
#import "../Views/PDTextFieldCell.h"
#import "../Views/PDTextViewCell.h"
#import "PDCommentViewController.h"
#import "../PDPersistenceController.h"

@implementation PDEntryDetailViewController

@synthesize entry, persistenceController;
@synthesize table;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithEntry:(PDListEntry *)aEntry persistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDEntryDetailView" bundle:nil])
		return nil;
	
	self.entry = aEntry;
	self.persistenceController = controller;
	
	self.title = @"Edit Entry";
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// adjusts the table view cells
	[self.table performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.table = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[self.table reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)note {
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardBounds];
	
	keyboardHeight = keyboardBounds.size.height;
	
	if (!keyboardIsShowing) {
		keyboardIsShowing = YES;
		
		CGRect frame = self.view.frame;
		frame.size.height -= keyboardHeight;
		
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		NSDictionary *info = [note userInfo];
		NSValue *value = [info valueForKey:UIKeyboardAnimationCurveUserInfoKey];
		UIViewAnimationCurve curve;
		[value getValue:&curve];
		[UIView setAnimationCurve:curve];
		
		value = [info valueForKey:UIKeyboardAnimationDurationUserInfoKey];
		NSTimeInterval duration;
		[value getValue:&duration];
		[UIView setAnimationDuration:duration];
		
		self.view.frame = frame;
		
		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification *)note {
	if (keyboardIsShowing) {
		keyboardIsShowing = NO;
		
		CGRect frame = self.view.frame;
		frame.size.height += keyboardHeight;
		
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDelay:0.0f];
		self.view.frame = frame;
		
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		static NSString *Cell = @"TextField";
		
		PDTextFieldCell *cell = (PDTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:Cell];
		if (!cell) {
			cell = [PDTextFieldCell textFieldCell];
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textField.text = self.entry.text;
		
		return cell;
	} else {
		static NSString *Cell = @"TextView";
		
		PDTextViewCell *cell = (PDTextViewCell *) [tableView dequeueReusableCellWithIdentifier:Cell];
		if (!cell) {
			cell = [[[PDTextViewCell alloc] initWithReuseIdentifier:Cell] autorelease];
		}
		
		cell.paragraphLabel.text = self.entry.comment;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return 44.0f;
	}
	
	NSString *text = self.entry.comment;
	CGFloat width = self.view.frame.size.width;
	CGSize constraint = CGSizeMake(width - 40.0f, 20000.0f);
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17.0f]
				   constrainedToSize:constraint
					   lineBreakMode:UILineBreakModeWordWrap];
	
	CGFloat height = MAX(size.height + 20.0f, 44.0f);
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 1) {
		PDCommentViewController *controller = [[PDCommentViewController alloc] initWithComment:self.entry.comment];
		controller.delegate = self;
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}

#pragma mark -
#pragma mark Comment Controller Delegate Methods

- (void)commentController:(PDCommentViewController *)controller commentDidChange:(NSString *)comment {
	self.entry.comment = comment;
	[self.persistenceController save];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.entry = nil;
	self.persistenceController = nil;
	self.table = nil;
    [super dealloc];
}

@end
