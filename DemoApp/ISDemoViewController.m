#import "ISDemoViewController.h"
#import "ISRefreshControl.h"

@implementation ISDemoViewController

- (id)init
{
    return [self initWithStyle:UITableViewStylePlain rowHeight:44.f topInset:0.f];
}

- (id)initWithStyle:(UITableViewStyle)style rowHeight:(CGFloat)rowHeight topInset:(CGFloat)topInset
{
    self = [super initWithStyle:style];
    if (self) {
        _topInset  = topInset;
        _rowHeight = rowHeight;
    }
    return self;
}

#pragma mark - UIView events

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.topInset, 0.f, 0.f, 0.f);
    self.tableView.rowHeight = self.rowHeight;
    
    self.refreshControl = (id)[[ISRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Demo";
    [self toggleContents];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)refresh
{
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self toggleContents];
        [self.refreshControl endRefreshing];
    });
}

- (void)toggleContents
{
    static BOOL flag = NO;
    
    if (flag) {
        self.items = @[@"foo", @"bar", @"baz", @"foo", @"bar", @"baz", @"foo", @"bar", @"baz", @"foo", @"bar", @"baz", @"foo", @"bar", @"baz", ];
    } else {
        self.items = @[@"hoge", @"fuga", @"piyo", @"hoge", @"fuga", @"piyo", @"hoge", @"fuga", @"piyo", @"hoge", @"fuga", @"piyo", @"hoge", @"fuga", @"piyo", ];
    }
    flag = !flag;
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[self.items objectAtIndex:indexPath.row] description];
    
    return cell;
}

@end
