#import "PDKeyboardObserver.h"

@implementation PDKeyboardObserver

#pragma mark -
#pragma mark Initializing a Keyboard Observer

+ (PDKeyboardObserver *)keyboardObserverWithViewController:(UIViewController *)controller
												  delegate:(id <PDKeyboardObserverDelegate>)aDelegate
{
	return [[[self alloc] initWithViewController:controller delegate:aDelegate] autorelease];
}

- (id)initWithViewController:(UIViewController *)controller delegate:(id <PDKeyboardObserverDelegate>)aDelegate {
	if (![super init])
		return nil;
	
	self.viewController = controller;
	self.delegate = aDelegate;
	
	return self;
}

#pragma mark -
#pragma mark Subscribing to Keyboard Notifications

- (void)registerNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)unregisterNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

#pragma mark -
#pragma mark Handling Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)note {
	CGRect keyboardBounds;
	[[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardBounds];
	
	keyboardHeight = keyboardBounds.size.height;
	
	if (!self.isKeyboardShowing) {
		keyboardIsShowing = YES;
		
		CGRect frame = self.viewController.view.frame;
		frame.size.height -= keyboardHeight;
		
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		NSDictionary *info = [note userInfo];
		NSValue *value = [info valueForKey:UIKeyboardAnimationCurveUserInfoKey];
		UIViewAnimationCurve curve;
		[value getValue:&curve];
		[UIView setAnimationCurve:curve];
		
		value = [info valueForKey:UIKeyboardAnimationDurationUserInfoKey];
		NSTimeInterval duration;
		[value getValue:&duration];
		[UIView setAnimationDuration:duration];
		
		self.viewController.view.frame = frame;
		[UIView commitAnimations];
		
		[self.delegate keyboardObserverWillShowKeyboard:self];
	}
}

- (void)keyboardWillHide:(NSNotification *)note {
	if (self.isKeyboardShowing) {
		keyboardIsShowing = NO;
		
		CGRect frame = self.viewController.view.frame;
		frame.size.height += keyboardHeight;
		
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDelay:0.0f];
		self.viewController.view.frame = frame;
		
		[UIView commitAnimations];
	}
}

@end
