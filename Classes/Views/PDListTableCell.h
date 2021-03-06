@class PDListProgressView;

//! A table cell used to show one of the user's lists.
/*!
 
 Displays an image to show the completion level of the list, as well as a label with the
 title of the list and a label showing the number of completed items.
 
 \nosubgrouping
 */
@interface PDListTableCell : UITableViewCell {}

@property (nonatomic, retain) IBOutlet PDListProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *completionLabel;

//! \name Creating Table Cells
//@{

+ (PDListTableCell *)listTableCell;

//@}

@end
