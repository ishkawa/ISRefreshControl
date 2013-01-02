#import <UIKit/UIKit.h>

@interface ISGumView : UIView

@property CGFloat distance;
@property BOOL shrinking;
@property (nonatomic, strong) UIColor *tintColor;

- (void)shrink;

@end
