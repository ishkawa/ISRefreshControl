#import "UITableView+ISRefreshControl.h"
#import "ISMethodSwizzling.h"
#import "ISRefreshControl.h"
#import <objc/runtime.h>

@implementation UITableView (ISRefreshControl)

+ (void)load
{
    @autoreleasepool {
        if (![UIRefreshControl class]) {
            ISSwizzleInstanceMethod([self class], @selector(initWithCoder:), @selector(_initWithCoder:));
        }
    }
}

- (id)_initWithCoder:(NSCoder *)coder
{
    self = [self _initWithCoder:coder];
    if (self) {
        ISRefreshControl *refreshControl = [coder decodeObjectForKey:@"UIRefreshControl"];
        [self addSubview:refreshControl];
    }
    return self;
}


@end
