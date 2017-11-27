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
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              
                          }
     ];

    return YES;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.repeatInterval = NSCalendarUnitMinute;
    [notification setAlertBody:@"You're almost at your daily walking goal - keep on going!"];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

@end
