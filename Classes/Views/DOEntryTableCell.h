#define ENTRY_CELL_OFFSET 68

@interface DOEntryTableCell : UITableViewCell
{
	BOOL isIndented;
}

@property (nonatomic, retain) IBOutlet UIButton *checkboxButton;
@property (nonatomic, retain) IBOutlet UIImageView *checkboxImage;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UILabel *commentLabel;

+ (DOEntryTableCell *)entryTableCell;

@end
