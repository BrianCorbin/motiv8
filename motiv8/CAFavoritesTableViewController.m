//
//  CAFavoritesTableViewController.m
//  motiv8
//
//  Created by Brian Corbin on 7/15/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import "CAFavoritesTableViewController.h"

@interface CAFavoritesTableViewController ()

- (IBAction)closeAction:(id)sender;

@property (strong, nonatomic) NSMutableArray* favoriteQuotes;

@end

@implementation CAFavoritesTableViewController

@synthesize favoriteQuotes;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    favoriteQuotes = [[NSMutableArray alloc] init];
    CAMessage* tempMessage = [[CAMessage alloc] init];
    NSArray* encodedMessages = [[NSUserDefaults standardUserDefaults] objectForKey:@"FavoritesList"];
    for(NSData* object in encodedMessages)
    {
        tempMessage = [self decodeObject:object];
        [favoriteQuotes addObject:tempMessage];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [favoriteQuotes count];
}

- (IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message" forIndexPath:indexPath];
    UILabel* messageLbl = (UILabel*)[cell viewWithTag:1];
    CAMessage* message = [favoriteQuotes objectAtIndex:indexPath.row];
    messageLbl.text = message.message;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CAMessage* message = [favoriteQuotes objectAtIndex:indexPath.row];

    [[NSUserDefaults standardUserDefaults] setObject:message.message forKey:@"FavMessage"];
    [[NSUserDefaults standardUserDefaults] setObject:message.author forKey:@"FavAuthor"];
    
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CAFavQuoteViewController"] animated:YES completion:nil];
}

@end
