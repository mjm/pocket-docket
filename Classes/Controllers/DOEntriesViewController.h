@class PDList;

@interface DOEntriesViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
	PDList *list;
	
	UIPopoverController *popoverController;
	IBOutlet UIToolbar *toolbar;
}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@end
