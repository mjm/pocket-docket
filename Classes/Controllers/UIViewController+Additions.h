#import "PDLoginViewController.h"

@interface UIViewController (Additions) <PDLoginViewControllerDelegate>

- (void)presentLoginViewController;
- (BOOL)shouldPresentLoginViewController;

@end
