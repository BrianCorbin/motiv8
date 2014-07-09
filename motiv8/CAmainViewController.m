//
//  CAmainViewController.m
//  motiv8
//
//  Created by Brian Corbin on 6/11/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import "CAmainViewController.h"

@interface CAmainViewController ()
- (IBAction)infoAction:(UIBarButtonItem *)sender;
- (IBAction)settingsAction:(UIBarButtonItem *)sender;
- (IBAction)copyAction:(id)sender;
- (IBAction)changeMessageBtn:(id)sender;
- (IBAction)activityAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (strong, nonatomic) NSArray* messages;

@end

@implementation CAmainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refreshView" object:nil];

    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:3600 forKey:@"TimeInterval"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1h 0m" forKey:@"TimeIntervalStr"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _messages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Messages"];
    _messageLbl.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentMessage"];
}

-(void)refreshView:(NSNotification *) notification
{
    _messages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Messages"];
    _messageLbl.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentMessage"];
} 

-(void)viewDidAppear:(BOOL)animated
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasPerformedFirstLaunch"];
        NSLog(@"First Launch Complete");
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CAinfoViewController"] animated:NO completion:nil];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    _messageLbl.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentMessage"];
    //[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)infoAction:(UIBarButtonItem *)sender {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CAinfoViewController"] animated:YES completion:nil];
}

- (IBAction)settingsAction:(UIBarButtonItem *)sender {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"svcNavController"] animated:YES completion:nil];
}

- (IBAction)copyAction:(id)sender {
    UIPasteboard* genPB = [UIPasteboard generalPasteboard];
    genPB.string = _messageLbl.text;
}

- (IBAction)changeMessageBtn:(id)sender {
    int randNum = arc4random_uniform((uint32_t)_messages.count);
    _messageLbl.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"NextMessage"];
    [[NSUserDefaults standardUserDefaults] setObject:_messageLbl.text forKey:@"CurrentMessage"];
    [[NSUserDefaults standardUserDefaults] setObject:_messages[randNum] forKey:@"NextMessage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (IBAction)activityAction:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_messageLbl.text] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityViewController animated:YES completion:nil];
}


@end
