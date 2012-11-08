#import "UITableViewController+RefreshControl.h"
#import "ISRefreshViewController.h"
#import <objc/runtime.h>

@implementation UITableViewController (RefreshControl)

+ (void)load
{
    class_setSuperclass([self class], [ISRefreshViewController class]);
}

@end
