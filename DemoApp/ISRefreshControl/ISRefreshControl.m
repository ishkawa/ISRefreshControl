#import "ISRefreshControl.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

const CGFloat additionalTopInset = 50.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL refreshed;
@property (nonatomic) BOOL didOffset;
@property (strong, nonatomic) UIImageView *imageView;
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
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(160-15, 25-15, 30, 30);
        self.imageView.backgroundColor = [UIColor blueColor];
        [self addSubview:self.imageView];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] init];
        self.indicatorView.frame = CGRectMake(160-15, 25-15, 30, 30);
        self.indicatorView.hidesWhenStopped = YES;
        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.indicatorView.color = [UIColor lightGrayColor];
        [self.indicatorView.layer setValue:@.01f forKeyPath:@"transform.scale"];
        [self addSubview:self.indicatorView];
    }
    return self;
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
    
    if (offset <= -50) {
        self.frame = CGRectMake(self.frame.origin.x,
                                offset,
                                self.frame.size.width,
                                self.frame.size.height);
    } else {
        self.frame = CGRectMake(0, -50, 320, 50);
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
    [self updateImageView];
}

- (void)endRefreshing
{
    if (self.refreshed) {
        return;
    }
    
    self.refreshing = NO;
    self.refreshed  = YES;
    
    [self updateIndicator];
    [self updateImageView];
    
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
    }
    [UIView animateWithDuration:.3f
                     animations:^{
                         [self.indicatorView.layer setValue:self.refreshing ? @.8f : @0.01f
                                                 forKeyPath:@"transform.scale"];
                     }
                     completion:^(BOOL finished) {
                         if (!self.refreshing) {
                             [self.indicatorView stopAnimating];
                         }
                     }];
}

- (void)updateImageView
{
    [UIView animateWithDuration:.3f
                     animations:^{
                         if (self.refreshing) {
                             self.imageView.frame = CGRectMake(160, 25, 0, 0);
                         }
                     }
                     completion:^(BOOL finished) {
                         if (self.refreshing) {
                             self.imageView.hidden = YES;
                         } else {
                             self.imageView.hidden = NO;
                             self.imageView.frame = CGRectMake(160-15, 25-15, 30, 30);
                         }
                     }];
}

@end
