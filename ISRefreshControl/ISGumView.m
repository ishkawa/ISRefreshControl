#import "ISGumView.h"

#define MAX_DISTANCE 65.f

#define MAIN_CIRCLE_MAX_RADIUS 16.f
#define MAIN_CIRCLE_MIN_RADIUS 10.f

#define SUB_CIRCLE_MAX_RADIUS 16.f
#define SUB_CIRCLE_MIN_RADIUS 2.f

@interface ISGumView ()

@property CGFloat mainRadius;
@property CGFloat subRadius;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ISGumView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.distance = 0.f;
        self.mainRadius = MAIN_CIRCLE_MAX_RADIUS;
        self.subRadius  = MAIN_CIRCLE_MAX_RADIUS;
        
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
    if (self.distance > MAX_DISTANCE) {
        self.distance = MAX_DISTANCE;
    }
    if (self.shrinking) {
        self.mainRadius = MAIN_CIRCLE_MIN_RADIUS*pow((self.distance/MAX_DISTANCE), 0.1);
        if (self.distance > self.mainRadius) {
            CGFloat diff = fabsf(SUB_CIRCLE_MIN_RADIUS-self.mainRadius);
            self.subRadius = SUB_CIRCLE_MIN_RADIUS+diff*(1-(self.distance-self.mainRadius)/(MAX_DISTANCE-self.mainRadius));
        } else {
            self.subRadius  = self.mainRadius;
        }
    } else {
        self.mainRadius = MAIN_CIRCLE_MAX_RADIUS-pow(((self.distance)/MAX_DISTANCE), 1.1)*(MAIN_CIRCLE_MAX_RADIUS-MAIN_CIRCLE_MIN_RADIUS);
        self.subRadius  = SUB_CIRCLE_MAX_RADIUS-pow(((self.distance)/MAX_DISTANCE), 1.3)*(SUB_CIRCLE_MAX_RADIUS-SUB_CIRCLE_MIN_RADIUS);
    }
    self.imageView.frame = CGRectMake(0, 0, self.mainRadius*2-5, self.mainRadius*2-5);
    self.imageView.center = CGPointMake(self.frame.size.width/2.f, self.mainRadius-2.f);
    
    // offset to keep center
    CGFloat offset = self.frame.size.width/2.f - self.mainRadius;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, offset, 25);
    CGPathAddArcToPoint(path, NULL,
                        offset, 0,
                        offset + self.mainRadius, 0,
                        self.mainRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        offset + self.mainRadius*2.f, 0,
                        offset + self.mainRadius*2.f, self.mainRadius,
                        self.mainRadius);

    CGPathAddCurveToPoint(path, NULL,
                          offset + self.mainRadius*2.f,            self.mainRadius*2.f,
                          offset + self.mainRadius+self.subRadius, self.mainRadius*2.f,
                          offset + self.mainRadius+self.subRadius, self.distance+self.mainRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        offset + self.mainRadius+self.subRadius, self.distance+self.mainRadius+self.subRadius,
                        offset + self.mainRadius,                self.distance+self.mainRadius+self.subRadius,
                        self.subRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        offset + self.mainRadius-self.subRadius, self.distance+self.mainRadius+self.subRadius,
                        offset + self.mainRadius-self.subRadius, self.distance+self.mainRadius,
                        self.subRadius);
    
    CGPathAddCurveToPoint(path, NULL,
                          offset + self.mainRadius-self.subRadius, self.mainRadius*2.f,
                          offset + 0, self.mainRadius*2.f,
                          offset + 0, self.mainRadius);
    
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    CGContextSetFillColorWithColor(ctx, (self.tintColor ? self.tintColor : [UIColor lightGrayColor]).CGColor);
    CGContextFillPath(ctx);
    CGPathRelease(path);
}

- (void)shrink
{
    if (self.distance <= 0) {
        self.shrinking = NO;
        self.hidden = YES;
        self.alpha = 1.f;
        return;
    }
    self.shrinking = YES;
    self.distance -= 1.f;
    
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 0.002 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self shrink];
    });
}

@end
