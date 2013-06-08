#import "ISConfigurationViewController.h"
#import "ISDemoViewController.h"

@implementation ISConfigurationViewController

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.styleSwitch = [[UISwitch alloc] init];
    
    self.topInsetTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 25.f)];
    self.topInsetTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.topInsetTextField.textAlignment = UITextAlignmentRight;
    self.topInsetTextField.placeholder = @"0";
    
    self.rowHeightTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 25.f)];
    self.rowHeightTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.rowHeightTextField.textAlignment = UITextAlignmentRight;
    self.rowHeightTextField.placeholder = @"44";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Configuration";
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Demo"
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(pushDemoViewController)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.topInsetTextField becomeFirstResponder];
}

- (void)pushDemoViewController
{
    UITableViewStyle style = self.styleSwitch.isOn ? UITableViewStyleGrouped : UITableViewStylePlain;
    CGFloat topContentInset = [self.topInsetTextField.text floatValue] ?: 0.f;
    CGFloat rowHeight = [self.rowHeightTextField.text floatValue] ?: 44.f;
    ISDemoViewController *viewController = [[ISDemoViewController alloc] initWithStyle:style
                                                                             rowHeight:rowHeight
                                                                              topInset:topContentInset];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"grouped";
            cell.accessoryView = self.styleSwitch;
            break;
            
        case 1:
            cell.textLabel.text = @"top inset";
            cell.accessoryView = self.topInsetTextField;
            break;
            
        case 2:
            cell.textLabel.text = @"row height";
            cell.accessoryView = self.rowHeightTextField;
            break;
    }
    
    return cell;
}

@end
