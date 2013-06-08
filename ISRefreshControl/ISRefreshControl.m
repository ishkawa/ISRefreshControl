#import "ISRefreshControl.h"
#import "ISGumView.h"
#import "ISScalingActivityIndicatorView.h"
#import "ISMethodSwizzling.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, ISRefreshingState) {
    ISRefreshingStateNormal,
    ISRefreshingStateRefreshing,
    ISRefreshingStateRefreshed,
};

static CGFloat const ISRefreshControlDefaultHeight = 44.f;
static CGFloat const ISRefreshControlThreshold = 105.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL addedTopInset;
@property (nonatomic) BOOL subtractingTopInset;
@property (nonatomic) ISRefreshingState refreshingState;
@property (nonatomic, readonly) ISGumView *gumView;
@property (nonatomic, readonly) ISScalingActivityIndicatorView *indicatorView;

@end


@implementation ISRefreshControl

@synthesize tintColor = _tintColor;

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
    _gumView = [[ISGumView alloc] init];
    _indicatorView = [[ISScalingActivityIndicatorView alloc] init];
    
    [self addSubview:self.gumView];
    [self addSubview:self.indicatorView];
    
    if ([(id)[ISRefreshControl class] respondsToSelector:@selector(appearance)]) {
        UIColor *tintColor = [[ISRefreshControl appearance] tintColor];
        if (tintColor) {
            self.tintColor = tintColor;
        }
    }
}

#pragma mark - accessors

- (BOOL)isRefreshing
{
    return self.refreshingState == ISRefreshingStateRefreshing;
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.gumView.tintColor = self.tintColor;
    if ([self.indicatorView respondsToSelector:@selector(setColor:)]) {
        self.indicatorView.color = self.tintColor;
    }
}

#pragma mark - view events

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL isOS4 = self.indicatorView.activityIndicatorViewStyle == UIActivityIndicatorViewStyleGray;
    CGSize indicatorSize = isOS4 ? CGSizeMake(25.f, 25.f) : CGSizeMake(30.f, 30.f);
    CGRect indicatorFrame = CGRectZero;
    indicatorFrame.origin.x = (self.frame.size.width - indicatorSize.width)  / 2.f;
    indicatorFrame.origin.y = (self.frame.size.height - indicatorSize.width) / 2.f;
    indicatorFrame.size = indicatorSize;
    self.indicatorView.frame = indicatorFrame;
    
    CGSize gumViewSize = CGSizeMake(35.f, 90.f);
    CGRect gumViewFrame = CGRectZero;
    gumViewFrame.origin.x = (self.frame.size.width - gumViewSize.width) / 2.f;
    gumViewFrame.origin.y = 10.f;
    gumViewFrame.size = gumViewSize;
    self.gumView.frame = gumViewFrame;
}

- (void)willMoveToSuperview:(UIView *)superview
{
    [super willMoveToSuperview:superview];
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
        
        CGRect frame = CGRectZero;
        frame.origin = CGPointMake(0.f, -ISRefreshControlDefaultHeight - scrollView.contentInset.top);
        frame.size = CGSizeMake(self.superview.frame.size.width, ISRefreshControlDefaultHeight);
        self.frame = frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.superview && [keyPath isEqualToString:@"contentOffset"]) {
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)self.superview;
            [self scrollViewDidScroll:scrollView];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - fake UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat topInset = scrollView.contentInset.top;
    if (self.addedTopInset && !self.subtractingTopInset) {
        topInset -= self.frame.size.height;
    }
    
    // keeps on top
    CGFloat offset = scrollView.contentOffset.y + topInset;
    CGFloat y = offset < -self.frame.size.height ? offset - topInset : -self.frame.size.height - topInset;
    self.frame = CGRectOffset(self.frame, 0.f, y - self.frame.origin.y);
    
    if (offset < 0.f) {
        self.gumView.distance = offset < -self.frame.size.height ? -offset-self.frame.size.height : 0.f;
    }
    
    // hides gumView when it is about to appear by inertial scrolling.
    if (scrollView.isTracking && !self.isRefreshing) {
        self.hidden = (offset > 0);
    }
    
    switch (self.refreshingState) {
        case ISRefreshingStateNormal:
            if (offset <= -ISRefreshControlThreshold && scrollView.isTracking) {
                [self beginRefreshing];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            break;
            
        case ISRefreshingStateRefreshing:
            if (!scrollView.isDragging && !self.addedTopInset) {
                [self addTopInsets];
            }
            break;
            
        case ISRefreshingStateRefreshed:
            if (offset >= -5.f) {
                [self reset];
            }
            break;
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
    inset.top += self.frame.size.height;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = inset;
                     }];
}

- (void)subtractTopInsets
{
    self.subtractingTopInset = YES;
    
    UIScrollView *scrollView = (id)self.superview;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top -= self.frame.size.height;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = inset;
                     }
                     completion:^(BOOL finished) {
                         self.subtractingTopInset = NO;
                         self.addedTopInset = NO;
                         self.gumView.distance = 0.f;
                         
                         if (scrollView.contentOffset.y <= scrollView.contentInset.top && !scrollView.isDragging) {
                             [self reset];
                         } else {
                             self.refreshingState = ISRefreshingStateRefreshed;
                         }
                     }];
}

@end
