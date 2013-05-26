#import "ISScalingActivityIndicatorView.h"
#import "UIColor+ISRefreshControl.h"

@implementation ISScalingActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.color = [UIColor is_refreshControlColor];
        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.color = [UIColor is_refreshControlColor];
        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
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
                             self.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.2
                                              animations:^{
                                                  self.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
                                              }];
                         }];
    });
}

- (void)stopAnimating
{
    if (self.superview == nil) {
        return;
    }
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                     }
                     completion:^(BOOL finished) {
                         [super stopAnimating];
                     }];
}

@end
