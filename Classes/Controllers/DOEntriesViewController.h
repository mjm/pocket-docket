@interface DOEntriesViewController : UIViewController <UISplitViewControllerDelegate> {
	UIPopoverController *popoverController;
	IBOutlet UIToolbar *toolbar;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@end
