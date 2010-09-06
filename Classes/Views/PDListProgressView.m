#import "PDListProgressView.h"

@interface PDListProgressView ()

- (void)drawAndReleaseImage:(CGImageRef)imageRef inRect:(CGRect)rect;

@end

@implementation PDListProgressView

- (void)setProgress:(CGFloat)aProgress
{
    progress = aProgress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	CGFloat len = 32;
	CGRect fullRect = CGRectMake(0, 0, len, len);
	CGRect topHalf = CGRectMake(0, 0, len, len * (1.0 - self.progress));
	CGRect bottomHalf = CGRectMake(0, topHalf.size.height, len, len * self.progress);

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_2
	CGFloat len2;
	if ([self respondsToSelector:@selector(contentScaleFactor)]) {
		len2 = len * self.contentScaleFactor;
	} else {
		len2 = len;
	}
	
	void * volatile fp = (void *)&(UIGraphicsBeginImageContextWithOptions);
	if (fp != NULL) {
		UIGraphicsBeginImageContextWithOptions(fullRect.size, NO, 0.0);
	} else {
		UIGraphicsBeginImageContext(fullRect.size);
	}
#else
	CGFloat len2 = len;
	UIGraphicsBeginImageContext(fullRect.size);
#endif
#endif

	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(ctx, 255, 255, 255, 0);
	CGContextFillRect(ctx, rect);
	
	CGRect topHalfBig = CGRectMake(0, 0, len2, len2 * (1.0 - self.progress));
	CGRect bottomHalfBig = CGRectMake(0, topHalfBig.size.height, len2, len2 * self.progress);
	
	UIImage *image = [UIImage imageNamed:@"ListIcon.png"];
	CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, topHalfBig);
	[self drawAndReleaseImage:cgImage inRect:topHalf];
	
	image = [UIImage imageNamed:@"ListIconDark.png"];
	cgImage = CGImageCreateWithImageInRect(image.CGImage, bottomHalfBig);
	[self drawAndReleaseImage:cgImage inRect:bottomHalf];
	
	UIImage *completeImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[completeImage drawInRect:fullRect];
}

- (void)drawAndReleaseImage:(CGImageRef)imageRef inRect:(CGRect)rect {
	UIImage *image = [UIImage imageWithCGImage:imageRef];
	[image drawInRect:rect];
	CGImageRelease(imageRef);
}

@end
