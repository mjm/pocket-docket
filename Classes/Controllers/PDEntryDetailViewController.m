#import "PDEntryDetailViewController.h"

#import "../Models/PDListEntry.h"
#import "../Views/PDTextFieldCell.h"
#import "../Views/PDTextViewCell.h"
#import "PDCommentViewController.h"
#import "../PDPersistenceController.h"

@implementation PDEntryDetailViewController

@synthesize entry, persistenceController, keyboardObserver;
@synthesize table, saveButton;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithEntry:(PDListEntry *)aEntry persistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDEntryDetailView" bundle:nil])
		return nil;
	
	self.entry = aEntry;
	self.persistenceController = controller;
	self.keyboardObserver = [[PDKeyboardObserver alloc] initWithViewController:self delegate:nil];
	
	self.title = @"Edit Entry";
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([keyboardObserver isKeyboardShowing]) {
		return NO;
	} else {
		// adjusts the table view cells
		[self.table performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
		return YES;
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.table = nil;
	self.saveButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[keyboardObserver registerNotifications];
	
	if (!editingComment) {
		[self.persistenceController.undoManager beginUndoGrouping];
	} else {
		editingComment = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[self.table reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[keyboardObserver unregisterNotifications];
	
	if (!editingComment) {
		// We are going back to the entry list, so either save or undo changes.
		[self.persistenceController.undoManager endUndoGrouping];
		if (didSave) {
			[self.persistenceController save];
			didSave = NO;
		} else {
			[self.persistenceController.undoManager undo];
		}
	}
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 2;
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
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
			if (self.entry.comment && [self.entry.comment length] > 0) {
				cell.paragraphLabel.font = [UIFont systemFontOfSize:17.0];
				cell.paragraphLabel.textColor = [UIColor blackColor];
			} else {
				cell.paragraphLabel.text = @"No comment. Tap to add one.";
				cell.paragraphLabel.font = [UIFont italicSystemFontOfSize:17.0];
				cell.paragraphLabel.textColor = [UIColor darkGrayColor];
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
		}
	} else {
		static NSString *Cell = @"DeleteButton";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell] autorelease];
		}
		
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = @"Delete Entry";
		
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
	
	return MAX(size.height + 20.0f, 44.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			PDTextFieldCell *cell = (PDTextFieldCell *) [self.table cellForRowAtIndexPath:indexPath];
			[cell.textField becomeFirstResponder];
		} else {
			editingComment = YES;
			
			PDCommentViewController *controller = [[PDCommentViewController alloc] initWithComment:self.entry.comment];
			controller.delegate = self;
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
		}
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Entry"
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:@"Delete Entry"
														otherButtonTitles:nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
}

#pragma mark -
#pragma mark Comment Controller Delegate Methods

- (void)commentController:(PDCommentViewController *)controller commentDidChange:(NSString *)comment {
	self.entry.comment = comment;
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [actionSheet destructiveButtonIndex]) {
		[self.persistenceController deleteEntry:self.entry];
		didSave = YES;
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	self.entry.text = textField.text;
	
	return NO;
}

#pragma mark -
#pragma mark Actions

- (IBAction)saveEntry {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	PDTextFieldCell *cell = (PDTextFieldCell *) [self.table cellForRowAtIndexPath:indexPath];
	self.entry.text = cell.textField.text;
	
	didSave = YES;
	
	// TODO don't like doing this from the controller being popped.
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.entry = nil;
	self.persistenceController = nil;
	self.keyboardObserver = nil;
	self.table = nil;
	self.saveButton = nil;
	[super dealloc];
}

@end
