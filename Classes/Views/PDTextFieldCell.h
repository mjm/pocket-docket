@interface PDTextFieldCell : UITableViewCell {
	IBOutlet UITextField *textField;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

+ (PDTextFieldCell *)textFieldCell;

@end
