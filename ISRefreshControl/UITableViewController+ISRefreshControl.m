#import "UITableViewController+ISRefreshControl.h"
#import "ISRefreshControl.h"
#import "ISMethodSwizzling.h"
#import <objc/runtime.h>

static char ISAssociatedRefreshControlKey;

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
    } else {
        for (UIView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[ISRefreshControl class]]) {
                self.refreshControl = (UIRefreshControl *)subview;
                break;
            }
        }
    }
}

- (ISRefreshControl *)_refreshControl
{
    return objc_getAssociatedObject(self, &ISAssociatedRefreshControlKey);
}

- (void)_setRefreshControl:(ISRefreshControl *)refreshControl
{
    if (self.isViewLoaded) {
        ISRefreshControl *oldRefreshControl = objc_getAssociatedObject(self, &ISAssociatedRefreshControlKey);
        [oldRefreshControl removeFromSuperview];
        [self.view addSubview:refreshControl];
    }
    
    objc_setAssociatedObject(self, &ISAssociatedRefreshControlKey, refreshControl, OBJC_ASSOCIATION_RETAIN);
}

@end

