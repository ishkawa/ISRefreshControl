#import <UIKit/UIKit.h>

@interface ISScalingActivityIndicatorView : UIActivityIndicatorView

- (void)expandWithCompletion:(void (^)(BOOL finished))completion;
- (void)shrinkWithCompletion:(void (^)(BOOL finished))completion;

@end
