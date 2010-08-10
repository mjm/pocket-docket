@protocol PDLoginViewControllerDelegate;

@interface PDLoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) id <PDLoginViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *loginButton;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITableViewCell *usernameCell;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;

- (IBAction)cancel;
- (IBAction)login;

@end


@protocol PDLoginViewControllerDelegate <NSObject>

- (void)loginControllerDidLogin:(PDLoginViewController *)controller;
- (void)loginControllerDidCancel:(PDLoginViewController *)controller;

@end