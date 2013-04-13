#import <UIKit/UIKit.h>

@interface ISGumView : UIView

@property (nonatomic) BOOL shrinking;
@property (nonatomic) CGFloat distance;
@property (nonatomic, strong) UIColor *tintColor;

- (void)shrink;

@end
