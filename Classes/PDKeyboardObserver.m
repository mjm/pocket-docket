#import "PDKeyboardObserver.h"

#define GET_VALUE(type, var, dict, key) \
	NSValue* _value##var = [dict valueForKey:key]; \
	type var; \
	[_value##var getValue:&var];

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
	NSDictionary *info = [note userInfo];
	GET_VALUE(CGRect, keyboardBounds, info, UIKeyboardBoundsUserInfoKey);
	
	keyboardHeight = keyboardBounds.size.height;
	
	if (!self.isKeyboardShowing) {
		keyboardIsShowing = YES;
		
		CGRect frame = self.viewController.view.frame;
		frame.size.height -= keyboardHeight;
		
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		
		GET_VALUE(UIViewAnimationCurve, curve, info, UIKeyboardAnimationCurveUserInfoKey);
		[UIView setAnimationCurve:curve];
		GET_VALUE(NSTimeInterval, duration, info, UIKeyboardAnimationDurationUserInfoKey);
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
		
		NSDictionary *info = [note userInfo];
		GET_VALUE(UIViewAnimationCurve, curve, info, UIKeyboardAnimationCurveUserInfoKey);
		[UIView setAnimationCurve:curve];
		GET_VALUE(NSTimeInterval, duration, info, UIKeyboardAnimationDurationUserInfoKey);
		[UIView setAnimationDuration:duration];
		
		self.viewController.view.frame = frame;
		
		[UIView commitAnimations];
	}
}

@end
