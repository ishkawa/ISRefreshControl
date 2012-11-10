#import "UITableViewController+RefreshControl.h"
#import "ISRefreshViewController.h"
#import <objc/runtime.h>

@implementation UITableViewController (RefreshControl)

+ (void)load
{
    @autoreleasepool {
        if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
            class_setSuperclass([self class], [ISRefreshViewController class]);
#pragma GCC diagnostic pop
        }
    }
}

@end
