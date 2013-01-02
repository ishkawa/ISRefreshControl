#import "UITableViewController+RefreshControl.h"
#import "ISRefreshControl.h"
#import "ISUtility.h"
#import <objc/runtime.h>

@implementation UITableViewController (RefreshControl)

+ (void)load
{
    @autoreleasepool {
        if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
            SwizzleMethod([self class], @selector(refreshControl),     @selector(iOS5_refreshControl));
            SwizzleMethod([self class], @selector(setRefreshControl:), @selector(iOS5_setRefreshControl:));
            SwizzleMethod([self class], @selector(viewDidLoad),        @selector(iOS5_viewDidLoad));
        }
    }
}

#pragma mark -

- (void)iOS5_viewDidLoad
{
    [super viewDidLoad];
    
    if (self.refreshControl) {
        [self.view addSubview:self.refreshControl];
    }
}

- (ISRefreshControl *)iOS5_refreshControl
{
    return objc_getAssociatedObject(self, @"iOS5RefreshControl");
}

- (void)iOS5_setRefreshControl:(ISRefreshControl *)refreshControl
{
    if (self.isViewLoaded) {
        ISRefreshControl *oldRefreshControl = objc_getAssociatedObject(self, @"iOS5RefreshControl");
        [oldRefreshControl removeFromSuperview];
        [self.view addSubview:refreshControl];
    }
    
    objc_setAssociatedObject(self, @"iOS5RefreshControl", refreshControl, OBJC_ASSOCIATION_RETAIN);
}

@end
