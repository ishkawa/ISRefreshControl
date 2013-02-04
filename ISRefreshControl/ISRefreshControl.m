#import "ISRefreshControl.h"
#import "ISGumView.h"
#import "ISUtility.h"
#import "UIActivityIndicatorView+ScaleAnimation.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, ISRefreshControlState) {
    ISRefreshControlStateNormal,
    ISRefreshControlStateRefreshing,
    ISRefreshControlStateRefreshed,
};
const CGFloat additionalTopInset = 50.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL didOffset;
@property (nonatomic) ISRefreshControlState refreshControlState;
@property (strong, nonatomic) ISGumView *gumView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (readonly, nonatomic) UITableView *superTableView;

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

#pragma mark - accessor

- (BOOL)isRefreshing
{
    return self.refreshControlState == ISRefreshControlStateRefreshing;
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
        CGFloat offset = scrollView.contentOffset.y;
        
        // reset refresh status
        if (self.refreshControlState == ISRefreshControlStateRefreshed && offset >= 0) {
            [self reset];
        }
        
        // send UIControlEvent
        if (self.refreshControlState == ISRefreshControlStateNormal && offset <= -115 && scrollView.isTracking) {
            [self beginRefreshing];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        
        // stays top and send distance to gumView
        if (offset < -50) {
            self.frame = CGRectMake(0, offset, self.frame.size.width, self.frame.size.height);
            
            if (!self.gumView.shrinking) {
                self.gumView.distance = -offset-50;
            }
        } else {
            self.frame = CGRectMake(0, -50, self.frame.size.width, self.frame.size.height);
            
            if (!self.gumView.shrinking) {
                self.gumView.distance = 0.f;
            }
        }
        
        // topInset
        if (!scrollView.isDragging && self.refreshing && !self.didOffset) {
            self.didOffset = YES;
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
    if (self.refreshControlState != ISRefreshControlStateNormal) {
        return;
    }
    
    self.refreshControlState = ISRefreshControlStateRefreshing;
    
    [self.superview bringSubviewToFront:self];
    
    [self.indicatorView startAnimating];
    [self.indicatorView expandWithCompletion:nil];
    [self.gumView shrink];
}

- (void)endRefreshing
{
    if (self.refreshControlState != ISRefreshControlStateRefreshing) {
        return;
    }
    
    [self.superview bringSubviewToFront:self];
    [self.indicatorView shrinkWithCompletion:^(BOOL finished) {
        [self.indicatorView stopAnimating];
    }];
    
    if (self.didOffset) {
        __weak ISRefreshControl *wself = self;
        [self setTopInsetsEnabled:NO completion:^(BOOL finished) {
            wself.refreshControlState = ISRefreshControlStateRefreshed;
    
            UIScrollView *scrollView = (UIScrollView *)wself.superview;
            if (!scrollView.isDragging) {
                [wself reset];
            }
        }];
    } else {
        self.refreshControlState = ISRefreshControlStateRefreshed;
    }
    self.didOffset = NO;
}

- (void)reset
{
    self.refreshControlState = ISRefreshControlStateNormal;
    self.gumView.hidden = NO;
}

- (void)setTopInsetsEnabled:(BOOL)offset completion:(void (^)(BOOL finished))completion
{
    if (![self.superview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    UIScrollView *scrollView = (id)self.superview;
    CGFloat diff = additionalTopInset * (offset?1.f:-1.f);
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top + diff,
                                                                    scrollView.contentInset.left,
                                                                    scrollView.contentInset.bottom,
                                                                    scrollView.contentInset.right);
                     }
                     completion:completion];
}

@end
