#import "ISRefreshControl.h"
#import <objc/runtime.h>

const CGFloat additionalTopInset = 50.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL refreshed;
@property (nonatomic) BOOL didOffset;
@property (readonly, nonatomic) UITableView *superTableView;

@end


@implementation ISRefreshControl

@synthesize state = _state;

+ (id)alloc
{
    if ([UIRefreshControl class]) {
        return (id)[UIRefreshControl alloc];
    }
    return [super alloc];
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
    
    CGFloat value = fabs(offset/self.frame.size.height);
    self.alpha = value;
    
    if (self.refreshed && offset >= 0) {
        self.refreshed = NO;
    }
    if (!self.refreshing && !self.refreshed && offset <= -50) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
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
}

- (void)endRefreshing
{
    if (self.refreshed) {
        return;
    }
    
    self.refreshing = NO;
    self.refreshed  = YES;
    
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

@end
