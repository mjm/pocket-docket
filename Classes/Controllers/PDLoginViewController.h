@class PDKeyboardObserver;
@class User;

@protocol PDLoginViewControllerDelegate;

@interface PDLoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) id <PDLoginViewControllerDelegate> delegate;
@property (nonatomic, retain) PDKeyboardObserver *keyboardObserver;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *loginButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *registerButton;
@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UITextField *passwordConfirmField;

- (IBAction)cancel;
- (IBAction)login;
- (IBAction)registerAccount;

- (IBAction)setFormMode:(UISegmentedControl *)sender;
- (IBAction)textFieldChanged:(UITextField *)textField;

@end


@protocol PDLoginViewControllerDelegate <NSObject>

- (void)loginControllerDidLogin:(PDLoginViewController *)controller;
- (void)loginControllerDidRegister:(PDLoginViewController *)controller;
- (void)loginControllerDidCancel:(PDLoginViewController *)controller;

@end