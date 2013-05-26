#import "UITableViewController+ISRefreshControl.h"
#import "ISRefreshControl.h"
#import "ISMethodSwizzling.h"
#import <objc/runtime.h>

@implementation UITableViewController (ISRefreshControl)

+ (void)load
{
    @autoreleasepool {
        if (![UIRefreshControl class]) {
            ISSwizzleInstanceMethod([self class], @selector(refreshControl),     @selector(_refreshControl));
            ISSwizzleInstanceMethod([self class], @selector(setRefreshControl:), @selector(_setRefreshControl:));
            ISSwizzleInstanceMethod([self class], @selector(viewDidLoad),        @selector(_viewDidLoad));
        }
    }
}

- (void)_viewDidLoad
{
    [self _viewDidLoad];
    
    if (self.refreshControl) {
        [self.view addSubview:self.refreshControl];
    }
}

- (ISRefreshControl *)_refreshControl
{
    return objc_getAssociatedObject(self.tableView, @"iOS5RefreshControl");
}

- (void)_setRefreshControl:(ISRefreshControl *)refreshControl
{
    if (self.isViewLoaded) {
        ISRefreshControl *oldRefreshControl = objc_getAssociatedObject(self, @"iOS5RefreshControl");
        [oldRefreshControl removeFromSuperview];
        [self.view addSubview:refreshControl];
    }
    
    objc_setAssociatedObject(self.tableView, @"iOS5RefreshControl", refreshControl, OBJC_ASSOCIATION_RETAIN);
}

@end

