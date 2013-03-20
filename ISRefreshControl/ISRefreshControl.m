#import "ISRefreshControl.h"
#import "ISGumView.h"
#import "ISUtility.h"
#import "UIActivityIndicatorView+ScaleAnimation.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

const CGFloat additionalTopInset = 50.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL topInsetsEnabled;
@property (nonatomic) BOOL animating;
@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL refreshed;
@property (strong, nonatomic) ISGumView *gumView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (readonly, nonatomic) UITableView *superTableView;

@property (nonatomic) CGFloat superScrollViewTopContentInset;

@end


@implementation ISRefreshControl

+ (void)load
{
    @autoreleasepool {
        if (![[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
            SwizzleMethod(object_getClass([self class]), @selector(appearance), @selector(iOS6_appearance));
        }
    }
}

+ (id)alloc
{
    if ([UIRefreshControl class]) {
        return (id)[UIRefreshControl alloc];
    }
    return [super alloc];
}

+ (id)iOS6_appearance
{
    return [[UIRefreshControl class] appearance];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.gumView = [[ISGumView alloc] init];
        [self addSubview:self.gumView];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] init];
        self.indicatorView.hidesWhenStopped = YES;
        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.indicatorView.color = [UIColor lightGrayColor];
        [self.indicatorView.layer setValue:@.01f forKeyPath:@"transform.scale"];
        [self addSubview:self.indicatorView];
        
        [self addObserver:self
               forKeyPath:@"tintColor"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        UIColor *tintColor = [[ISRefreshControl appearance] tintColor];
        if (tintColor) {
            self.tintColor = tintColor;
        }
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"tintColor"];
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
        self.superScrollViewTopContentInset = [(UIScrollView*)self.superview contentInset].top;
        self.frame = CGRectMake(0, (-50-self.superScrollViewTopContentInset), self.superview.frame.size.width, 50);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self setNeedsLayout];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.superview && [keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        CGFloat offset = scrollView.contentOffset.y + self.superScrollViewTopContentInset;
        
        // hide when isTracking == NO
        if ([(UIScrollView *)self.superview isTracking] && !self.isRefreshing) {
            self.hidden = (offset > 0);
        }
        
        // reset refresh status
        if (!self.refreshing && !self.animating && offset >= 0) {
            [self reset];
        }
        
        // send UIControlEvent
        if (!self.refreshing && !self.refreshed && offset <= -115 && scrollView.isTracking) {
            [self beginRefreshing];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        
        // stays top and send distance to gumView
        if (offset < -50) {
            self.frame = CGRectMake(0, (offset-self.superScrollViewTopContentInset), self.frame.size.width, self.frame.size.height);
            
            if (!self.gumView.shrinking) {
                self.gumView.distance = -offset-50;
            }
        } else {
            self.frame = CGRectMake(0, (-50-self.superScrollViewTopContentInset), self.frame.size.width, self.frame.size.height);
            
            if (!self.gumView.shrinking) {
                self.gumView.distance = 0.f;
            }
        }
        
        // topInset
        if (!scrollView.isDragging && self.refreshing && !self.animating && !self.topInsetsEnabled) {
            [self setTopInsetsEnabled:YES completion:nil];
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

#pragma mark -

- (void)beginRefreshing
{
    if (self.refreshing) {
        return;
    }
    
    self.refreshing = YES;
    
    [self.superview bringSubviewToFront:self];
    
    [self.indicatorView startAnimating];
    [self.indicatorView expandWithCompletion:nil];
    [self.gumView shrink];
}

- (void)endRefreshing
{
    if (!self.refreshing) {
        return;
    }
    
    self.refreshing = NO;
    self.refreshed = YES;
    
    [self.superview bringSubviewToFront:self];
    [self.indicatorView shrinkWithCompletion:^(BOOL finished) {
        [self.indicatorView stopAnimating];
    }];
    
    if (self.topInsetsEnabled) {
        __weak __typeof__(self) wself = self;
        [self setTopInsetsEnabled:NO completion:^{
            UIScrollView *scrollView = (UIScrollView *)wself.superview;
            if (!scrollView.isDragging) {
                [wself reset];
            }
        }];
    }
}

- (void)reset
{
    self.refreshing = NO;
    self.refreshed = NO;
    self.gumView.hidden = NO;
}

- (void)setTopInsetsEnabled:(BOOL)enabled completion:(void (^)(void))completion
{
    if (![self.superview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    if (self.topInsetsEnabled == enabled) {
        return;
    }
    self.topInsetsEnabled = enabled;
    
    UIScrollView *scrollView = (id)self.superview;
    CGFloat diff = additionalTopInset * (enabled?1.f:-1.f);
    
    __weak __typeof__(self) wself = self;
    wself.animating = YES;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top + diff,
                                                                    scrollView.contentInset.left,
                                                                    scrollView.contentInset.bottom,
                                                                    scrollView.contentInset.right);
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                         
                         if (completion) {
                             completion();
                         };
                     }];
}

@end
