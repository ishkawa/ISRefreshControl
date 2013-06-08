#import <UIKit/UIKit.h>

@interface ISRefreshControl : UIControl

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSAttributedString *attributedTitle UI_APPEARANCE_SELECTOR;

- (void)beginRefreshing;
- (void)endRefreshing;

@end
