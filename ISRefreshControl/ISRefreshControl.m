#import "ISRefreshControl.h"
#import "ISGumView.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

const CGFloat additionalTopInset = 50.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL refreshed;
@property (nonatomic) BOOL didOffset;
@property (strong, nonatomic) ISGumView *gumView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (readonly, nonatomic) UITableView *superTableView;

@end


@implementation ISRefreshControl

+ (id)alloc
{
    if ([UIRefreshControl class]) {
        return (id)[UIRefreshControl alloc];
    }
    return [super alloc];
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
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat width = self.frame.size.width;
    self.gumView.frame = CGRectMake(width/2.f-15, 25-15, 35, 90);
    self.indicatorView.frame = CGRectMake(width/2.f-15, 25-15, 30, 30);
}

#pragma mark - accessor

- (UITableView *)superTableView
{
    if (![self.superview isKindOfClass:[UITableView class]]) {
        return nil;
    }
    return (UITableView *)self.superview;
}

- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    
    if (self.refreshed && offset >= 0) {
        self.refreshed = NO;
        if (self.gumView.hidden) {
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * .3f * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.gumView.hidden = NO;
            });
        }
    }
    if (!self.refreshing && !self.refreshed && offset <= -115 && self.tracking) {
        [self beginRefreshing];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }

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
}

- (void)setDragging:(BOOL)dragging
{
    _dragging = dragging;
    
    if (!self.dragging && self.refreshing && !self.didOffset) {
        self.didOffset = YES;
        [self updateTopInset];
    }
}

#pragma mark -

- (void)beginRefreshing
{
    if (self.refreshing) {
        return;
    }
    
    self.refreshing = YES;
    self.refreshed  = NO;
    
    [self updateIndicator];
    [self.gumView shrink];
}

- (void)endRefreshing
{
    if (self.refreshed) {
        return;
    }
    
    self.refreshing = NO;
    self.refreshed  = YES;
    
    [self updateIndicator];
    
    if (self.didOffset) {
        [self updateTopInset];
    }
    self.didOffset = NO;
}

- (void)updateTopInset
{
    CGFloat diff = additionalTopInset * (self.refreshing?1.f:-1.f);
    UIEdgeInsets inset = self.superTableView.contentInset;
    [UIView animateWithDuration:.3f
                     animations:^{
                         self.superTableView.contentInset = UIEdgeInsetsMake(inset.top + diff,
                                                                             inset.left,
                                                                             inset.bottom,
                                                                             inset.right);
                     }];
}

- (void)updateIndicator
{
    if (self.refreshing) {
        [self.indicatorView startAnimating];
        
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 0.1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:.4f
                             animations:^{
                                 [self.indicatorView.layer setValue:@.7f forKeyPath:@"transform.scale"];
                             }
                             completion:^(BOOL finished) {
                             }];
        });
    } else {
        [UIView animateWithDuration:.3f
                         animations:^{
                             [self.indicatorView.layer setValue:@0.01f forKeyPath:@"transform.scale"];
                         }
                         completion:^(BOOL finished) {
                             [self.indicatorView stopAnimating];
                         }];
    }
    
}

@end
