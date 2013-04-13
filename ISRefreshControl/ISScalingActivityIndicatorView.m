#import "ISScalingActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ISScalingActivityIndicatorView

- (void)expandWithCompletion:(void (^)(BOOL))completion
{
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.2
                         animations:^{
                             [self.layer setValue:@.8f forKeyPath:@"transform.scale"];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.2
                                              animations:^{
                                                  [self.layer setValue:@.7f forKeyPath:@"transform.scale"];
                                              }
                                              completion:completion];
                         }];
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
