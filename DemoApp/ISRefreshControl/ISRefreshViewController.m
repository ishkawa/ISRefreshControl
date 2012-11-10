#import "ISRefreshViewController.h"
#import "ISRefreshControl.h"

@implementation ISRefreshViewController

- (id)init
{
    self = [super init];
    if (self) {
        NSKeyValueObservingOptions options = (NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew);
        
        [self addObserver:self
               forKeyPath:@"refreshControl"
                  options:options
                  context:nil];
        
        [self.tableView addObserver:self
                         forKeyPath:@"contentOffset"
                            options:options
                            context:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [(UITableView *)self.view setSeparatorColor:[UIColor colorWithWhite:.9f alpha:1.f]];
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"refreshControl"];
}

#pragma mark - key value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"refreshControl"]) {
        UIView *oldView = [change objectForKey:@"old"];
        UIView *newView = [change objectForKey:@"new"];
        
        if ([oldView isKindOfClass:[UIView class]]) {
            [oldView removeFromSuperview];
        }
        if ([newView isKindOfClass:[UIView class]]) {
            newView.frame = CGRectMake(0, -50, 320, 50);
            newView.backgroundColor = [UIColor blueColor];
            [self.view addSubview:newView];
        }
    }
    else if ([keyPath isEqualToString:@"contentOffset"]) {
        [self updateRefreshControl];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -

- (void)updateRefreshControl
{
    CGFloat offset = self.tableView.contentOffset.y;
    CGFloat threthold = -self.refreshControl.frame.size.height;
    if (offset < threthold) {
        offset = threthold;
    }

    [(ISRefreshControl *)self.refreshControl setOffset:offset];
    [(ISRefreshControl *)self.refreshControl setDragging:self.tableView.isDragging];
}

@end
