@interface PDEntryTableCell : UITableViewCell {}

@property (nonatomic, retain) IBOutlet UIButton *checkboxButton;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;

+ (PDEntryTableCell *)entryTableCell;

@end
