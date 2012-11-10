#import "ISRefreshControl.h"
#import <objc/runtime.h>

const CGFloat additionalTopInset = 50.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL refreshing;
@property (nonatomic, getter = isRefreshed) BOOL refreshed;
@property (readonly, nonatomic) UITableView *superTableView;

@end


@implementation ISRefreshControl

@synthesize state = _state;

- (UITableView *)superTableView
{
    if (![self.superview isKindOfClass:[UITableView class]]) {
        return nil;
    }
    return (UITableView *)self.superview;
}

+ (id)alloc
{
    if ([UIRefreshControl class]) {
        return (id)[UIRefreshControl alloc];
    }
    return [super alloc];
}

- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    
    CGFloat value = fabs(offset/self.frame.size.height);
    self.alpha = value;
    
    if (self.refreshed && offset >= 0) {
        self.refreshed = NO;
    }
    if (!self.refreshing && !self.refreshed && offset <= -50) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)beginRefreshing
{
    if (self.refreshing) {
        return;
    }
    
    self.refreshing = YES;
    self.refreshed  = NO;
    
    [self updateTopInset];
}

- (void)endRefreshing
{
    if (self.refreshed) {
        return;
    }
    
    self.refreshing = NO;
    self.refreshed  = YES;
    
    [self updateTopInset];
}

- (void)updateTopInset
{
    // FIXME: setting contentInset will reset contentOffset.
    //        while user is dragging, it seems like a bug.
    
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

@end
