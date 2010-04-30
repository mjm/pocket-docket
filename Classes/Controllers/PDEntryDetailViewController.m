#import "PDEntryDetailViewController.h"

#import "../Models/PDListEntry.h"
#import "../Views/PDTextFieldCell.h"
#import "../Views/PDTextViewCell.h"
#import "PDCommentViewController.h"
#import "../PDPersistenceController.h"

@implementation PDEntryDetailViewController

@synthesize entry, persistenceController, keyboardObserver;
@synthesize table, cancelButton;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithEntry:(PDListEntry *)aEntry persistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDEntryDetailView" bundle:nil])
		return nil;
	
	self.entry = aEntry;
	self.persistenceController = controller;
	self.keyboardObserver = [[PDKeyboardObserver alloc] initWithViewController:self delegate:nil];
	
	self.title = self.entry.text;
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	[self.entry addObserver:self
				 forKeyPath:@"text"
					options:NSKeyValueObservingOptionNew
					context:NULL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// adjusts the table view cells
	[self.table performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
	return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.table = nil;
	self.cancelButton = nil;
	
	[self.entry removeObserver:self forKeyPath:@"text"];
}

- (void)viewDidAppear:(BOOL)animated {
	[self.table reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.table setEditing:editing animated:animated];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	PDTextFieldCell *cell = (PDTextFieldCell *) [self.table cellForRowAtIndexPath:indexPath];
	
	if (editing) {
		[self.persistenceController.undoManager beginUndoGrouping];
		self.navigationItem.hidesBackButton = YES;
		[self.navigationItem setLeftBarButtonItem:self.cancelButton animated:animated];
	} else {
		self.entry.text = cell.textField.text;
		[cell.textField resignFirstResponder];
		
		[self.persistenceController.undoManager endUndoGrouping];
		if (didCancel) {
			[self.persistenceController.undoManager undo];
			didCancel = NO;
		} else {
			[self.persistenceController save];
		}
		[self.navigationItem setLeftBarButtonItem:nil animated:animated];
		self.navigationItem.hidesBackButton = NO;
	}
	
	[self.table beginUpdates];
	if (editing) {
		[self.table insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	} else {
		[self.table deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	}
	[self.table endUpdates];
	
	[self.table beginUpdates];
	[self.table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	[self.table endUpdates];
	
	if (editing) {
		// cell will have changed since earlier.
		cell = (PDTextFieldCell *) [self.table cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
	}
}

#pragma mark -
#pragma mark Handling Model Changes

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if ([keyPath isEqual:@"text"]) {
		self.navigationItem.title = [change objectForKey:NSKeyValueChangeNewKey];
	}
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.editing ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 2;
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		static NSString *TextViewCell = @"TextView";
		if (indexPath.row == 0) {
			static NSString *Cell = @"TextField";
			
			if (self.editing) {
				PDTextFieldCell *cell = (PDTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:Cell];
				if (!cell) {
					cell = [PDTextFieldCell textFieldCell];
				}
				
				cell.textField.text = self.entry.text;
				cell.textField.delegate = self;
				cell.textField.enabled = self.editing;
				
				return cell;
			} else {
				PDTextViewCell *cell = (PDTextViewCell *) [tableView dequeueReusableCellWithIdentifier:TextViewCell];
				if (!cell) {
					cell = [[[PDTextViewCell alloc] initWithReuseIdentifier:TextViewCell] autorelease];
				}
				
				cell.paragraphLabel.text = self.entry.text;
				cell.paragraphLabel.font = [UIFont systemFontOfSize:17.0];
				cell.paragraphLabel.textColor = [UIColor blackColor];
				cell.accessoryType = UITableViewCellAccessoryNone;
				
				return cell;
			}
		} else {
			
			PDTextViewCell *cell = (PDTextViewCell *) [tableView dequeueReusableCellWithIdentifier:TextViewCell];
			if (!cell) {
				cell = [[[PDTextViewCell alloc] initWithReuseIdentifier:TextViewCell] autorelease];
			}
			
			cell.paragraphLabel.text = self.entry.comment;
			if (self.entry.comment && [self.entry.comment length] > 0) {
				cell.paragraphLabel.font = [UIFont systemFontOfSize:17.0];
				cell.paragraphLabel.textColor = [UIColor blackColor];
			} else {
				cell.paragraphLabel.text = self.editing ? @"No comment. Tap to add one." : @"No comment.";
				cell.paragraphLabel.font = [UIFont italicSystemFontOfSize:17.0];
				cell.paragraphLabel.textColor = [UIColor darkGrayColor];
			}
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
		}
	} else {
		static NSString *Cell = @"DeleteButton";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:Cell] autorelease];
		}
		
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = @"Delete Entry";
		
		return cell;
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0 && self.editing) {
		return 44.0f;
	}
	
	NSString *text = indexPath.row == 0 ? self.entry.text : self.entry.comment;
	CGFloat width = self.view.frame.size.width;
	CGSize constraint = CGSizeMake(width - 40.0f, 20000.0f);
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17.0f]
				   constrainedToSize:constraint
					   lineBreakMode:UILineBreakModeWordWrap];
	
	return MAX(size.height + 20.0f, 44.0f);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return self.editing ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			PDTextFieldCell *cell = (PDTextFieldCell *) [self.table cellForRowAtIndexPath:indexPath];
			[cell.textField becomeFirstResponder];
		} else {
			NSIndexPath *textIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
			PDTextFieldCell *cell = (PDTextFieldCell *) [self.table cellForRowAtIndexPath:textIndexPath];
			self.entry.text = cell.textField.text;
			
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
		[self.persistenceController.undoManager endUndoGrouping];
		[self.persistenceController save];
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

- (IBAction)cancelEditing {
	didCancel = YES;
	[self setEditing:NO animated:YES];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.entry = nil;
	self.persistenceController = nil;
	self.keyboardObserver = nil;
	self.table = nil;
	self.cancelButton = nil;
	[super dealloc];
}

@end
