//
//  AppDelegate.m
//  Norlife
//
//  Created by Ryan D'souza on 11/24/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) UITabBarController *tabBarController;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate = self;
    
    DailyScoreViewController *dailyScore = [[DailyScoreViewController alloc] initWithNibName:@"DailyScoreViewController"
                                                                                      bundle:[NSBundle mainBundle]];
    UIImage *dailyImage = [Constants imageWithImage:[UIImage imageNamed:@"calendar_icon.png"]
                                       scaledToSize:CGSizeMake(30, 30)];
    UITabBarItem *dailyScoreTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Daily"
                                                                       image:dailyImage
                                                                         tag:0];
    dailyScore.tabBarItem = dailyScoreTabBarItem;
    
    TrendsScoreViewController *trendsScore = [[TrendsScoreViewController alloc] initWithNibName:@"TrendsScoreViewController"
                                                                                         bundle:[NSBundle mainBundle]];
    UIImage *trendsImage = [Constants imageWithImage:[UIImage imageNamed:@"combo_chart_icon.png"]
                                        scaledToSize:CGSizeMake(30, 30)];
    UITabBarItem *trendsScoreTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Trends"
                                                                        image:trendsImage
                                                                          tag:1];
    trendsScore.tabBarItem = trendsScoreTabBarItem;
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor darkNordeaBlue] }
                                             forState:UIControlStateNormal];
    
    NSArray *viewControllers = @[dailyScore, trendsScore];
    
    self.tabBarController.viewControllers = viewControllers;
    self.window.rootViewController = self.tabBarController;
    
    [[LocationDataManager instance] beginLocationTracking];
    
    return YES;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
