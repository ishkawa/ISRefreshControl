#import "UIActivityIndicatorView+ScaleAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIActivityIndicatorView (ScaleAnimation)

- (void)expandWithCompletion:(void (^)(BOOL))completion
{
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.4f
                         animations:^{
                             [self.layer setValue:@.7f forKeyPath:@"transform.scale"];
                         }
                         completion:completion];
    });
}

- (void)shrinkWithCompletion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:.3f
                     animations:^{
                         [self.layer setValue:@0.01f forKeyPath:@"transform.scale"];
                     }
                     completion:completion];
}

@end
