#import "UITableViewController+RefreshControl.h"
#import "ISRefreshControl.h"
#import <objc/runtime.h>

void Swizzle(Class c, SEL original, SEL alternative)
{
    Method orgMethod = class_getInstanceMethod(c, original);
    Method altMethod = class_getInstanceMethod(c, alternative);
    
    if(class_addMethod(c, original, method_getImplementation(altMethod), method_getTypeEncoding(altMethod))) {
        class_replaceMethod(c, alternative, method_getImplementation(orgMethod), method_getTypeEncoding(orgMethod));
    } else {
        method_exchangeImplementations(orgMethod, altMethod);
    }
}

@implementation UITableViewController (RefreshControl)

+ (void)load
{
    @autoreleasepool {
        if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
            Swizzle([self class], @selector(refreshControl),     @selector(iOS5_refreshControl));
            Swizzle([self class], @selector(setRefreshControl:), @selector(iOS5_setRefreshControl:));
            Swizzle([self class], @selector(viewDidLoad),        @selector(iOS5_viewDidLoad));
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
