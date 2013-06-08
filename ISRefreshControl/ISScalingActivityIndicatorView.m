#import "ISScalingActivityIndicatorView.h"
#import "UIColor+ISRefreshControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation ISScalingActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    if ([self respondsToSelector:@selector(setColor:)]) {
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.color = [UIColor is_refreshControlColor];
        self.layer.transform = CATransform3DMakeScale(.7f, .7f, .7f);
    } else {
        // iOS 4.x
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}

- (void)startAnimating
{
    [super startAnimating];
    
    
    NSArray *scaleValues;
    if (self.activityIndicatorViewStyle == UIActivityIndicatorViewStyleWhiteLarge) {
        scaleValues = @[@.01f, @.85f, @.7f];
    } else {
        scaleValues = @[@.01f, @1.2f, @1.f];
    }
    
    NSTimeInterval duration = .4;
    
    CAKeyframeAnimation *scaleXAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleXAnimation.duration = duration;
    scaleXAnimation.values = scaleValues;
    [self.layer addAnimation:scaleXAnimation forKey:@"scaleXAnimation"];
    
    CAKeyframeAnimation *scaleYAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleYAnimation.duration = duration;
    scaleYAnimation.values = scaleValues;
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
    
    BOOL isOS4 = self.activityIndicatorViewStyle == UIActivityIndicatorViewStyleGray;
    NSTimeInterval duration = .255;
    
    CABasicAnimation *scaleXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleXAnimation.duration = duration;
    scaleXAnimation.fromValue = isOS4 ? @1.f : @.7f;
    scaleXAnimation.toValue = @.01f;
    scaleXAnimation.delegate = self;
    scaleXAnimation.fillMode = kCAFillModeForwards;
    scaleXAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:scaleXAnimation forKey:@"scaleXAnimation"];
    
    CABasicAnimation *scaleYAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleYAnimation.duration = duration;
    scaleYAnimation.fromValue = isOS4 ? @1.f : @.7f;
    scaleYAnimation.toValue = @.01f;
    scaleYAnimation.fillMode = kCAFillModeForwards;
    scaleYAnimation.removedOnCompletion = NO;
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
    [self.layer removeAllAnimations];
}

@end
