//
//  CAmainViewController.m
//  motiv8
//
//  Created by Brian Corbin on 6/11/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import "CAmainViewController.h"
#import "CAMessage.h"

@interface CAmainViewController ()
- (IBAction)infoAction:(UIBarButtonItem *)sender;
- (IBAction)settingsAction:(UIBarButtonItem *)sender;
- (IBAction)copyAction:(id)sender;
- (IBAction)changeMessageBtn:(id)sender;
- (IBAction)activityAction:(id)sender;
- (IBAction)favoriteAction:(id)sender;
- (IBAction)favoriteListAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView* favImgView;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UILabel *authorLbl;
@property (strong, nonatomic) NSMutableArray* messages;

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
        [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"BeginSilentMode"];
        [[NSUserDefaults standardUserDefaults] setInteger: 800 forKey:@"EndSilentMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _messages = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Messages"]];
    CAMessage* currentMessage = [self loadObjectWithKey:@"CurrentMessage"];
    _messageLbl.text = [NSString stringWithFormat:@"\"%@\"",currentMessage.message];
    _authorLbl.text = currentMessage.author;
    [self checkFavoriteStatus:currentMessage];
}

- (void)refreshView:(NSNotification *) notification
{
    _messages = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Messages"]];
    CAMessage* currentMessage = [self loadObjectWithKey:@"CurrentMessage"];
    _messageLbl.text = [NSString stringWithFormat:@"\"%@\"",currentMessage.message];
    _authorLbl.text = currentMessage.author;
    [self checkFavoriteStatus:currentMessage];
} 

- (void)viewDidAppear:(BOOL)animated
{
    //will show info screen after first launch.
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"])
    {
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CAinfoViewController"] animated:NO completion:nil];
    }
    
    CAMessage* currentMessage = [self loadObjectWithKey:@"CurrentMessage"];
    _messageLbl.text = [NSString stringWithFormat:@"\"%@\"",currentMessage.message];
    _authorLbl.text = currentMessage.author;
    [self checkFavoriteStatus:currentMessage];
    
}

-(void)checkFavoriteStatus:(CAMessage*) message
{
    /*if([message.favorited isEqualToString:@"YES"])
        [_favImgView setImage:[UIImage imageNamed:@"favorite YES"]];
    else
        [_favImgView setImage:[UIImage imageNamed:@"favorite NO"]];*/
    
    NSArray* favoritesList = [[NSUserDefaults standardUserDefaults] arrayForKey:@"FavoritesList"];
    NSMutableArray* favoritesListMA = [[NSMutableArray alloc] initWithArray:favoritesList];
    
    [_favImgView setImage:[UIImage imageNamed:@"favorite NO"]];
    for(int i=0; i<favoritesListMA.count; i++)
    {
        CAMessage* compMessage = [self decodeObject:[favoritesListMA objectAtIndex:i]];
        if([compMessage.message isEqualToString:message.message])
        {
            [_favImgView setImage:[UIImage imageNamed:@"favorite YES"]];
            break;
        }
    }
}

-(void)saveObject:(CAMessage*) object forKey:(NSString*) key
{
    NSData* encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(CAMessage*)loadObjectWithKey:(NSString*) key
{
    NSData* encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    CAMessage* unencodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return unencodedObject;
}

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
    
    if(_messages.count == 0)
    {
        NSMutableArray* renewMessages = [[NSMutableArray alloc] init];
        NSArray* oldMessages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"OldMessages"];
        NSMutableArray* oldMessagesMA = [[NSMutableArray alloc] initWithArray:oldMessages];
        while(oldMessagesMA.count != 0)
        {
            [renewMessages insertObject:[oldMessagesMA objectAtIndex:0] atIndex:arc4random_uniform((uint32_t)renewMessages.count)];
            [oldMessagesMA removeObjectAtIndex:0];
        }
        _messages = renewMessages;
        NSArray* allMessages = [[NSArray alloc] initWithArray:_messages];
        [[NSUserDefaults standardUserDefaults] setObject:allMessages forKey:@"Messages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self changeMessageBtn:self];
    }
    
    CAMessage* currentMessage = [self loadObjectWithKey:@"NextMessage"];
    _messageLbl.text = [NSString stringWithFormat:@"\"%@\"",currentMessage.message];
    _authorLbl.text = currentMessage.author;

    [[NSUserDefaults standardUserDefaults] setObject:[_messages objectAtIndex:0] forKey:@"NextMessage"];
    NSArray* oldMessages = [[NSUserDefaults standardUserDefaults] arrayForKey:@"OldMessages"];
    NSMutableArray* oldMessagesMA = [[NSMutableArray alloc] initWithArray:oldMessages];
        
    [oldMessagesMA addObject:[_messages objectAtIndex:0]];
    oldMessages = [[NSArray alloc] initWithArray:oldMessagesMA];
    [[NSUserDefaults standardUserDefaults] setObject:oldMessages forKey:@"OldMessages"];
    
    [_messages removeObjectAtIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_messages forKey:@"Messages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
        
    [self saveObject:currentMessage forKey:@"CurrentMessage"];
    [self checkFavoriteStatus:currentMessage];
}

- (IBAction)activityAction:(id)sender {
    NSURL* motiv8URL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/motiv8-daily-motivation/id892431850?ls=1&mt=8"];
    NSString* messageStr = [NSString stringWithFormat:@"%@ - %@", _messageLbl.text, _authorLbl.text];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[messageStr, motiv8URL] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                                     UIActivityTypeMail,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypeAirDrop];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)favoriteAction:(id)sender {
    CAMessage* currentMessage = [self loadObjectWithKey:@"CurrentMessage"];
    
    /*if([currentMessage.favorited isEqualToString:@"NO"])
    {
         currentMessage.favorited = @"YES";
        [self addToFavoritesList:currentMessage];
    }
    else
    {
        currentMessage.favorited = @"NO";
        [self removeFromFavoritesList:currentMessage];
    }
    
    [self saveObject:currentMessage forKey:@"CurrentMessage"];
    [self checkFavoriteStatus:currentMessage];*/
    
    NSArray* favoritesList = [[NSUserDefaults standardUserDefaults] arrayForKey:@"FavoritesList"];
    NSMutableArray* favoritesListMA = [[NSMutableArray alloc] initWithArray:favoritesList];
    
    for(int i=0; i<favoritesListMA.count; i++)
    {
        CAMessage* compMessage = [self decodeObject:[favoritesListMA objectAtIndex:i]];
        if([compMessage.message isEqualToString:currentMessage.message])
        {
            [self removeFromFavoritesList:currentMessage];
            [self checkFavoriteStatus:currentMessage];
            return;
        }
    }
    [self addToFavoritesList:currentMessage];
    [self checkFavoriteStatus:currentMessage];
}

-(void)addToFavoritesList:(CAMessage*) message
{
    NSArray* favoritesList = [[NSUserDefaults standardUserDefaults] arrayForKey:@"FavoritesList"];
    NSMutableArray* favoritesListMA = [[NSMutableArray alloc] initWithArray:favoritesList];
    [favoritesListMA addObject:[self encodeObject:message]];
    favoritesList = [[NSArray alloc] initWithArray:favoritesListMA];
    [[NSUserDefaults standardUserDefaults] setObject:favoritesList forKey:@"FavoritesList"];
}

-(void)removeFromFavoritesList:(CAMessage*) message
{
    NSArray* favoritesList = [[NSUserDefaults standardUserDefaults] arrayForKey:@"FavoritesList"];
    NSMutableArray* favoritesListMA = [[NSMutableArray alloc] initWithArray:favoritesList];
    
    for(int i=0; i<favoritesListMA.count; i++)
    {
        CAMessage* compMessage = [self decodeObject:[favoritesListMA objectAtIndex:i]];
        if([compMessage.message isEqualToString:message.message])
        {
            [favoritesListMA removeObjectAtIndex:i];
            break;
        }
    }
    
    favoritesList = [[NSArray alloc] initWithArray:favoritesListMA];
    [[NSUserDefaults standardUserDefaults] setObject:favoritesList forKey:@"FavoritesList"];
}

- (IBAction)favoriteListAction:(id)sender {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"favNavController"] animated:YES completion:nil];
}

@end
