#import "ISRefreshControl.h"
#import "ISGumView.h"
#import "ISScalingActivityIndicatorView.h"
#import "ISMethodSwizzling.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, ISRefreshingState) {
    ISRefreshingStateNormal,
    ISRefreshingStateRefreshing,
    ISRefreshingStateRefreshed,
};

static CGFloat const ISAdditionalTopInset = 50.f;
static CGFloat const ISThreshold = 115.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL addedTopInset;
@property (nonatomic) CGFloat offset;
@property (nonatomic) ISRefreshingState refreshingState;
@property (nonatomic, strong) ISGumView *gumView;
@property (nonatomic, strong) ISScalingActivityIndicatorView *indicatorView;

@end


@implementation ISRefreshControl

+ (void)load
{
    @autoreleasepool {
        if (![UIRefreshControl class]) {
            objc_registerClassPair(objc_allocateClassPair([ISRefreshControl class], "UIRefreshControl", 0));
        } else {
#ifndef IS_TEST_FROM_COMMAND_LINE
            ISSwizzleClassMethod([ISRefreshControl class], @selector(alloc), @selector(_alloc));
#endif
        }
    }
}

+ (id)_alloc
{
    if ([UIRefreshControl class]) {
        return (id)[UIRefreshControl alloc];
    }
    return [self _alloc];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.gumView = [[ISGumView alloc] init];
    [self addSubview:self.gumView];
    
    self.indicatorView = [[ISScalingActivityIndicatorView alloc] init];
    self.indicatorView.hidesWhenStopped = YES;
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.indicatorView.color = [UIColor lightGrayColor];
    [self.indicatorView.layer setValue:@.01f forKeyPath:@"transform.scale"];
    [self addSubview:self.indicatorView];
    
    [self addObserver:self forKeyPath:@"tintColor" options:0 context:NULL];
    
    UIColor *tintColor = [[ISRefreshControl appearance] tintColor];
    if (tintColor) {
        self.tintColor = tintColor;
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"tintColor"];
}

#pragma mark -

- (BOOL)isRefreshing
{
    return self.refreshingState == ISRefreshingStateRefreshing;
}

#pragma mark - view events

- (void)layoutSubviews
{
    CGFloat width = self.frame.size.width;
    self.gumView.frame = CGRectMake(width/2.f-15, 25-15, 35, 90);
    self.indicatorView.frame = CGRectMake(width/2.f-15, 25-15, 30, 30);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)didMoveToSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
        
        self.frame = CGRectMake(0, -50, self.superview.frame.size.width, 50);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self setNeedsLayout];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.superview && [keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        self.offset = scrollView.contentOffset.y;
        
        [self keepOnTopOfView];
        [self sendDistanceToGumView];
        [self updateGumViewVisible];
        
        if (self.refreshingState == ISRefreshingStateNormal && self.offset <= -ISThreshold && scrollView.isTracking) {
            [self beginRefreshing];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        if (self.refreshingState == ISRefreshingStateRefreshing && !scrollView.isDragging && !self.addedTopInset) {
            [self addTopInsets];
        }
        if (self.refreshingState == ISRefreshingStateRefreshed && self.offset >= scrollView.contentInset.top - 5.f) {
            [self reset];
        }
        return;
    }
    
    if (object == self && [keyPath isEqualToString:@"tintColor"]) {
        self.gumView.tintColor = self.tintColor;
        self.indicatorView.color = self.tintColor;
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)keepOnTopOfView
{
    if (self.offset < -ISAdditionalTopInset) {
        self.frame = CGRectMake(0, self.offset, self.frame.size.width, self.frame.size.height);
    } else {
        self.frame = CGRectMake(0, -ISAdditionalTopInset, self.frame.size.width, self.frame.size.height);
    }
}

- (void)sendDistanceToGumView
{
    if (self.gumView.shrinking) {
        return;
    }
    self.gumView.distance = self.offset < -ISAdditionalTopInset ? -self.offset-ISAdditionalTopInset : 0.f;
}

- (void)updateGumViewVisible
{
    // hides gumView when it is about to appear by inertial scrolling.
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    if (scrollView.isTracking && !self.isRefreshing) {
        self.hidden = (self.offset > 0);
    }
}

#pragma mark -

- (void)beginRefreshing
{
    if (self.isRefreshing) {
        return;
    }
    
    self.refreshingState = ISRefreshingStateRefreshing;
    [self.indicatorView startAnimating];
    [self.gumView shrink];
}

- (void)endRefreshing
{
    if (!self.isRefreshing) {
        return;
    }
    
    [self.indicatorView stopAnimating];
    
    if (self.addedTopInset) {
        [self subtractTopInsets];
    } else {
        self.refreshingState = ISRefreshingStateRefreshed;
    }
}

- (void)reset
{
    self.gumView.hidden = NO;
    self.indicatorView.hidden = YES;
    self.refreshingState = ISRefreshingStateNormal;
}

- (void)addTopInsets
{
    self.addedTopInset = YES;
    
    UIScrollView *scrollView = (id)self.superview;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top += ISAdditionalTopInset;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = inset;
                     }];
}

- (void)subtractTopInsets
{
    UIScrollView *scrollView = (id)self.superview;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top -= ISAdditionalTopInset;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = inset;
                     }
                     completion:^(BOOL finished) {
                         self.addedTopInset = NO;
                         
                         if (self.offset <= [(UIScrollView *)self.superview contentInset].top) {
                             [self reset];
                         } else {
                             self.refreshingState = ISRefreshingStateRefreshed;
                         }
                     }];
}

@end
