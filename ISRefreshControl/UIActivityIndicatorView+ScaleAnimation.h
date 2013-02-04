#import <UIKit/UIKit.h>

@interface UIActivityIndicatorView (ScaleAnimation)

- (void)expandWithCompletion:(void (^)(BOOL finished))completion;
- (void)shrinkWithCompletion:(void (^)(BOOL finished))completion;

@end
