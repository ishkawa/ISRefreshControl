#import "ISGumView.h"

#define MAX_DISTANCE 70.f

#define MAIN_CIRCLE_MAX_RADIUS 16.f
#define MAIN_CIRCLE_MIN_RADIUS 11.f

#define SUB_CIRCLE_MAX_RADIUS 16.f
#define SUB_CIRCLE_MIN_RADIUS 2.5f

@interface ISGumView ()

@property CGFloat mainRadius;
@property CGFloat subRadius;

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
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.distance < 0) {
        self.distance = 0;
    }
    if (self.distance > MAX_DISTANCE) {
        self.distance = MAX_DISTANCE;
    }
    self.mainRadius = MAIN_CIRCLE_MAX_RADIUS-pow(((self.distance)/MAX_DISTANCE), 1.6)*(MAIN_CIRCLE_MAX_RADIUS-MAIN_CIRCLE_MIN_RADIUS);
    self.subRadius  = SUB_CIRCLE_MAX_RADIUS-pow(((self.distance)/MAX_DISTANCE), 1.6)*(SUB_CIRCLE_MAX_RADIUS-SUB_CIRCLE_MIN_RADIUS);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, 25);
    CGPathAddArcToPoint(path, NULL,
                        0, 0,
                        self.mainRadius, 0,
                        self.mainRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        self.mainRadius*2.f, 0,
                        self.mainRadius*2.f, self.mainRadius,
                        self.mainRadius);

    CGPathAddCurveToPoint(path, NULL,
                          self.mainRadius*2.f,            self.mainRadius*2.f,
                          self.mainRadius+self.subRadius, self.mainRadius*2.f,
                          self.mainRadius+self.subRadius, self.distance+self.mainRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        self.mainRadius+self.subRadius, self.distance+self.mainRadius+self.subRadius,
                        self.mainRadius,                self.distance+self.mainRadius+self.subRadius,
                        self.subRadius);
    
    CGPathAddArcToPoint(path, NULL,
                        self.mainRadius-self.subRadius, self.distance+self.mainRadius+self.subRadius,
                        self.mainRadius-self.subRadius, self.distance+self.mainRadius,
                        self.subRadius);
    
    CGPathAddCurveToPoint(path, NULL,
                          self.mainRadius-self.subRadius, self.mainRadius*2.f,
                          0, self.mainRadius*2.f,
                          0, self.mainRadius);
    
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    CGContextSetFillColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextFillPath(ctx);
    CGPathRelease(path);
}

@end
