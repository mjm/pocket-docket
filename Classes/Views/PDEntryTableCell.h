@interface PDEntryTableCell : UITableViewCell
{
	BOOL isIndented;
}

@property (nonatomic, retain) IBOutlet UIButton *checkboxButton;
@property (nonatomic, retain) IBOutlet UIImageView *checkboxImage;
@property (nonatomic, retain) IBOutlet UILabel *entryLabel;

+ (PDEntryTableCell *)entryTableCell;

@end
