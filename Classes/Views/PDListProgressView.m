#import "PDListProgressView.h"

@implementation PDListProgressView

@synthesize progress;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
	
	self.progress = 0.5;
	
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(ctx, 255, 255, 255, 0);
	CGContextFillRect(ctx, rect);

	CGRect topHalf = CGRectMake(0, 0, 32, 32 * (1.0 - self.progress));
	CGRect bottomHalf = CGRectMake(0, topHalf.size.height, 32, 32 * self.progress);
	
	UIImage *image = [UIImage imageNamed:@"ListIcon.png"];
	CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, topHalf);
	
	image = [UIImage imageWithCGImage:cgImage];
	[image drawInRect:topHalf];
	CGImageRelease(cgImage);
	
	image = [UIImage imageNamed:@"ListIconDark.png"];
	cgImage = CGImageCreateWithImageInRect(image.CGImage, bottomHalf);
	
	image = [UIImage imageWithCGImage:cgImage];
	[image drawInRect:bottomHalf];
	CGImageRelease(cgImage);
}

- (void)dealloc {
    [super dealloc];
}

@end
