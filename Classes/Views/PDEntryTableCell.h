@interface PDEntryTableCell : UITableViewCell {
	IBOutlet UIButton *checkboxButton;
	IBOutlet UILabel *textLabel;
}

@property (nonatomic, retain) IBOutlet UIButton *checkboxButton;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;

+ (PDEntryTableCell *)entryTableCell;

@end
