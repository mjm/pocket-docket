#import "PDImportEntriesViewController.h"

#import "../PDKeyboardObserver.h"
#import "../PDListParser.h"
#import "../Singletons/PDPersistenceController.h"
#import "PDListEntry.h"
#import "PDList.h"


@implementation PDImportEntriesViewController

- (id)initWithList:(PDList *)aList
{
	if (![super initWithNibName:@"PDImportEntriesView" bundle:nil])
		return nil;
	
	if ([[UIPasteboard generalPasteboard] containsPasteboardTypes:UIPasteboardTypeListString])
	{
		self.importText = [[UIPasteboard generalPasteboard] string];
	}
	else
	{
		self.importText = @"";
	}
	self.list = aList;
	self.title = NSLocalizedString(@"Import Entries", nil);
	self.keyboardObserver = [PDKeyboardObserver keyboardObserverWithViewController:self delegate:nil];
	
	return self;
}



#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.textView.text = self.importText;
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.importButton;
	self.navigationItem.prompt = @"Paste the entries from your email.";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.keyboardObserver registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.keyboardObserver unregisterNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.textView = nil;
}



#pragma mark -
#pragma mark Actions

- (IBAction)cancelImport
{
	[self.delegate dismissImportEntriesController:self];
}

- (IBAction)importEntries
{
	PDListParser *listParser = [[PDListParser alloc] init];
	self.importText = self.textView.text;
	NSArray *entries = [listParser parseListEntriesFromString:self.importText];
	[listParser release];
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	for (NSDictionary *entryDict in entries)
	{
		PDListEntry *entry = [persistenceController createEntry:[entryDict valueForKey:@"text"]
														 inList:self.list];
		entry.checked = [entryDict valueForKey:@"checked"];
		if ([entryDict valueForKey:@"comment"])
			entry.comment = [entryDict valueForKey:@"comment"];
	}
	[persistenceController save];
	[persistenceController.managedObjectContext refreshObject:self.list mergeChanges:YES];
	
	[self.delegate dismissImportEntriesController:self];
}



#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	self.importText = nil;
	self.textView = nil;
	self.cancelButton = nil;
	self.importButton = nil;
	self.keyboardObserver = nil;
    [super dealloc];
}


@end
