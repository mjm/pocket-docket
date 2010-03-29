#import "PDEntriesTableView.h"

@implementation PDEntriesTableView

#define HORIZ_SWIPE_DRAG_MIN 70

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([self isEditing]) {
		[super touchesBegan:touches withEvent:event];
		return;
	}
	
    UITouch *touch = [touches anyObject];
	CGPoint newTouchPosition = [touch locationInView:self];
	
	if (startTouchPosition.x != newTouchPosition.x || startTouchPosition.y != newTouchPosition.y) {
		processingSwipe = NO;
	}
	
	startTouchPosition = [touch locationInView:self];
	[super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([self isEditing]) {
		[super touchesMoved:touches withEvent:event];
		return;
	}
	
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
	
    // If the swipe tracks correctly.
	double diffx = startTouchPosition.x - currentTouchPosition.x + 0.1; // adding 0.1 to avoid division by zero
	double diffy = startTouchPosition.y - currentTouchPosition.y + 0.1; // adding 0.1 to avoid division by zero
    
    if (abs(diffx / diffy) > 1 && abs(diffx) > HORIZ_SWIPE_DRAG_MIN) {
        // It appears to be a swipe.
		if (processingSwipe) {
			// ignore move, we're currently processing the swipe
			return;
		}
		
		processingSwipe = YES;
		if ([self.delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)]) {
			[self.delegate performSelector:@selector(tableView:didSwipeCellAtIndexPath:)
								withObject:self
								withObject:[self indexPathForRowAtPoint:startTouchPosition]];
		}
    } else if (abs(diffy / diffx) > 1) {
		processingSwipe = YES;
		[super touchesMoved:touches	withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([self isEditing]) {
		[super touchesEnded:touches withEvent:event];
		return;
	}
	
	processingSwipe = NO;
	[super touchesEnded:touches withEvent:event];
}

@end
