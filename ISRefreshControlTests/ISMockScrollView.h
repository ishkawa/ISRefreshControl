#import <UIKit/UIKit.h>

@interface ISMockScrollView : UIScrollView

@property (nonatomic, getter=isTracking)     BOOL tracking;
@property (nonatomic, getter=isDragging)     BOOL dragging;
@property (nonatomic, getter=isDecelerating) BOOL decelerating;

@end
