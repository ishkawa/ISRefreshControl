#import "ISRefreshControl.h"
#import <objc/runtime.h>

typedef enum {
    ISRefreshControlStateNormal,
    ISRefreshControlStateRefreshing,
    ISRefreshControlStateFinished,
} ISRefreshControlState;

@interface ISRefreshControl ()

@property ISRefreshControlState state;

@end


@implementation ISRefreshControl

+ (id)alloc
{
    if ([UIRefreshControl class]) {
        return (id)[UIRefreshControl alloc];
    }
    return [super alloc];
}

- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    
    CGFloat value = fabs(offset/self.frame.size.height);
    self.alpha = value;
}

- (void)beginRefreshing
{
}

- (void)endRefreshing
{
}

@end
