#import "ISScalingActivityIndicatorView.h"
#import "UIColor+ISRefreshControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation ISScalingActivityIndicatorView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.color = [UIColor is_refreshControlColor];
    }
    return self;
}

- (void)startAnimating
{
    [super startAnimating];
    
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
                                              }];
                         }];
    });
}

- (void)stopAnimating
{
    [UIView animateWithDuration:.3f
                     animations:^{
                         [self.layer setValue:@0.01f forKeyPath:@"transform.scale"];
                     }
                     completion:^(BOOL finished) {
                         [super stopAnimating];
                     }];
}

@end
