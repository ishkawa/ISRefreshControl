#import "ISDemoViewController.h"
#import "ISRefreshControl.h"

@implementation ISDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, 320, 50);
    label.text = @"header";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = UITextAlignmentCenter;
    self.tableView.tableHeaderView = label;
    
    self.refreshControl = (id)[[ISRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)refresh
{
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
