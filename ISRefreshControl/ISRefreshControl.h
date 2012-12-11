#import <UIKit/UIKit.h>
#import "UITableViewController+RefreshControl.h"

@interface ISRefreshControl : UIControl;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nonatomic) CGFloat offset;
@property (nonatomic) BOOL dragging;
@property (nonatomic, readwrite, getter=isTracking) BOOL tracking;
@property (nonatomic, retain) UIColor *tintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) NSAttributedString *attributedTitle UI_APPEARANCE_SELECTOR;

- (void)beginRefreshing;
- (void)endRefreshing;

@end
