@interface PDTextFieldCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UITextField *textField;

+ (PDTextFieldCell *)textFieldCell;

@end
