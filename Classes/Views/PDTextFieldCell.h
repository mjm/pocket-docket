@interface PDTextFieldCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, assign) NSInteger leftIndent;

+ (PDTextFieldCell *)textFieldCell;

@end
