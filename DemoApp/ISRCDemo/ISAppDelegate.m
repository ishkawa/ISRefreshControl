#import "ISAppDelegate.h"
#import "ISSampleTableViewController.h"

@implementation ISAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ISSampleTableViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
