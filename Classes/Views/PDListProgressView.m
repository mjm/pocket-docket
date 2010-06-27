#import "PDListProgressView.h"

@implementation PDListProgressView

- (void)drawRect:(CGRect)rect {
	CGFloat len = 32;
	CGFloat len2;
	if ([self respondsToSelector:@selector(contentScaleFactor)]) {
		len2 = len * self.contentScaleFactor;
	} else {
		len2 = len;
	}
	
	void * volatile fp = (void *)&(UIGraphicsBeginImageContextWithOptions);
	if (fp != NULL) {
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(len, len), NO, 0.0);
	} else {
		UIGraphicsBeginImageContext(CGSizeMake(len, len));
	}
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(ctx, 255, 255, 255, 0);
	CGContextFillRect(ctx, rect);
	
	CGRect topHalf = CGRectMake(0, 0, len, len * (1.0 - self.progress));
	CGRect topHalfBig = CGRectMake(0, 0, len2, len2 * (1.0 - self.progress));
	CGRect bottomHalf = CGRectMake(0, topHalf.size.height, len, len * self.progress);
	CGRect bottomHalfBig = CGRectMake(0, topHalfBig.size.height, len2, len2 * self.progress);
	
	UIImage *image = [UIImage imageNamed:@"ListIcon.png"];
	CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, topHalfBig);
	
	image = [UIImage imageWithCGImage:cgImage];
	[image drawInRect:topHalf];
	CGImageRelease(cgImage);
	
	image = [UIImage imageNamed:@"ListIconDark.png"];
	cgImage = CGImageCreateWithImageInRect(image.CGImage, bottomHalfBig);
	
	image = [UIImage imageWithCGImage:cgImage];
	[image drawInRect:bottomHalf];
	CGImageRelease(cgImage);
	
	UIImage *completeImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[completeImage drawInRect:CGRectMake(0, 0, len, len)];
}

@end
