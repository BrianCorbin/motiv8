//
//  CAFavQuoteViewController.m
//  motiv8
//
//  Created by Brian Corbin on 7/21/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import "CAFavQuoteViewController.h"

@interface CAFavQuoteViewController ()
- (IBAction)closeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UILabel *authorLbl;

@end

@implementation CAFavQuoteViewController

@synthesize messageLbl, authorLbl;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    NSString* message = [[NSUserDefaults standardUserDefaults] stringForKey:@"FavMessage"];
    NSString* author = [[NSUserDefaults standardUserDefaults] stringForKey:@"FavAuthor"];
    
    messageLbl.text = message;
    authorLbl.text = author;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
