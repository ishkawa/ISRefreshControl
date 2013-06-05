#import "ISGumView.h"
#import "UIColor+ISRefreshControl.h"

static CGFloat const ISMaxDistance = 65.f;
static CGFloat const ISMainCircleMaxRadius = 16.f;
static CGFloat const ISMainCircleMinRadius = 10.f;
static CGFloat const ISSubCircleMaxRadius  = 16.f;
static CGFloat const ISSubCircleMinRadius  = 2.f;

@interface ISGumView ()

@property (nonatomic) CGFloat mainRadius;
@property (nonatomic) CGFloat subRadius;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ISGumView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.distance = 0.f;
        self.mainRadius = ISMainCircleMaxRadius;
        self.subRadius  = ISMainCircleMaxRadius;
        
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
        [self setNeedsDisplay];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.distance < 0) {
        self.distance = 0;
    }
    if (self.distance > ISMaxDistance) {
        self.distance = ISMaxDistance;
    }
    CGFloat progress = self.distance / ISMaxDistance;
    if (self.shrinking) {
        self.mainRadius = ISMainCircleMinRadius*pow((self.distance/ISMaxDistance), 0.1);
        if (self.distance > self.mainRadius) {
            CGFloat diff = fabsf(ISSubCircleMinRadius-self.mainRadius);
            self.subRadius = ISSubCircleMinRadius+diff*(1-(self.distance-self.mainRadius)/(ISMaxDistance-self.mainRadius));
        } else {
            self.subRadius  = self.mainRadius;
        }
    } else {
        self.mainRadius = ISMainCircleMaxRadius - (ISMainCircleMaxRadius - ISMainCircleMinRadius) * progress;
        self.subRadius  = ISSubCircleMaxRadius - (ISSubCircleMaxRadius - ISSubCircleMinRadius) * progress;
    }
    self.imageView.frame = CGRectMake(0, 0, self.mainRadius*2-5, self.mainRadius*2-5);
    self.imageView.center = CGPointMake(self.frame.size.width/2.f, self.mainRadius-2.f + self.distance * 0.03);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath addArcWithCenter:CGPointMake(self.mainRadius, self.mainRadius)
                          radius:self.mainRadius
                      startAngle:M_PI / 2.f
                        endAngle:M_PI / 2.f + M_PI * 2.f
                       clockwise:YES];
    
    [bezierPath addArcWithCenter:CGPointMake(self.mainRadius, self.mainRadius + self.distance)
                          radius:self.subRadius
                      startAngle:M_PI / 2.f
                        endAngle:M_PI / 2.f + M_PI * 2.f
                       clockwise:YES];
    
    CGPoint rightPoint1 = CGPointMake(self.mainRadius * 2.f, self.mainRadius);
    CGPoint rightPoint2 = CGPointMake(self.mainRadius + self.subRadius, self.mainRadius + self.distance);
    [bezierPath moveToPoint:rightPoint1];
    [bezierPath addCurveToPoint:rightPoint2
                  controlPoint1:CGPointMake(rightPoint1.x, rightPoint1.y * (1.f + progress))
                  controlPoint2:CGPointMake(rightPoint2.x, rightPoint2.y * (1.f - progress * .7f))];
    
    CGPoint leftPoint1 = CGPointMake(self.mainRadius - self.subRadius, self.mainRadius + self.distance);
    CGPoint leftPoint2 = CGPointMake(0.f, self.mainRadius);
    [bezierPath addLineToPoint:leftPoint1];
    [bezierPath addCurveToPoint:leftPoint2
                  controlPoint1:CGPointMake(leftPoint1.x, leftPoint1.y * (1.f - progress * .7f))
                  controlPoint2:CGPointMake(leftPoint2.x, leftPoint2.y * (1.f + progress))];
    
    [bezierPath closePath];
    
    CGFloat offset = self.frame.size.width/2.f - self.mainRadius;
    [bezierPath applyTransform:CGAffineTransformMakeTranslation(offset, 0.f)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef path = bezierPath.CGPath;
    
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, (self.tintColor ?: [UIColor is_refreshControlColor]).CGColor);
    CGContextSetShadow(context, CGSizeMake(0.f, .5f), 1.f);
    CGContextFillPath(context);
}

- (void)shrink
{
    self.shrinking = YES;
    
    CGFloat distance = self.distance < ISMaxDistance ? self.distance : ISMaxDistance;
    NSInteger count = 20;
    CGFloat delta = self.distance/(CGFloat)count;
    NSTimeInterval interval = (distance/ISMaxDistance)*0.1/(NSTimeInterval)count;
    [self shrinkWithDelta:delta interval:interval count:count];
}

- (void)shrinkWithDelta:(CGFloat)delta interval:(NSTimeInterval)interval count:(NSInteger)count
{
    if (count <= 0) {
        self.shrinking = NO;
        self.hidden = YES;
        self.alpha = 1.f;
        
        return;
    }
    self.distance -= delta;

    double delayInSeconds = interval;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shrinkWithDelta:delta interval:interval count:count-1];
    });
}

@end
