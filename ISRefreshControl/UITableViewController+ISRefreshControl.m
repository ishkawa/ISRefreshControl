#import "UITableViewController+ISRefreshControl.h"
#import "ISRefreshControl.h"
#import "ISUtility.h"
#import <objc/runtime.h>

@implementation UITableViewController (ISRefreshControl)

+ (void)load
{
    @autoreleasepool {
        if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
            SwizzleMethod([self class], @selector(refreshControl),     @selector(_refreshControl));
            SwizzleMethod([self class], @selector(setRefreshControl:), @selector(_setRefreshControl:));
            SwizzleMethod([self class], @selector(viewDidLoad),        @selector(_viewDidLoad));
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

