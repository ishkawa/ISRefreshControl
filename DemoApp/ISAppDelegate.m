#import "ISAppDelegate.h"
#import "ISConfigurationViewController.h"

@implementation ISAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ISConfigurationViewController *viewController = [[ISConfigurationViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.viewControllers = @[viewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
