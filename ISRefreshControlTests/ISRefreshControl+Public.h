#import "ISRefreshControl.h"

typedef NS_ENUM(NSInteger, ISRefreshingState) {
    ISRefreshingStateNormal,
    ISRefreshingStateRefreshing,
    ISRefreshingStateRefreshed,
};

static CGFloat const ISAdditionalTopInset = 50.f;
static CGFloat const ISThreshold = 115.f;

@class ISGumView;
@class ISScalingActivityIndicatorView;

@interface ISRefreshControl (Public)

@property (nonatomic) BOOL addedTopInset;
@property (nonatomic) CGFloat offset;
@property (nonatomic) ISRefreshingState refreshingState;
@property (nonatomic, strong) ISGumView *gumView;
@property (nonatomic, strong) ISScalingActivityIndicatorView *indicatorView;

- (void)reset;
- (void)addTopInsets;
- (void)subtractTopInsets;

@end
