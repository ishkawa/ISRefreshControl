#import <UIKit/UIKit.h>

@interface ISDemoViewController : UITableViewController

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, readonly) CGFloat rowHeight;
@property (nonatomic, readonly) CGFloat topInset;

- (id)initWithStyle:(UITableViewStyle)style rowHeight:(CGFloat)rowHeight topInset:(CGFloat)topInset;

@end
