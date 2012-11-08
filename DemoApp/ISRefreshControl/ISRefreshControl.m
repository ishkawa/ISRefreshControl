#import "ISRefreshControl.h"
#import <objc/runtime.h>

@implementation ISRefreshControl

+ (id)alloc
{
    if ([UIRefreshControl class]) {
        return (id)[UIRefreshControl alloc];
    }
    return [super alloc];
}


@end
