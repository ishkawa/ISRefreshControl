#import "UITableView+ISRefreshControl.h"
#import "ISUtility.h"
#import <objc/runtime.h>

@implementation UITableView (ISRefreshControl)

+ (void)load
{
    @autoreleasepool {
        if (![UIRefreshControl class]) {
            SwizzleMethod([self class], @selector(initWithCoder:), @selector(_initWithCoder:));
        }
    }
}

- (id)_initWithCoder:(NSCoder *)coder
{
    self = [self _initWithCoder:coder];
    if (self) {
        UIRefreshControl *refreshControl = [coder decodeObjectForKey:@"UIRefreshControl"];
        [self addSubview: refreshControl];
        
        objc_setAssociatedObject(self, @"iOS5RefreshControl", refreshControl, OBJC_ASSOCIATION_RETAIN);
    }
    return self;
}


@end
