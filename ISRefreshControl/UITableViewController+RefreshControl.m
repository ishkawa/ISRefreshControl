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
            Swizzle([self class], @selector(refreshControl), @selector(iOS5_refreshControl));
            Swizzle([self class], @selector(setRefreshControl:), @selector(iOS5_setRefreshControl:));
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [self addObserversForRefreshControl];
    }
    return self;
}

- (void)awakeFromNib
{
    [self addObserversForRefreshControl];
}

- (void)addObserversForRefreshControl
{
    NSKeyValueObservingOptions options = (NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew);
    
    [self addObserver:self
           forKeyPath:@"refreshControl"
              options:options
              context:NULL];
    
    [self.tableView addObserver:self
                     forKeyPath:@"contentOffset"
                        options:options
                        context:NULL];
}

- (void)dealloc
{
    if (![[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
        return;
    }
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"refreshControl"];
}

- (ISRefreshControl *)iOS5_refreshControl
{
    return objc_getAssociatedObject(self, @"iOS5RefreshControl");
}

- (void)iOS5_setRefreshControl:(ISRefreshControl *)refreshControl
{
    objc_setAssociatedObject(self, @"iOS5RefreshControl", refreshControl, OBJC_ASSOCIATION_RETAIN);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"refreshControl"]) {
        UIView *oldView = [change objectForKey:@"old"];
        UIView *newView = [change objectForKey:@"new"];
        
        if ([oldView isKindOfClass:[UIView class]]) {
            [oldView removeFromSuperview];
        }
        if ([newView isKindOfClass:[UIView class]]) {
            newView.frame = CGRectMake(0, -50, self.view.frame.size.width, 50);
            newView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [newView setNeedsLayout];
            [self.view addSubview:newView];
        }
        return;
    }
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat offset = self.tableView.contentOffset.y;
        [(ISRefreshControl *)self.refreshControl setOffset:offset];
        [(ISRefreshControl *)self.refreshControl setDragging:self.tableView.isDragging];
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
