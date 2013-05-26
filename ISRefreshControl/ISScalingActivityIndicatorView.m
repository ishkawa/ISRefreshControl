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
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-M_PI_2);
    CGAffineTransform scale = CGAffineTransformMakeScale(0.01f, 0.01f);
    self.transform = CGAffineTransformConcat(rotation, scale);
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
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
    
    [UIView animateWithDuration:.255f
                     animations:^{
                         CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI_2);
                         CGAffineTransform scale = CGAffineTransformMakeScale(0.01f, 0.01f);
                         self.transform = CGAffineTransformConcat(rotation, scale);
                     }
                     completion:^(BOOL finished) {
                         [super stopAnimating];
                     }];
}

@end
