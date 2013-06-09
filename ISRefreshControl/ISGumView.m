#import "ISGumView.h"
#import "UIColor+ISRefreshControl.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const ISMaxDistance = 60.f;
static CGFloat const ISMainCircleMaxRadius = 16.f;
static CGFloat const ISMainCircleMinRadius = 10.f;
static CGFloat const ISSubCircleMaxRadius  = 16.f;
static CGFloat const ISSubCircleMinRadius  = 2.5f;

@interface ISGumView ()

@property (nonatomic) CGFloat mainRadius;
@property (nonatomic) CGFloat subRadius;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ISGumView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        layer.fillColor = [UIColor is_refreshControlColor].CGColor;
        self.backgroundColor = [UIColor clearColor];
        
        self.distance = 0.f;
        self.mainRadius = ISMainCircleMaxRadius;
        self.subRadius  = ISMainCircleMaxRadius;
        
        self.layer.shadowColor = [UIColor is_refreshControlColor].CGColor;
        self.layer.shadowOpacity = .5f;
        self.layer.shadowRadius = .5f;
        self.layer.shadowOffset = CGSizeMake(0.f, .5f);
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(0, 0, self.mainRadius*2-12, self.mainRadius*2-12);
        self.imageView.center = CGPointMake(frame.size.width/2.f, self.mainRadius);
        self.imageView.image = [UIImage imageNamed:@"ISRefresgControlIcon"];
        [self addSubview:self.imageView];
        
        [self addObserver:self forKeyPath:@"distance" options:0 context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"distance"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"distance"]) {
        [self setNeedsLayout];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.fillColor = tintColor.CGColor;
}

- (UIBezierPath *)pathForMainRadius:(CGFloat)mainRadius
                          subRadius:(CGFloat)subRadius
                           distance:(CGFloat)distance
{
    CGFloat progress = distance / ISMaxDistance;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath moveToPoint:CGPointMake(0.f, mainRadius)];
    [bezierPath addArcWithCenter:CGPointMake(mainRadius, mainRadius)
                          radius:mainRadius
                      startAngle:M_PI
                        endAngle:0.f
                       clockwise:YES];
    
    CGPoint rightPoint1 = [bezierPath currentPoint];
    CGPoint rightPoint2 = CGPointMake(mainRadius + subRadius, mainRadius + distance);
    [bezierPath addCurveToPoint:rightPoint2
                  controlPoint1:CGPointMake(rightPoint1.x, rightPoint1.y * (1.f + progress))
                  controlPoint2:CGPointMake(rightPoint2.x, rightPoint2.y * (1.f - progress * .7f))];
    
    [bezierPath addArcWithCenter:CGPointMake(mainRadius, mainRadius + distance)
                          radius:subRadius
                      startAngle:0.f
                        endAngle:-M_PI
                       clockwise:YES];
    
    CGPoint leftPoint1 = [bezierPath currentPoint];
    CGPoint leftPoint2 = CGPointMake(0.f, mainRadius);
    [bezierPath addCurveToPoint:leftPoint2
                  controlPoint1:CGPointMake(leftPoint1.x, leftPoint1.y * (1.f - progress * .7f))
                  controlPoint2:CGPointMake(leftPoint2.x, leftPoint2.y * (1.f + progress))];
    
    [bezierPath closePath];
    
    CGFloat offset = self.frame.size.width/2.f - mainRadius;
    [bezierPath applyTransform:CGAffineTransformMakeTranslation(offset, 0.f)];
    
    return bezierPath;
}

#pragma mark - UIView events

- (void)layoutSubviews
{
    if (self.shrinking) {
        return;
    }
    
    if (self.distance < 0) {
        self.distance = 0;
    }
    if (self.distance > ISMaxDistance) {
        self.distance = ISMaxDistance;
    }
    
    CGFloat progress = self.distance / ISMaxDistance;
    self.mainRadius = ISMainCircleMaxRadius - (ISMainCircleMaxRadius - ISMainCircleMinRadius) * progress;
    self.subRadius  = ISSubCircleMaxRadius - (ISSubCircleMaxRadius - ISSubCircleMinRadius) * progress;
    
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.path = [self pathForMainRadius:self.mainRadius
                               subRadius:self.subRadius
                                distance:self.distance].CGPath;
    
    self.imageView.frame = CGRectMake(0, 0, self.mainRadius*2-5, self.mainRadius*2-5);
    self.imageView.center = CGPointMake(self.frame.size.width/2.f, self.mainRadius-2.f + self.distance * 0.03);
}

#pragma mark -

- (void)shrink
{
    self.shrinking = YES;
    
    NSMutableArray *paths = [@[] mutableCopy];
    NSMutableArray *values = [@[] mutableCopy];
    
    CGFloat distance = self.distance < ISMaxDistance ? self.distance : ISMaxDistance;
    NSInteger count = 20;
    CGFloat delta = distance / (CGFloat)count;
    
    for (NSInteger index = 0; index < count; index++) {
        CGFloat mainRadius = ISMainCircleMinRadius*pow((distance/ISMaxDistance), 0.15);
        CGFloat subRadius;
        if (distance > mainRadius) {
            CGFloat diff = fabsf(ISSubCircleMinRadius-mainRadius);
            subRadius = ISSubCircleMinRadius+diff*(1-(distance-mainRadius)/(ISMaxDistance-mainRadius));
        } else {
            subRadius = mainRadius;
        }
        
        UIBezierPath *path = [self pathForMainRadius:mainRadius subRadius:subRadius distance:distance];
        [paths addObject:path];
        [values addObject:(id)path.CGPath];
        
        distance -= delta;
        if (distance < 0.f) {
            UIBezierPath *path = [self pathForMainRadius:.1f subRadius:.1f distance:.1f];
            [paths addObject:path];
            break;
        }
    }
    
    NSTimeInterval duration = .135;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = duration;
    pathAnimation.values = values;
    pathAnimation.delegate = self;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:pathAnimation forKey:@"pathAnimation"];
    
    CABasicAnimation *scaleXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleXAnimation.duration = duration;
    scaleXAnimation.fromValue = @1.f;
    scaleXAnimation.toValue = @.4f;
    scaleXAnimation.fillMode = kCAFillModeForwards;
    scaleXAnimation.removedOnCompletion = NO;
    [self.imageView.layer addAnimation:scaleXAnimation forKey:@"scaleXAnimation"];
    
    CABasicAnimation *scaleYAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleYAnimation.duration = duration;
    scaleYAnimation.fromValue = @1.f;
    scaleYAnimation.toValue = @.4f;
    scaleYAnimation.fillMode = kCAFillModeForwards;
    scaleYAnimation.removedOnCompletion = NO;
    [self.imageView.layer addAnimation:scaleYAnimation forKey:@"scaleYAnimation"];
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    moveAnimation.duration = duration;
    moveAnimation.fromValue = @0.f;
    moveAnimation.toValue = @(-5.0f);
    [self.imageView.layer addAnimation:moveAnimation forKey:@"moveAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.shrinking = NO;
    self.hidden = YES;
    self.alpha = 1.f;
    
    [self.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
}

@end
