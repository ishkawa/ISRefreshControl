#import "ISRefreshViewController.h"

@implementation ISRefreshViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self addObserver:self
               forKeyPath:@"refreshControl"
                  options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
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
    [self removeObserver:self forKeyPath:@"refreshControl"];
}

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
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
