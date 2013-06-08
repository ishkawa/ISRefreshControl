#import "ISScalingActivityIndicatorView.h"
#import "UIColor+ISRefreshControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation ISScalingActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.color = [UIColor is_refreshControlColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.color = [UIColor is_refreshControlColor];
    }
    return self;
}

- (void)startAnimating
{
    [super startAnimating];
    
    self.transform = CGAffineTransformIdentity;
    self.layer.transform = CATransform3DMakeScale(.7f, .7f, .7f);
    
    NSTimeInterval duration = .4;
    
    CAKeyframeAnimation *scaleXAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleXAnimation.duration = duration;
    scaleXAnimation.values = @[@.01f, @.85f, @.7f];
    [self.layer addAnimation:scaleXAnimation forKey:@"scaleXAnimation"];
    
    CAKeyframeAnimation *scaleYAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleYAnimation.duration = duration;
    scaleYAnimation.values = @[@.01f, @.85f, @.7f];
    [self.layer addAnimation:scaleYAnimation forKey:@"scaleYAnimation"];
    
    CABasicAnimation *rotatingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotatingAnimation.duration = duration * .8;
    rotatingAnimation.fromValue = @(-M_PI * .8);
    rotatingAnimation.toValue = @(.0);
    rotatingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.layer addAnimation:rotatingAnimation forKey:@"rotatingAnimation"];
}

- (void)stopAnimating
{
    if (self.superview == nil) {
        return;
    }
    
    NSTimeInterval duration = .255;
    
    CABasicAnimation *scaleXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleXAnimation.duration = duration;
    scaleXAnimation.fromValue = @.7f;
    scaleXAnimation.toValue = @.01f;
    scaleXAnimation.delegate = self;
    [self.layer addAnimation:scaleXAnimation forKey:@"scaleXAnimation"];
    
    CABasicAnimation *scaleYAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleYAnimation.duration = duration;
    scaleYAnimation.fromValue = @.7f;
    scaleYAnimation.toValue = @.01f;
    [self.layer addAnimation:scaleYAnimation forKey:@"scaleYAnimation"];
    
    CABasicAnimation *rotatingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotatingAnimation.duration = duration;
    rotatingAnimation.fromValue = @(.0);
    rotatingAnimation.toValue = @(M_PI * .3);
    rotatingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.layer addAnimation:rotatingAnimation forKey:@"rotatingAnimation"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished
{
    [super stopAnimating];
}

@end
