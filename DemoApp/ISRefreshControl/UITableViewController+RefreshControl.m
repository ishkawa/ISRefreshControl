#import "UITableViewController+RefreshControl.h"
#import "ISRefreshViewController.h"
#import <objc/runtime.h>

@implementation UITableViewController (RefreshControl)

+ (void)load
{
    @autoreleasepool {
        if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
            class_setSuperclass([self class], [ISRefreshViewController class]);
        }
    }
}

@end
