@interface PDTextFieldCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UITextField *textField;

+ (PDTextFieldCell *)textFieldCell;

@end
