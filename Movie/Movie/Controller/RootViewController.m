
#import "RootViewController.h"
#import "HomeViewController.h"
#import "MEViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"视频.png"] tag:101];
    
    MEViewController *meVC = [[MEViewController alloc] init];
    UINavigationController *meNC = [[UINavigationController alloc] initWithRootViewController:meVC];
    meVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"我的.png"] tag:102];
    
    self.viewControllers = @[homeNC,meNC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
