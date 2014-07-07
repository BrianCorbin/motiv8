//
//  CAinfoViewController.m
//  motiv8
//
//  Created by Brian Corbin on 6/11/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import "CAinfoViewController.h"

@interface CAinfoViewController ()
- (IBAction)doneAction:(UIBarButtonItem *)sender;

@end

@implementation CAinfoViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
