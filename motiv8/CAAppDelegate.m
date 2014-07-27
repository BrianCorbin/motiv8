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
    //Initializing Parse to work with application
    [Parse setApplicationId:@"ENca1CpIt5LOMKgajDydyGcXXSmINEmhnDDOgM21"
                  clientKey:@"A31vuZy7iRF7QbzOY8jkcMPc2MyooFEJSiSLy4yA"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    //Allows for localNotifications to register for user
    //This is for iOS 7
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    //This is for iOS 8
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    
    //Set up starting messages to introduce the application
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"])
    {
        CAMessage* firstMessage = [[CAMessage alloc] init];
        CAMessage* secondMessage = [[CAMessage alloc] init];
        firstMessage.message = @"Welcome to motiv8! Press me to see your next message.";
        firstMessage.author = @"motiv8 Team";
        secondMessage.message = @"You can favorite messages and view them again at any time by pressing the heart below. Never give up, and stay motivated!";
        secondMessage.author = @"motiv8 Team";
        
        [self saveObject:firstMessage forKey:@"CurrentMessage"];
        [self saveObject:secondMessage forKey:@"NextMessage"];
    }
    
    //Fire every time the app is launched and checks for new quotes on the Parse server in the background.
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                         {
                             if(!error)
                             {
                                 NSArray* existingMessages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Messages"];
                                 if(objects.count > existingMessages.count)
                                 {
                                     for(PFObject *object in objects)
                                     {
                                         CAMessage* newMessage = [[CAMessage alloc] init];
                                         newMessage.message = object[@"message"];
                                         newMessage.author = object[@"author"];
                                         newMessage.favorited = @"NO";
                                         NSData* encodedObject = [self encodeObject:newMessage];
                                         [messages addObject:encodedObject];
                                     }
                                     
                                     [self addNewMessages:messages and:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Messages"]];
                                     
                                     //sends notification to refreshView in mainViewController to reload the quote and author
                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
                                 }
                             }
                         }];
    return YES;
}

-(void)addNewMessages:(NSMutableArray*) newMessages and:(NSArray*)existingMessages
{
    NSMutableArray* existingMessagesMA = [[NSMutableArray alloc] initWithArray:existingMessages];
    for(int i=0; i<newMessages.count; i++)
    {
        BOOL messageExists = NO;
        CAMessage* newMessage = [self decodeObject:[newMessages objectAtIndex:i]];
        for(int j=0; j<existingMessages.count; j++)
        {
            CAMessage* existingMessage = [self decodeObject:[existingMessages objectAtIndex:j]];
            if(newMessage.message == existingMessage.message)
            {
                messageExists = YES;
                break;
            }
        }
        if(!messageExists)
        {
            NSData* encodedObject = [self encodeObject:newMessage];
            [existingMessagesMA insertObject:encodedObject atIndex:arc4random_uniform((uint32_t)existingMessagesMA.count)];
        }
    }
    existingMessages = [[NSArray alloc] initWithArray:existingMessagesMA];
    [[NSUserDefaults standardUserDefaults] setObject:existingMessages forKey:@"Messages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//encodes CAMessage to NSData
-(NSData*)encodeObject:(CAMessage*) object
{
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    return encodedObject;
}

-(CAMessage*)decodeObject:(NSData*) encodedObject
{
    CAMessage* unencodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return unencodedObject;
}

//saves CAMessage to NSUserDefaults
-(void)saveObject:(CAMessage*) object forKey:(NSString*) key
{
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//Loads CAMessage from NSUserDefaults
-(CAMessage*)loadObjectWithKey:(NSString*) key
{
    NSData* encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    CAMessage* unencodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return unencodedObject;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //When app enters background, create local notification after set time interval
    //as long as it's within the allowed notification times
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    CAMessage* nextMessage = [self loadObjectWithKey:@"NextMessage"];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[[NSUserDefaults standardUserDefaults] integerForKey:@"TimeInterval"]];
    localNotification.alertBody = [NSString stringWithFormat:@"\"%@\" - %@", nextMessage.message, nextMessage.author];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"\"%@\" - %@", nextMessage.message, nextMessage.author);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"])
    {
        //Checks if a notification has gone off (when notifications.count == 0)
        //and sets it as current message and generates a new nextMessage.
        //Saves all to NSUserDefaults and creates refreshView Notification.
        NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        if(notifications.count == 0)
        {
            CAMessage* nextMessage = [self loadObjectWithKey:@"NextMessage"];
            [self saveObject:nextMessage forKey:@"CurrentMessage"];
            NSArray *messages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Messages"];
            int randNum = arc4random_uniform((uint32_t)messages.count);
            [[NSUserDefaults standardUserDefaults] setObject:messages[randNum] forKey:@"NextMessage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasPerformedFirstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //cancel all notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
