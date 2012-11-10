#import "ISAppDelegate.h"
#import "ISDemoViewController.h"

@implementation ISAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ISDemoViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
