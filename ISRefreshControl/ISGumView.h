#import <UIKit/UIKit.h>

@interface ISGumView : UIView

@property (nonatomic) BOOL shrinking;
@property (nonatomic) CGFloat distance;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, readonly) UIBezierPath *bezierPath;

- (void)shrink;

@end
