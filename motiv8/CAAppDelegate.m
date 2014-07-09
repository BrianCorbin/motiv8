//
//  CAAppDelegate.m
//  motiv8
//
//  Created by Brian Corbin on 6/11/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import "CAAppDelegate.h"
#import <Parse/Parse.h>

@implementation CAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"ENca1CpIt5LOMKgajDydyGcXXSmINEmhnDDOgM21"
                  clientKey:@"A31vuZy7iRF7QbzOY8jkcMPc2MyooFEJSiSLy4yA"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    //[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"])
    {
        NSArray *array = [[NSArray alloc] initWithObjects:@"Genius is one percent inspiration, ninety-nine percent perspiration.", @"Run from your problems, and they'll catch you, for they're much faster than you. But turn to fight them, and they'll run away from you and never come back.", @"Never be ashamed of a scar. It simply means you were stronger than whatever tried to hurt you.", @"If you can dream it, you can do it.", @"If you think you can do a thing or think you can't do a thing, you're right.", @"Obstacles are those frightful things you see when you take your eyes off your goal.", @"Negative results are just what I want. They’re just as valuable to me as positive results. I can never find the thing that does the job best until I find the ones that don’t.", @"I find out what the world needs. Then I go ahead and try to invent it.", @"Everything comes to him who hustles while he waits.", @"I never did a day's work in my life, it was all fun.", @"Our greatest weakness lies in giving up. The most certain way to succeed is always to try just one more time.", @"When you have exhausted all possibilities, remember this - you haven't.", @"I have not failed. I've just found 10,000 ways that won't work.", @"Many of life's failures are people who did not realize how close they were to success when they gave up.", @"If we did all the things we are really capable of doing, we would literally astound ourselves.", nil];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"Messages"];
        int randNum = arc4random_uniform((int)(array.count));
        [[NSUserDefaults standardUserDefaults] setObject:array[randNum] forKey:@"CurrentMessage"];
        randNum = arc4random_uniform((int)(array.count));
        [[NSUserDefaults standardUserDefaults] setObject:array[randNum] forKey:@"NextMessage"];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                         {
                             if(!error)
                             {
                                 NSLog(@"Working?");
                                 for(PFObject *object in objects)
                                 {
                                     NSString* message = object[@"message"];
                                     NSString* author = object[@"author"];
                                     NSString* messageFormatted = [NSString stringWithFormat:@"\"%@\" - %@", message, author];
                                     [messages addObject:messageFormatted];
                                 }
                                 [[NSUserDefaults standardUserDefaults] setObject:messages forKey:@"Messages"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
                             }
                         }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[[NSUserDefaults standardUserDefaults] integerForKey:@"TimeInterval"]];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    localNotification.alertBody = [[NSUserDefaults standardUserDefaults] stringForKey:@"NextMessage"];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"LocalNotificationWithContents \"%@\"", [[NSUserDefaults standardUserDefaults] stringForKey:@"NextMessage"]);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if(notifications.count == 0)
    {
        NSString *showMessage = [[NSUserDefaults standardUserDefaults] stringForKey:@"NextMessage"];
        [[NSUserDefaults standardUserDefaults] setObject:showMessage forKey:@"CurrentMessage"];
        NSArray *messages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Messages"];
        int randNum = arc4random_uniform((uint32_t)messages.count);
        [[NSUserDefaults standardUserDefaults] setObject:messages[randNum] forKey:@"NextMessage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
