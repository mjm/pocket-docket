@interface PDTextViewCell : UITableViewCell {

}

@property (nonatomic, readonly) UILabel *paragraphLabel;

- (id)initWithReuseIdentifier:(NSString *)identifier;

@end
