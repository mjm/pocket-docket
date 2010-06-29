@protocol PDKeyboardObserverDelegate;

//! Watches for keyboard notifications and adjusts a view controller's frame.
/*!
 
 The observer ensures that the view controller's view does not get hidden behind the keyboard
 view. It also has support for a delegate which can be used to perform actions when the keyboard
 is shown.
 
 */
@interface PDKeyboardObserver : NSObject {
	CGFloat keyboardHeight;
	BOOL keyboardIsShowing;
}

@property (nonatomic, assign) id <PDKeyboardObserverDelegate> delegate;
@property (nonatomic, assign) UIViewController *viewController;
@property (nonatomic, getter=isKeyboardShowing, readonly) BOOL keyboardIsShowing;

+ (PDKeyboardObserver *)keyboardObserverWithViewController:(UIViewController *)controller
												  delegate:(id <PDKeyboardObserverDelegate>)aDelegate;
- (id)initWithViewController:(UIViewController *)controller delegate:(id <PDKeyboardObserverDelegate>)aDelegate;

- (void)registerNotifications;
- (void)unregisterNotifications;

@end

@protocol PDKeyboardObserverDelegate

- (void)keyboardObserverWillShowKeyboard:(PDKeyboardObserver *)observer;

@end