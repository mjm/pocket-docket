#define ENTRY_CELL_OFFSET 68

@interface DOEntryTableCell : UITableViewCell {
	IBOutlet UIButton *checkboxButton;
	IBOutlet UILabel *textLabel;
	IBOutlet UILabel *commentLabel;
}

@property (nonatomic, retain) IBOutlet UIButton *checkboxButton;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UILabel *commentLabel;

+ (DOEntryTableCell *)entryTableCell;

@end
