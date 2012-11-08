#import "ISSampleTableViewController.h"

@implementation ISSampleTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.refreshControl = (UIRefreshControl *)[[ISRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(refresh)
                      forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, 320, 50);
    view.backgroundColor = [UIColor darkGrayColor];
    
    self.tableView.tableHeaderView = view;
}

#pragma mark -

- (void)refresh
{
    NSLog(@"\n%@", [self.view performSelector:@selector(recursiveDescription)]);
    [self.refreshControl beginRefreshing];
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        static BOOL flag = NO;
        if (flag) {
            self.items = @[@"foo", @"bar", @"baz"];
        }else {
            self.items = @[@"hoge", @"fuga", @"piyo"];
        }
        flag = !flag;
        
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - table view data source

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
